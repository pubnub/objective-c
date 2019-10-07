/**
 * @author Serhii Mamontov
 * @version 4.9.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNHistoryParser.h"
#import "PubNub+CorePrivate.h"
#import "PNConstants.h"
#import "PNLogMacro.h"
#import "PNLLogger.h"
#import "PNHelpers.h"
#import "PNAES.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNHistoryParser ()

/**
 * @brief Process list of messages.
 *
 * @discussion Processing may include message decryption and mobile payload format restore.
 *
 * @param messages List of messages which should be processed.
 * @param additionalData Dictionary which may contain additional data which maybe required during
 *     messages processing.
 *
 * @return Parsed message / event entries from history.
 *
 * @since 4.5.6
 */
+ (NSMutableDictionary *)processedMessagesFrom:(nullable NSArray *)messages
                                      withData:(nullable NSDictionary<NSString *, id> *)additionalData;


#pragma mark - Misc

/**
 * @brief Iterate through action senders and replace \a NSString \c actionTimetoken with \a NSNumber
 * value.
 *
 * @param actionsForTypes List contains set of values for various \c action type (\c receip,
 * \c reaction and \c custom).
 *
 * @since 4.11.0
 */
+ (void)normalizeActionTimetokens:(NSArray<NSMutableDictionary *> *)actionsForTypes;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNHistoryParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    return @[
        @(PNHistoryOperation),
        @(PNHistoryForChannelsOperation),
        @(PNHistoryWithActionsOperation)
    ];
}

+ (BOOL)requireAdditionalData {
    return YES;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response 
                                               withData:(NSDictionary<NSString *, id> *)additionalData {

    NSDictionary *processedResponse = nil;

    if ([response isKindOfClass:[NSArray class]] && ((NSArray *)response).count == 3) {
        NSArray *messages = (NSArray *)response[0];
        NSMutableDictionary *data = [@{
            @"start": (NSArray *)response[1],
            @"end": (NSArray *)response[2],
            @"messages": [NSMutableArray new]
        } mutableCopy];
        NSMutableDictionary *processedMessages = [self processedMessagesFrom:messages
                                                                    withData:additionalData];

        if (processedMessages[@"messages"]) {
            data[@"messages"] = processedMessages[@"messages"];
        }

        if (processedMessages[@"decryptError"]) {
            data[@"decryptError"] = @YES;
        }

        processedResponse = data;
    } else if ([response isKindOfClass:[NSDictionary class]] &&
               response[@"channels"] && response[@"status"]) {

        NSMutableDictionary *data = [@{@"channels": [NSMutableDictionary new]} mutableCopy];
        NSDictionary *channels = response[@"channels"];

        [channels enumerateKeysAndObjectsUsingBlock:^(NSString *channel, NSArray *messages,
                                                      __unused BOOL *stop) {

            NSMutableDictionary *processedMessages = [self processedMessagesFrom:messages
                                                                        withData:additionalData];
            data[@"channels"][channel] = processedMessages[@"messages"] ?: @[];

            if (processedMessages[@"decryptError"]) {
                data[@"decryptError"] = @YES;
            }
        }];

        processedResponse = data;
    }
    
    return processedResponse;
}

+ (NSMutableDictionary *)processedMessagesFrom:(NSArray *)messages
                                      withData:(NSDictionary<NSString *, id> *)additionalData {

    NSMutableDictionary *data = [@{@"messages": [NSMutableArray new]} mutableCopy];
    [messages enumerateObjectsUsingBlock:^(id messageObject, __unused NSUInteger messageObjectIdx,
                                           __unused BOOL *messageObjectEnumeratorStop) {
        
        NSArray<NSDictionary *> *actions = nil;
        NSDictionary *metadata = nil;
        id message = messageObject;
        NSNumber *timeToken = nil;

        if ([messageObject isKindOfClass:[NSDictionary class]] && messageObject[@"message"] &&
            (messageObject[@"timetoken"] || messageObject[@"meta"] || messageObject[@"actions"])) {
            
            timeToken = messageObject[@"timetoken"];
            message = messageObject[@"message"];
            actions = messageObject[@"actions"];
            metadata = messageObject[@"meta"];
            messageObject = message;
            
            if (![metadata isKindOfClass:[NSDictionary class]]) {
                metadata = nil;
            }
            
            timeToken = timeToken ? @(((NSString *)timeToken).longLongValue) : nil;
            [self normalizeActionTimetokens:((NSDictionary *)actions).allValues];
        }

        if (((NSString *)additionalData[@"cipherKey"]).length){
            BOOL isDictionary = [message isKindOfClass:[NSDictionary class]];
            NSError *decryptionError;
            id decryptedMessage = nil;
            id dataForDecryption = isDictionary ? ((NSDictionary *)message)[@"pn_other"] : message;

            if ([dataForDecryption isKindOfClass:[NSString class]]) {
                NSData *eventData = [PNAES decrypt:dataForDecryption
                                           withKey:additionalData[@"cipherKey"]
                                          andError:&decryptionError];

                NSString *decryptedMessageString = nil;
                if (eventData) {
                    decryptedMessageString = [[NSString alloc] initWithData:eventData
                                                                   encoding:NSUTF8StringEncoding];
                }

                // In case if decrypted message (because of error suppression) is equal to original
                // message, there is no need to retry JSON de-serialization.
                if (decryptedMessageString && ![decryptedMessageString isEqualToString:dataForDecryption]) {

                    decryptedMessage = [PNJSON JSONObjectFrom:decryptedMessageString withError:nil];
                }
            }
            
            if (decryptionError || !decryptedMessage) {

                PNLLogger *logger = [PNLLogger loggerWithIdentifier:kPNClientIdentifier];
                [logger enableLogLevel:PNAESErrorLogLevel];
                PNLogAESError(logger, @"<PubNub::AES> History entry decryption error: %@",
                              decryptionError);
                data[@"decryptError"] = @YES;

                // Restore message to original form.
                message = messageObject;
            } else {
                if (isDictionary) {
                    NSMutableDictionary *mutableMessage = [(NSDictionary *)message mutableCopy];
                    [mutableMessage removeObjectForKey:@"pn_other"];

                    if (![decryptedMessage isKindOfClass:[NSDictionary class]]) {
                        mutableMessage[@"pn_other"] = decryptedMessage;
                    } else {
                        [mutableMessage addEntriesFromDictionary:decryptedMessage];
                    }

                    decryptedMessage = [mutableMessage copy];
                }

                message = decryptedMessage;
            }
        }
        
        if (message) {
            if (timeToken || metadata || actions) {
                NSMutableDictionary *messageWithInfo = [@{ @"message": message } mutableCopy];
                
                if (timeToken) {
                    messageWithInfo[@"timetoken"] = timeToken;
                }
                
                if (metadata) {
                    messageWithInfo[@"metadata"] = metadata;
                }
                
                if (actions) {
                    messageWithInfo[@"actions"] = actions;
                }
                
                message = messageWithInfo;
            }
            
            [data[@"messages"] addObject:message];
        }
    }];
    
    return data;
}

#pragma mark - Misc

+ (void)normalizeActionTimetokens:(NSArray<NSMutableDictionary *> *)actionsForTypes {
    for (NSMutableDictionary *actionValues in actionsForTypes) {
        for (NSString *actionValue in actionValues) {
            for (NSMutableDictionary *action in actionValues[actionValue]) {
                action[@"actionTimetoken"] = @(((NSString *)action[@"actionTimetoken"]).longLongValue);
            }
        }
    }
}

#pragma mark -


@end
