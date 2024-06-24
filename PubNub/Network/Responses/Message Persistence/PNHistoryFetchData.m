#import "PNHistoryFetchData+Private.h"
#import <PubNub/PNCryptoProvider.h>
#import <PubNub/PNCodable.h>
#ifndef PUBNUB_DISABLE_LOGGER
#import <PubNub/PNLLogger.h>
#import "PNConstants.h"
#import "PNLogMacro.h"
#endif // PUBNUB_DISABLE_LOGGER
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Fetch history request response data private extension.
@interface PNHistoryFetchData () <PNCodable>

#pragma mark - Properties


/// Batch messages fetch.
///
/// Each key represent name of the channel and value is list of messages for that channel.
///
/// > Note: Property will be set if history has been requested for multiple single channel.
/// > Note: Kept mutable reference to make it possible to decrypt data.
@property(strong, nonatomic, readonly) NSMutableDictionary<NSString *, NSMutableArray<NSMutableDictionary *> *> *channelsUpdates;

/// Whether there were decryption error or not.
@property(assign, nonatomic) BOOL decryptError;


#pragma mark - Initialization and Configuration

/// Initialize history data object with processed updates.
///
/// - Parameters:
///   - updates: Pre-processed messages payloads for each received channel.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: Initialized history data object.
- (instancetype)initWithChannelUpdates:(NSMutableDictionary<NSString *, NSMutableArray<NSMutableDictionary *> *> *)updates
                                 error:(NSError *)error;


#pragma mark - Helpers

/// Re-format source ``updates`` into expected structure.
///
/// - Parameters:
///   - updates: List of updates which should be pre-processed restructured.
///   - cryptoModule: Configured crypto module which should be used to decrypt original payloads.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: List of updates with expected structure.
- (NSMutableArray *)formattedUpdatesFromArray:(NSArray *)updates
                             withCryptoModule:(nullable id<PNCryptoProvider>)cryptoModule
                                        error:(NSError **)error;

/// Decrypt payload.
///
/// - Parameters:
///   - data: Previously encrypted data.
///   - cryptoModule: cryptor which should be used to decrypt data.
///   - error: If an error occurs, upon return contains an `NSError` object that describes the problem.
/// - Returns: Decrypted payload or original `data` if `cryptoModule` not set.
- (id)decryptedMessageFromData:(id)data
              withCryptoModule:(nullable id<PNCryptoProvider>)cryptoModule
                         error:(NSError **)error;

/// Convert action timetokens into `NSNumber`.
///
/// - Parameter actions: Message reactions by type.
/// - Returns: New dictionary with reactions where message action timetoken sotred as `NSNumber` instance.
- (NSMutableDictionary *)normalizeActionTimetokens:(NSMutableDictionary *)actions;

#pragma mark -


@end

/// History message data.
@interface PNMessageData : NSObject <PNCodable>


#pragma mark - Properties

/// Previously published message object.
@property(strong, nonatomic, readonly) id message;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNHistoryFetchData


#pragma mark - Properties

- (NSArray<NSDictionary *> *)messages {
    if (self.channelsUpdates.count != 1) return nil;
    return self.channelsUpdates[self.channelsUpdates.allKeys.firstObject];
}

- (NSNumber *)start {
    NSArray *messages = self.messages;
    NSDictionary *message = messages.firstObject;
    return message ? message[@"timetoken"] : nil;
}

- (NSNumber *)end {
    NSArray *messages = self.messages;
    NSDictionary *message = messages.lastObject;
    return message ? message[@"timetoken"] : nil;
}


#pragma mark - Initialization and Configuration

- (instancetype)initWithChannelUpdates:(NSMutableDictionary<NSString *, NSMutableArray<NSMutableDictionary *> *> *)updates
                                 error:(NSError *)error {
    if ((self = [super init])) {
        _decryptError = error != nil;
        _channelsUpdates = updates;
    }
    return self;
}

- (instancetype)initObjectWithCoder:(id<PNDecoder>)coder {
    NSDictionary *payload = [coder decodeObjectOfClass:[NSDictionary class]];
    if (![payload isKindOfClass:[NSDictionary class]] || payload[@"channels"]) return nil;

    id<PNCryptoProvider> cryptoModule = coder.additionalData[@"cryptoModule"];
    NSMutableDictionary *channelMessages = [NSMutableDictionary new];
    NSDictionary *channels = payload[@"channels"];
    __block NSError *decryptionError;

    [channels enumerateKeysAndObjectsUsingBlock:^(NSString *channel, NSArray *messages, BOOL *stop) {
        NSError *error;
        channelMessages[channel] = [self formattedUpdatesFromArray:messages withCryptoModule:cryptoModule error:&error];

        if (!decryptionError) decryptionError = error;
    }];


    return [self initWithChannelUpdates:channelMessages error:decryptionError];
}


#pragma mark - Helpers

