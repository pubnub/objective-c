/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNHistoryParser.h"
#import "PubNub+CorePrivate.h"
#import "PNConstants.h"
#import "PNLogMacro.h"
#import "PNLLogger.h"
#import "PNHelpers.h"
#import "PNAES.h"


#pragma mark Private interface declaration

@interface PNHistoryParser ()

/**
 @brief      Process list of messages.
 @discussion Processing may include message decryption and mobile payload format restore.
 
 @since 4.5.6
 
 @param messages       Reference on list of messages which should be processed.
 @param additionalData Reference on dictionary which may contain additional data which maybe required during
                       messages processing.
 */
+ (NSMutableDictionary *)processedMessagesFrom:(nullable NSArray *)messages
                                      withData:(nullable NSDictionary<NSString *, id> *)additionalData;

@end


#pragma mark - Interface implementation

@implementation PNHistoryParser


#pragma mark - Identification

+ (NSArray<NSNumber *> *)operations {
    
    return @[@(PNHistoryOperation), @(PNHistoryForChannelsOperation)];
}

+ (BOOL)requireAdditionalData {
    
    return YES;
}


#pragma mark - Parsing

+ (NSDictionary<NSString *, id> *)parsedServiceResponse:(id)response 
                                               withData:(NSDictionary<NSString *, id> *)additionalData {
    
    // To handle case when response is unexpected for this type of operation processed value sent through 
    // 'nil' initialized local variable.
    NSDictionary *processedResponse = nil;
    
    // Array is valid response type for v2 history request.
    if ([response isKindOfClass:[NSArray class]] && ((NSArray *)response).count == 3) {
        
        NSMutableDictionary *data = [@{@"start": (NSArray *)response[1], @"end": (NSArray *)response[2],
                                       @"messages": [NSMutableArray new]} mutableCopy];
        NSArray *messages = (NSArray *)response[0];
        NSMutableDictionary *processedMessages = [self processedMessagesFrom:messages withData:additionalData];
        if (processedMessages[@"messages"]) { data[@"messages"] = processedMessages[@"messages"]; }
        if (processedMessages[@"decryptError"]) { data[@"decryptError"] = @YES; }
        processedResponse = data;
    }
     // Dictionary is valid response type for v3 history request.
    else if ([response isKindOfClass:[NSDictionary class]] && response[@"channels"] && response[@"status"]) {
        
        NSMutableDictionary *data = [@{@"channels": [NSMutableDictionary new]} mutableCopy];
        NSDictionary *channels = response[@"channels"];
        [channels enumerateKeysAndObjectsUsingBlock:^(NSString *channel, NSArray *messages, BOOL *channelsEnumeratorStop) {
            
            NSMutableDictionary *processedMessages = [self processedMessagesFrom:messages withData:additionalData];
            data[@"channels"][channel] = (processedMessages[@"messages"]?: @[]);
            if (processedMessages[@"decryptError"]) { data[@"decryptError"] = @YES; }
        }];
        processedResponse = data;
    }
    
    return processedResponse;
}

+ (NSMutableDictionary *)processedMessagesFrom:(NSArray *)messages
                                      withData:(NSDictionary<NSString *, id> *)additionalData {
    
    BOOL shouldStripMobilePayload = ((NSNumber *)additionalData[@"stripMobilePayload"]).boolValue;
    NSMutableDictionary *data = [@{@"messages": [NSMutableArray new]} mutableCopy];
    [messages enumerateObjectsUsingBlock:^(id messageObject, __unused NSUInteger messageObjectIdx,
                                           __unused BOOL *messageObjectEnumeratorStop) {
        
        NSNumber *timeToken = nil;
        id message = messageObject;
        
        // Check whether history response returned with 'timetoken' or not.
        if ([messageObject isKindOfClass:[NSDictionary class]] &&messageObject[@"message"] && 
            messageObject[@"timetoken"]) {
            
            timeToken = messageObject[@"timetoken"];
            message = messageObject[@"message"];
            messageObject = message;
        }
        
        // Try decrypt message if possible.
        if (((NSString *)additionalData[@"cipherKey"]).length){
            
            NSError *decryptionError;
            id decryptedMessage = nil;
            id dataForDecryption = ([message isKindOfClass:[NSDictionary class]] ? ((NSDictionary *)message)[@"pn_other"] : message);
            if ([dataForDecryption isKindOfClass:[NSString class]]) {
                
                NSData *eventData = [PNAES decrypt:dataForDecryption withKey:additionalData[@"cipherKey"]
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
                DDLogAESError(logger, @"<PubNub::AES> History entry decryption error: %@", 
                              decryptionError);
                data[@"decryptError"] = @YES;
                
                // Restore message to original form.
                message = messageObject;
            }
            else { 
                
                if (!shouldStripMobilePayload && [message isKindOfClass:[NSDictionary class]]) {
                    
                    NSMutableDictionary *mutableMessage = [message mutableCopy];
                    [mutableMessage removeObjectForKey:@"pn_other"];
                    if (![decryptedMessage isKindOfClass:[NSDictionary class]]) {
                        
                        mutableMessage[@"pn_other"] = decryptedMessage;
                    } else { [mutableMessage addEntriesFromDictionary:decryptedMessage]; }
                    decryptedMessage = [mutableMessage copy];
                }
                message = decryptedMessage;
            }
        }
        
        if (message) {
            
            if (shouldStripMobilePayload && [message isKindOfClass:[NSDictionary class]] &&
                (message[@"pn_apns"] || message[@"pn_gcm"] || message[@"pn_mpns"])) {
                
                id decomposedMessage = message;
                if (!message[@"pn_other"]) {
                    
                    NSMutableDictionary *dictionaryData = [message mutableCopy];
                    [dictionaryData removeObjectsForKeys:@[@"pn_apns", @"pn_gcm", @"pn_mpns"]];
                    decomposedMessage = dictionaryData;
                }
                else { decomposedMessage = message[@"pn_other"]; }
                message = decomposedMessage;
            }
            
            message = (timeToken ? @{@"message": message, @"timetoken": timeToken} : message);
            [data[@"messages"] addObject:message];
        }
    }];
    
    return data;
}

#pragma mark -


@end
