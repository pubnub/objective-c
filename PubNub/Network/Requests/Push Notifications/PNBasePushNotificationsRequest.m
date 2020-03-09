/**
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNBasePushNotificationsRequest.h"
#import "PNRequest+Private.h"
#import "PNErrorCodes.h"
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNBasePushNotificationsRequest ()


#pragma mark - Information

/**
 * @brief OS/library-provided device push token.
 */
@property (nonatomic, copy) id pushToken;

/**
 * @brief One of \b PNPushType fields which specify spervide to manage notifications for device
 * specified with \c pushToken.
 */
@property (nonatomic, assign) PNPushType pushType;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c push \c notifications API access request.
 *
 * @param pushToken Depending from passed \c pushType should be \a NSData (for \b PNAPNS2Push and
 *     \b PNAPNSPush) or \a NSString for other.
 * @param pushType One of \b PNPushType fields which specify spervide to manage notifications for
 *     device specified with \c pushToken.
 *
 * @return Initialized and ready to use \c push \c notifications API access request.
 */
- (instancetype)initWithDevicePushToken:(id)pushToken pushType:(PNPushType)pushType;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNBasePushNotificationsRequest


#pragma mark - Information

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];
    
    if (self.parametersError) {
        return parameters;
    }
    
    NSString *token = self.pushToken;
    NSString *tokenType = @"apns";
    
    if (self.pushType == PNAPNSPush || self.pushType == PNAPNS2Push) {
        token = [PNData HEXFromDevicePushToken:self.pushToken];
    }
    
    if (self.pushType == PNFCMPush) {
        tokenType = @"gcm";
    } else if (self.pushType == PNMPNSPush) {
        tokenType = @"mpns";
    }
    
    if (self.pushType == PNAPNS2Push) {
        NSString *environment = self.environment == PNAPNSDevelopment ? @"development" : @"production";
        NSString *topic = self.topic.length ? self.topic : NSBundle.mainBundle.bundleIdentifier;
        
        [parameters addQueryParameter:environment forFieldName:@"environment"];
        [parameters addQueryParameter:topic forFieldName:@"topic"];
    }
    
    [parameters addPathComponent:token.lowercaseString forPlaceholder:@"{token}"];
    [parameters addQueryParameter:tokenType forFieldName:@"type"];
    
    return parameters;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithDevicePushToken:(id)pushToken pushType:(PNPushType)pushType {
    return [[self alloc] initWithDevicePushToken:pushToken pushType:pushType];
}

- (instancetype)initWithDevicePushToken:(id)pushToken pushType:(PNPushType)pushType {
    if ((self = [super init])) {
        _pushToken = [pushToken copy];
        _pushType = pushType;
        
        NSDictionary *errorInformation = nil;
        
        if (!pushToken ||
            ([pushToken isKindOfClass:[NSData class]] && !((NSData *)pushToken).length) ||
            ([pushToken isKindOfClass:[NSString class]] && !((NSString *)pushToken).length)) {
            
            errorInformation = @{
                NSLocalizedDescriptionKey: @"Push Notifications API access request configuration error",
                NSLocalizedFailureReasonErrorKey: @"Device token / identifier is missing or empty"
            };
        } else if ((pushType == PNAPNSPush || pushType == PNAPNS2Push) &&
                   ![pushToken isKindOfClass:[NSData class]]) {
            NSString *serviceName = pushType == PNAPNSPush ? @"APNS" : @"APNS over HTTP/2";
            
            errorInformation = @{
                NSLocalizedDescriptionKey: @"Push Notifications API access request configuration error",
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"%@ expects device "
                                                   "token / identifier to be instance of NSData, "
                                                   "but got: %@",
                                                   serviceName,
                                                   NSStringFromClass([pushToken class])]
            };
        } else if (pushType != PNAPNSPush && pushType != PNAPNS2Push &&
                   ![pushToken isKindOfClass:[NSString class]]) {
            errorInformation = @{
                NSLocalizedDescriptionKey: @"Push Notifications API access request configuration error",
                NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"FCM / GCM / MPNS expects "
                                                   "device token / identifier to be instance of "
                                                   "NSString, but got: %@",
                                                   NSStringFromClass([pushToken class])]
            };
        }
        
        if (errorInformation) {
            self.parametersError = [NSError errorWithDomain:kPNAPIErrorDomain
                                                       code:kPNAPIUnacceptableParameters
                                                   userInfo:errorInformation];
        }
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}

#pragma mark -


@end