- (NSMutableArray *)formattedUpdatesFromArray:(NSArray *)updates 
                             withCryptoModule:(id<PNCryptoProvider>)cryptoModule
                                        error:(NSError **)processingError {
    NSMutableArray *processed = [NSMutableArray arrayWithCapacity:updates.count];
    __block NSError *decError;

    [updates enumerateObjectsUsingBlock:^(NSDictionary *entry, __unused NSUInteger entryIdx, __unused BOOL *stop) {
        NSDictionary *actions = [self normalizeActionTimetokens:entry[@"actions"]];
        NSNumber *messageType = entry[@"message_type"];
        NSNumber *timeToken = entry[@"timetoken"];
        NSDictionary *metadata = entry[@"meta"];
        NSString *senderUUID = entry[@"uuid"];
        NSError *error;
        id message = [self decryptedMessageFromData:entry[@"message"] withCryptoModule:cryptoModule error:&error];

        if (![metadata isKindOfClass:[NSDictionary class]]) metadata = nil;

        timeToken = timeToken ? @(((NSString *)timeToken).longLongValue) : nil;

        NSMutableDictionary *messageWithInfo = [@{ @"message": message } mutableCopy];
        if ([messageType isKindOfClass:[NSNumber class]]) messageWithInfo[@"messageType"] = messageType;
        if (timeToken) messageWithInfo[@"timetoken"] = timeToken;
        if (metadata) messageWithInfo[@"metadata"] = metadata;
        if (actions) messageWithInfo[@"actions"] = actions;
        if (senderUUID.length) messageWithInfo[@"uuid"] = senderUUID;

        if (!decError && error) decError = error;

        [processed addObject:messageWithInfo];
    }];

    if(decError) *processingError = decError;

    return processed;
}

- (id)decryptedMessageFromData:(id)data withCryptoModule:(id<PNCryptoProvider>)cryptoModule error:(NSError **)error {
    if (!cryptoModule) return data;

    BOOL isDictionary = [data isKindOfClass:[NSDictionary class]];
    NSError *decryptionError;
    id decryptedMessage = nil;
    id encryptedData = isDictionary ? ((NSDictionary *)data)[@"pn_other"] : data;

    if ([encryptedData isKindOfClass:[NSString class]]) {
        NSCharacterSet *trimCharSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
        encryptedData = [PNString base64DataFrom:[encryptedData stringByTrimmingCharactersInSet:trimCharSet]];
        PNResult<NSData *> *decryptResult = [cryptoModule decryptData:encryptedData];
        NSString *decryptedEventData = nil;

        if (decryptResult.isError) decryptionError = decryptResult.error;
        else decryptedEventData = [[NSString alloc] initWithData:decryptResult.data encoding:NSUTF8StringEncoding];

        if (decryptedEventData && ![decryptedEventData isEqualToString:encryptedData]) {
            decryptedMessage = [PNJSON JSONObjectFrom:decryptedEventData withError:nil];
        }
    }

    if (decryptionError || !decryptedMessage) {
#ifndef PUBNUB_DISABLE_LOGGER
        PNLLogger *logger = [PNLLogger loggerWithIdentifier:kPNClientIdentifier];
        [logger enableLogLevel:PNAESErrorLogLevel];
        PNLogAESError(logger, @"<PubNub::AES> History entry decryption error: %@", decryptionError);
#endif // PUBNUB_DISABLE_LOGGER
        *error = decryptionError;

        return isDictionary ? ((NSDictionary *)data)[@"pn_other"] : data;
    } else if (isDictionary) {
        NSMutableDictionary *mutableMessage = [(NSDictionary *)data mutableCopy];
        [mutableMessage removeObjectForKey:@"pn_other"];

        if (![decryptedMessage isKindOfClass:[NSDictionary class]])  mutableMessage[@"pn_other"] = decryptedMessage;
        else [mutableMessage addEntriesFromDictionary:decryptedMessage];

        decryptedMessage = [mutableMessage copy];
    }

    return decryptedMessage;
}

- (NSMutableDictionary *)normalizeActionTimetokens:(NSMutableDictionary *)actions {
    if (actions.count == 0) return nil;

    NSMutableDictionary *updatedActions = [NSMutableDictionary dictionaryWithCapacity:actions.count];
    for (NSString *type in actions) {
        NSDictionary *actionValues = actions[type];
        NSMutableDictionary *updatedActionValues = [NSMutableDictionary dictionaryWithCapacity:actionValues.count];

        for (NSString *value in actionValues) {
            NSArray<NSDictionary *> *senders = actionValues[value];
            NSMutableArray *updatedSenders = [NSMutableArray arrayWithCapacity:senders.count];

            for(NSDictionary *sender in senders) {
                NSMutableDictionary *updatedSender = [sender mutableCopy];
                updatedSender[@"actionTimetoken"] = @(((NSString *)sender[@"actionTimetoken"]).longLongValue);
                [updatedSenders addObject:updatedSender];
            }

            updatedActionValues[value] = updatedSenders;
        }

        updatedActions[type] = updatedActionValues;
    }

    return updatedActions;
}

#pragma mark -


@end
