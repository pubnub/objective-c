#import "PNSubscribeData.h"
#import "PNSubscribeMessageActionEventData.h"
#import "PNSubscribePresenceEventData.h"
#import "PNSubscribeMessageEventData.h"
#import "PNSubscribeObjectEventData.h"
#import "PNSubscribeSignalEventData.h"
#import "PNSubscribeFileEventData.h"
#import "PNCryptoProvider.h"
#import "PNJSONDecoder.h"
#import "PNCodable.h"
#import "PNSubscribeMessageEventData+Private.h"
#import "PNSubscribeFileEventData+Private.h"
#import "PNSubscribeEventData+Private.h"
#import "PNPrivateStructures.h"
#import "PNConstants.h"
#import "PNFunctions.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Subscribe request response private extension.
@interface PNSubscribeData () <PNCodable>


#pragma mark - Properties

/// List with received real-time updates.
@property(strong, nonatomic) NSArray<PNSubscribeEventData *> *updates;

/// Next subscription cursor.
///
/// The cursor contains information about the start of the next real-time update timeframe.
@property(strong, nonatomic) PNSubscribeCursorData *cursor;


#pragma mark - Initialization and Configuration

/// Initialize `Subscribe` data object.
///
/// - Parameters:
///   - updates: Received real-time updates.
///   - cursor: Next subscription cursor.
/// - Returns: Initialized `Subscribe` data object.
- (instancetype)initWithUpdates:(NSArray<PNSubscribeEventData *> *)updates cursor:(PNSubscribeCursorData *)cursor;


#pragma mark - Helpers

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

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSubscribeData


#pragma mark - Initialization and Configuration

- (instancetype)initWithUpdates:(NSArray<PNSubscribeEventData *> *)updates cursor:(PNSubscribeCursorData *)cursor {
    if ((self = [super init])) {
        _updates = updates;
        _cursor = cursor;
    }

    return self;
}

- (instancetype)initObjectWithCoder:(id<PNDecoder>)coder {
    id<PNCryptoProvider> cryptoModule = coder.additionalData[@"cryptoModule"];
    NSDictionary *payload = [coder decodeObjectOfClass:[NSDictionary class]];
    if (![payload isKindOfClass:[NSDictionary class]] || !payload[@"t"] || !payload[@"m"]) return nil;

    __block NSError *error;
    PNSubscribeCursorData *cursor = [PNJSONDecoder decodedObjectOfClass:[PNSubscribeCursorData class]
                                                         fromDictionary:payload[@"t"]
                                                              withError:&error];
    if (error) return nil;
    
    NSArray<NSDictionary *> *receivedUpdates = payload[@"m"];
    NSMutableArray<PNSubscribeEventData *> *updates = [NSMutableArray arrayWithCapacity:receivedUpdates.count];

    [receivedUpdates enumerateObjectsUsingBlock:^(NSDictionary *update, __unused NSUInteger idx, __unused BOOL *stop) {
        PNMessageType messageType = ((NSNumber *)update[@"e"]).unsignedIntegerValue;
        NSString *fingerprint = PNMessageFingerprint(update[@"d"]);
        NSMutableDictionary *patchedUpdate = [update mutableCopy];
        NSString *channel = update[@"c"];
        id updatePayload = update[@"d"];
        PNSubscribeEventData *data;
        NSError *decryptionError;
        Class dataClass;

        [patchedUpdate removeObjectForKey:@"d"];
        if (messageType == PNRegularMessageType && [PNChannel isPresenceObject:channel]) {
            NSMutableDictionary *presenceData = [updatePayload mutableCopy];
            dataClass = [PNSubscribePresenceEventData class];
            messageType = PNPresenceMessageType;

            if (presenceData[@"data"]) presenceData[@"state"] = presenceData[@"data"];

            // Rearrange for deserialization model.
            [patchedUpdate addEntriesFromDictionary:@{
                @"action": updatePayload[@"action"],
                @"presence": presenceData
            }];
        } else if (!update[@"e"] || messageType == PNRegularMessageType || messageType == PNSignalMessageType) {
            if (!update[@"e"]) messageType = PNRegularMessageType;
            dataClass = messageType == PNRegularMessageType ? [PNSubscribeMessageEventData class]
                                                            : [PNSubscribeSignalEventData class];

            if (messageType == PNRegularMessageType) {
                updatePayload = [self decryptedMessageFromData:updatePayload
                                              withCryptoModule:cryptoModule
                                                         error:&decryptionError];
            }

            // Rearrange for deserialization model.
            [patchedUpdate addEntriesFromDictionary:@{ @"message": updatePayload }];
        } else if (messageType == PNObjectMessageType) {
            NSMutableDictionary *membershipData = [updatePayload mutableCopy];
            dataClass = [PNSubscribeObjectEventData class];

            // Rearrange for deserialization model.
            if (membershipData[@"data"][@"uuid"]) {
                NSMutableDictionary *data = [membershipData[@"data"] mutableCopy];
                data[@"_uuid"] = data[@"uuid"];
                [data removeObjectForKey:@"uuid"];
                membershipData[@"data"] = data;
            }

            // Rearrange for deserialization model.
            [patchedUpdate addEntriesFromDictionary:membershipData];
        } else if (messageType == PNMessageActionType) {
            dataClass = [PNSubscribeMessageActionEventData class];

            // Rearrange for deserialization model.
            NSMutableDictionary *actionEventData = [updatePayload mutableCopy];
            NSMutableDictionary *actionData = [actionEventData[@"data"] mutableCopy];
            actionData[@"uuid"] = update[@"i"];
            actionEventData[@"data"] = actionData;

            [patchedUpdate addEntriesFromDictionary:actionEventData];
        } else if (messageType == PNFileMessageType) {
            dataClass = [PNSubscribeFileEventData class];
            updatePayload = [self decryptedMessageFromData:updatePayload
                                          withCryptoModule:cryptoModule
                                                     error:&decryptionError];

            // Rearrange for deserialization model.
            [patchedUpdate addEntriesFromDictionary:updatePayload];
        }

        data = [PNJSONDecoder decodedObjectOfClass:dataClass fromDictionary:patchedUpdate withError:&error];
        if (fingerprint) data.pnFingerprint = fingerprint;

        if (data && !error) {
            data.messageType = @(messageType);
            
            if (decryptionError) {
                if (messageType == PNFileMessageType) ((PNSubscribeFileEventData *)data).decryptionError = decryptionError;
                else ((PNSubscribeMessageEventData *)data).decryptionError = decryptionError;
            }

            [updates addObject:data];
        }
        else if (error) *stop = YES;
    }];

    return !error ? [self initWithUpdates:updates cursor:cursor] : nil;
}


