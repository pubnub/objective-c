#import "PNBasePublishRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"
#import "PNError.h"
#import "PNAES.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General request for all `Publish` API endpoints private extension.
@interface PNBasePublishRequest ()


#pragma mark - Properties

/// Crypto module for data processing.
///
/// **PubNub** client uses this instance to _encrypt_ and _decrypt_ data that has been sent and received from the
/// **PubNub** network.
@property(strong, nullable, nonatomic) id<PNCryptoProvider> cryptoModule;

/// Whether message should be compressed before sending or not.
@property(assign, nonatomic, getter = shouldCompress) BOOL compress;

/// Serialized `NSDictionary` with values which should be used by **PubNub** service to filter messages.
@property(strong, nullable, nonatomic) NSString *preparedMetadata;

/// Dictionary with payloads for different vendors (Apple with `'apns'` key and Google with `'gcm'`).
@property(strong, nullable, nonatomic) NSDictionary *payloads;

/// Message which has been prepared for publish.
///
/// Depending from request configuration this object may store encrypted message with mobile push payloads.
@property(strong, nullable, nonatomic) NSString *preparedMessage;

/// Publish request sequence number.
@property(assign, nonatomic) NSUInteger sequenceNumber;

/// Request post body.
@property(strong, nullable, nonatomic) NSData *body;

/// Name of channel to which message should be published.
@property(copy, nonatomic) NSString *channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNBasePublishRequest


#pragma mark - Properties

- (TransportMethod)httpMethod {
    return self.shouldCompress ? TransportPOSTMethod : TransportGETMethod;
}

- (BOOL)shouldCompressBody {
    return self.shouldCompress;
}

- (NSDictionary *)headers {
    NSMutableDictionary *headers = [([super headers] ?: @{}) mutableCopy];
    
    if (self.httpMethod == TransportPOSTMethod) headers[@"Content-Type"] = @"application/json";
    
    return headers;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [NSMutableDictionary new];

    if (self.customMessageType.length) query[@"custom_message_type"] = self.customMessageType;
    if (self.preparedMetadata.length) query[@"meta"] = self.preparedMetadata;
    if (self.shouldStore && self.ttl > 0) query[@"ttl"] = @(self.ttl).stringValue;
    if (!self.shouldReplicate) query[@"norep"] = @"true";
    if (!self.shouldStore) query[@"store"] = @"0";
    query[@"seqn"] = @(self.sequenceNumber);
    
    if (self.arbitraryQueryParameters.count) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query.count ? query : nil;
}

- (NSData *)body {
    if (self.httpMethod == TransportPOSTMethod) return [self.preparedMessage dataUsingEncoding:NSUTF8StringEncoding];
    return nil;
}


- (id)preFormattedMessage {
    return self.message;
}


#pragma mark - Initialization & Configuration

-  (instancetype)initWithChannel:(NSString *)channel {
    if ((self = [super init])) {
        _channel = [channel copy];
        _replicate = YES;
        _store = YES;
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    if (self.channel.length == 0) return [self missingParameterError:@"channel" forObjectRequest:@"Request"];
    
    NSString *preFormattedMessage = self.preFormattedMessage;
    NSString *messageForPublish = @"";
    NSError *error = nil;

    messageForPublish = [PNJSON JSONStringFrom:preFormattedMessage withError:&error];
    BOOL isMessageEncrypted = NO;

    if (error) {
        NSDictionary *userInfo = PNErrorUserInfo(
            @"Request parameters error",
            @"Message serialization did fail",
            @"Ensure that only JSON-compatible values used in 'message'.",
            error
        );
        
        return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
    }
    
    if (self.cryptoModule) {
        NSString *encryptedMessage = [self encryptedMessage:messageForPublish error:&error];
        
        if (!error) {
            messageForPublish = [encryptedMessage copy];
            isMessageEncrypted = YES;
        } else if (error) {
            NSDictionary *userInfo = PNErrorUserInfo(
                @"Request parameters error",
                @"Message encryption did fail.",
                nil,
                error
            );

            return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
        }
    }
    
    if (self.payloads.count) {
        id targetMessage = isMessageEncrypted ? messageForPublish : preFormattedMessage;
        NSDictionary *mergedData = [self mergedMessage:targetMessage withMobilePushPayload:self.payloads];
        messageForPublish = [PNJSON JSONStringFrom:mergedData withError:&error];
        
        if (error) {
            NSDictionary *userInfo = PNErrorUserInfo(
                @"Request parameters error",
                @"Message merge with push notification payload did fail",
                @"Ensure that only JSON-compatible values used in message.",
                error
            );
            
            return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
        }
    }
    
    if (messageForPublish.length == 0) return [self missingParameterError:@"message" forObjectRequest:@"Request"];
    else self.preparedMessage = messageForPublish;

    if (self.metadata) {
        NSString *metadataForPublish = [PNJSON JSONStringFrom:self.metadata withError:&error];
        if (!error && metadataForPublish.length) self.preparedMetadata = [metadataForPublish copy];
        else if (error) {
            NSDictionary *userInfo = PNErrorUserInfo(
                @"Request parameters error",
                @"Metadata serialization did fail",
                @"Ensure that only JSON-compatible values used in 'metadata'.",
                error
            );

            return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
        }
    }

    return nil;
}


#pragma mark - Misc

- (NSDictionary<NSString *, id> *)mergedMessage:(id)message
                          withMobilePushPayload:(NSDictionary<NSString *, id> *)payloads {
    NSDictionary *originalMessage = message ?: @{};
    if (message && ![message isKindOfClass:[NSDictionary class]]) originalMessage = @{ @"pn_other": message };

    NSMutableDictionary *mergedMessage = [originalMessage mutableCopy];

    for (NSString *pushProviderType in payloads) {
        NSString *providerKey = pushProviderType;
        id payload = payloads[pushProviderType];

        if (![pushProviderType hasPrefix:@"pn_"]) {
            providerKey = [NSString stringWithFormat:@"pn_%@", pushProviderType];

            if ([pushProviderType isEqualToString:@"aps"]) {
                payload = @{pushProviderType:payload};
                providerKey = @"pn_apns";
            }
        }

        [mergedMessage setValue:payload forKey:providerKey];
    }
    
    return [mergedMessage copy];
}

- (NSString *)encryptedMessage:(NSString *)message error:(NSError **)error {
    NSString *encryptedMessage = message;
    NSData *JSONData = [message dataUsingEncoding:NSUTF8StringEncoding];
    PNResult<NSData *> *encryptionResult = [self.cryptoModule encryptData:JSONData];

    if (encryptionResult.isError) {
        *error = encryptionResult.error;
        encryptedMessage = nil;
    } else {
        NSString *base64 = [encryptionResult.data base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
        encryptedMessage = [PNJSON JSONStringFrom:base64 withError:error];
    }
    
    return encryptedMessage;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"replicate": @(self.shouldReplicate),
        @"store": @(self.shouldStore),
        @"channel": self.channel ?: @"missing",
        @"ttl": @(self.ttl)
    }];
    
    if (self.arbitraryQueryParameters) dictionary[@"arbitraryQueryParameters"] = self.arbitraryQueryParameters;
    if (self.customMessageType) dictionary[@"customMessageType"] = self.customMessageType;
    if (self.metadata) dictionary[@"metadata"] = self.metadata;
    if (self.message) dictionary[@"message"] = self.message;
    
    return dictionary;
}

#pragma mark -


@end
