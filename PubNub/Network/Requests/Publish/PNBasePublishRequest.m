/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNBasePublishRequest+Private.h"
#import "PNRequest+Private.h"
#import "PNMessageType.h"
#import "PNSpaceId.h"
#import "PNHelpers.h"
#import "PNAES.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNBasePublishRequest ()


#pragma mark - Information

/**
 * @brief Whether message should be encrypted using random initialization vector or not.
 *
 * @since 4.16.0
 */
@property (nonatomic, assign, getter = shouldUseRandomInitializationVector) BOOL useRandomInitializationVector;

/**
 * @brief Whether message should be replicated across the PubNub Real-Time Network and sent simultaneously to all subscribed
 * clients on a channel.
 */
@property (nonatomic, assign, getter = shouldReplicate) BOOL replicate;

/**
 * @brief Whether message should be compressed before sending or not.
 */
@property (nonatomic, assign, getter = shouldCompress) BOOL compress;

/**
 * @brief Dictionary with payloads for different vendors (Apple with "apns" key and Google with "gcm").
 */
@property (nonatomic, nullable, strong) NSDictionary *payloads;

/**
 * @brief Message which has been prepared for publish.
 *
 * @discussion Depending from request configuration this object may store encrypted message with mobile push payloads.
 */
@property (nonatomic, nullable, strong) id preparedMessage;

/**
 * @brief Key which should be used to encrypt message.
 */
@property (nonatomic, nullable, copy) NSString *cipherKey;

/**
 * @brief Publish request sequence number.
 */
@property (nonatomic, assign) NSUInteger sequenceNumber;

/**
 * @brief Name of channel to which message should be published.
 */
@property (nonatomic, copy) NSString *channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNBasePublishRequest


#pragma mark - Information

- (BOOL)returnsResponse {
    return NO;
}

- (NSString *)httpMethod {
    return self.shouldCompress ? @"POST" : @"GET";
}

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];

    if (self.parametersError) {
        return parameters;
    }

    if (self.channel.length) {
        [parameters addPathComponent:[PNString percentEscapedString:self.channel]
                      forPlaceholder:@"{channel}"];
    } else {
        self.parametersError = [self missingParameterError:@"channel" forObjectRequest:@"Request"];
    }
    
    
    if (!self.shouldStore) {
        [parameters addQueryParameter:@"0" forFieldName:@"store"];
    }
    
    if (self.ttl > 0) {
        [parameters addQueryParameter:@(self.ttl).stringValue forFieldName:@"ttl"];
    }
    
    if (!self.shouldReplicate) {
        [parameters addQueryParameter:@"true" forFieldName:@"norep"];
    }

    if (self.spaceId) {
        [parameters addQueryParameter:self.spaceId.value forFieldName:@"space-id"];
    }

    if (self.messageType) {
        [parameters addQueryParameter:self.messageType.value forFieldName:@"type"];
    }
    
    parameters.POSTBodyCompressed = self.shouldCompress;
    
    NSString *messageForPublish = @"";
    messageForPublish = [self JSONFromMessage:self.preFormattedMessage
                 withPushNotificationsPayload:self.payloads];
    
    if (!self.parametersError && !messageForPublish.length) {
        self.parametersError = [self missingParameterError:@"message" forObjectRequest:@"Request"];
    }
    
    if (!self.parametersError) {
        if (!self.shouldCompress) {
            messageForPublish = [PNString percentEscapedString:messageForPublish];
        } else {
            messageForPublish = @"";
        }
        
        [parameters addPathComponent:messageForPublish forPlaceholder:@"{message}"];
    }
    
    if (self.metadata) {
        NSError *parametersError = nil;
        NSString *metadataForPublish = [PNJSON JSONStringFrom:self.metadata
                                                    withError:&parametersError];
        
        if (!parametersError && metadataForPublish.length) {
            [parameters addQueryParameter:[PNString percentEscapedString:metadataForPublish]
                             forFieldName:@"meta"];
        } else if (parametersError) {
            self.parametersError = parametersError;
        }
    }
    
    [parameters addQueryParameter:@(self.sequenceNumber).stringValue forFieldName:@"seqn"];

    return parameters;
}

- (NSData *)bodyData {
    NSString *messageForPublish = [self JSONFromMessage:self.preFormattedMessage
                           withPushNotificationsPayload:self.payloads];
    
    if (self.parametersError) {
        return nil;
    }

    NSData *messageData = [messageForPublish dataUsingEncoding:NSUTF8StringEncoding];

    return [PNGZIP GZIPDeflatedData:messageData] ?: [@"" dataUsingEncoding:NSUTF8StringEncoding];
}

- (id)preFormattedMessage {
    return self.message;
}


#pragma mark - Initialization & Configuration

-  (instancetype)initWithChannel:(NSString *)channel {
    if ((self = [super init])) {
        _channel = [channel copy];
        self.replicate = YES;
        self.store = YES;
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}


#pragma mark - Misc

- (NSString *)JSONFromMessage:(id)message withPushNotificationsPayload:(NSDictionary *)payloads {
    if (self.preparedMessage) {
        return self.preparedMessage;
    }
    
    NSError *parametersError = nil;
    NSString *messageForPublish = [PNJSON JSONStringFrom:message withError:&parametersError];
    BOOL isMessageEncrypted = NO;

    if (!parametersError && self.cipherKey.length) {
        NSString *encryptedMessage = [self encryptedMessage:messageForPublish
                                              withCipherKey:self.cipherKey
                                 randomInitializationVector:self.shouldUseRandomInitializationVector
                                                      error:&parametersError];
        
        if (!parametersError) {
            messageForPublish = [encryptedMessage copy];
            isMessageEncrypted = YES;
        } else {
            messageForPublish = nil;
        }
    }
    
    if (!parametersError && payloads.count) {
        id targetMessage = isMessageEncrypted ? messageForPublish : message;
        NSDictionary *mergedData = [self mergedMessage:targetMessage withMobilePushPayload:payloads];
        messageForPublish = [PNJSON JSONStringFrom:mergedData withError:&parametersError];
    }
    
    if (parametersError) {
        self.parametersError = parametersError;
    }
    
    self.preparedMessage = messageForPublish;
    
    return messageForPublish;
}


- (NSDictionary<NSString *, id> *)mergedMessage:(id)message
                          withMobilePushPayload:(NSDictionary<NSString *, id> *)payloads {

    NSDictionary *originalMessage = message ?: @{};
    
    if (message && ![message isKindOfClass:[NSDictionary class]]) {
        originalMessage = @{ @"pn_other": message };
    }

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

- (NSString *)encryptedMessage:(NSString *)message
                 withCipherKey:(NSString *)key
    randomInitializationVector:(BOOL)randomIV
                         error:(NSError **)error {
    
    NSString *encryptedMessage = message;

    if (key.length) {
        NSData *JSONData = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSString *JSONString = [PNAES encrypt:JSONData
                                 withRandomIV:randomIV
                                    cipherKey:key
                                     andError:error];

        if (*error == nil) {
            /**
             * PNAES encryption output is NSString which is valid JSON object from PubNub service perspective, but it should be
             * decorated with " (this done internally by helper when it need to create JSON string).
             */
            encryptedMessage = [PNJSON JSONStringFrom:JSONString withError:error];
        } else {
            encryptedMessage = nil;
        }
    }
    
    return encryptedMessage;
}

#pragma mark -


@end