#pragma mark - Helpers

- (id)decryptedMessageFromData:(id)data withCryptoModule:(id<PNCryptoProvider>)cryptoModule error:(NSError **)error {
    if (!cryptoModule) return data;

    BOOL isDictionary = [data isKindOfClass:[NSDictionary class]];
    NSError *decryptionError;
    id decryptedEvent = nil;
    id encryptedData = isDictionary ? ((NSDictionary *)data)[@"pn_other"] : data;

    if ([encryptedData isKindOfClass:[NSString class]]) {
        NSCharacterSet *trimCharSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
        encryptedData = [PNString base64DataFrom:[encryptedData stringByTrimmingCharactersInSet:trimCharSet]];
        PNResult<NSData *> *decryptResult = [cryptoModule decryptData:encryptedData];
        NSString *decryptedEventData = nil;

        if (decryptResult.isError) decryptionError = decryptResult.error;
        else decryptedEventData = [[NSString alloc] initWithData:decryptResult.data encoding:NSUTF8StringEncoding];

        if (decryptedEventData && ![decryptedEventData isEqualToString:encryptedData]) {
            decryptedEvent = [PNJSON JSONObjectFrom:decryptedEventData withError:nil];
        }
    }

    if (decryptionError || !decryptedEvent) {
        if (!decryptionError) {
            decryptionError = [NSError errorWithDomain:PNCryptorErrorDomain code:PNCryptorErrorDecryption userInfo:nil];
        }
        *error = decryptionError;

        return isDictionary ? ((NSDictionary *)data)[@"pn_other"] : data;
    } else if (isDictionary) {
        NSMutableDictionary *mutableData = [(NSDictionary *)data mutableCopy];
        [mutableData removeObjectForKey:@"pn_other"];

        if (![decryptedEvent isKindOfClass:[NSDictionary class]]) mutableData[@"pn_other"] = decryptedEvent;
        else [mutableData addEntriesFromDictionary:decryptedEvent];

        decryptedEvent = [mutableData copy];
    }

    return decryptedEvent;
}

#pragma mark -


@end
