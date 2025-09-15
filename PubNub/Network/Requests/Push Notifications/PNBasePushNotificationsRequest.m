#import "PNBasePushNotificationsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNFunctions.h"
#import "PNHelpers.h"
#import "PNError.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General request for all `Push Notifications` API endpoints private extension.
@interface PNBasePushNotificationsRequest ()


#pragma mark - Properties

/// Normalized OS / library-provided device push token.
@property(copy, nonatomic) NSString *preparedPushToken;

/// One of **PNPushType** fields which specify provider to manage notifications for device specified with `pushToken`.
@property(assign, nonatomic) PNPushType pushType;

/// OS / library-provided device push token.
@property(copy, nonatomic) id pushToken;


#pragma mark - Initialization and Configuration

/// Initialize general `Push notifications` API access request.
///
/// - Parameters:
///   - pushToken: Device token / identifier which depending from passed `pushType` should be `NSData` (for
///   **PNAPNS2Push** and **PNAPNSPush**) or `NSString` for other.
///   - pushType: One of **PNPushType** fields which specify service to manage notifications for device specified with
///   `pushToken`.
/// - Returns: Initialized `push notifications` API access request.
- (instancetype)initWithDevicePushToken:(id)pushToken pushType:(PNPushType)pushType;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNBasePushNotificationsRequest


#pragma mark - Properties

- (NSString *)path {
    NSString *path = PNStringFormat(@"/%@/push/sub-key/%@/devices%@/%@",
                                    self.pushType != PNAPNS2Push ? @"v1" : @"v2",
                                    self.subscribeKey, 
                                    self.pushType != PNAPNS2Push ? @"" : @"-apns2",
                                    self.preparedPushToken);
    
    if (self.operation == PNRemoveAllPushNotificationsOperation ||
        self.operation == PNRemoveAllPushNotificationsV2Operation) {
        return [path stringByAppendingString:@"/remove"];
    }
    
    return path;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [NSMutableDictionary new];
    NSString *tokenType = @"apns";
    
    if (self.pushType == PNFCMPush) tokenType = @"gcm";
    else if (self.pushType == PNMPNSPush) tokenType = @"mpns";
    
    if (self.pushType == PNAPNS2Push) {
        NSString *environment = self.environment == PNAPNSDevelopment ? @"development" : @"production";
        NSString *topic = self.topic.length ? self.topic : NSBundle.mainBundle.bundleIdentifier;
        
        query[@"environment"] = environment;
        query[@"topic"] = topic;
    }
    
    query[@"type"] = tokenType;
    
    if (self.arbitraryQueryParameters.count) [query addEntriesFromDictionary:self.arbitraryQueryParameters];
    
    return query;
}


#pragma mark - Initialization & Configuration

+ (instancetype)requestWithDevicePushToken:(id)pushToken pushType:(PNPushType)pushType {
    return [[self alloc] initWithDevicePushToken:pushToken pushType:pushType];
}

- (instancetype)initWithDevicePushToken:(id)pushToken pushType:(PNPushType)pushType {
    if ((self = [super init])) {
        if ([pushToken isKindOfClass:[NSData class]] && (pushType == PNAPNSPush || pushType == PNAPNS2Push)) {
            _preparedPushToken = [PNData HEXFromDevicePushToken:pushToken].lowercaseString;
        } else _preparedPushToken = [pushToken copy];
        
        _pushToken = [pushToken copy];
        _pushType = pushType;
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];
    
    return nil;
}


#pragma mark - Prepare

- (PNError *)validate {
    NSDictionary *userInfo = nil;
    
    if (!self.pushToken ||
        ([self.pushToken isKindOfClass:[NSData class]] && !((NSData *)self.pushToken).length) ||
        ([self.pushToken isKindOfClass:[NSString class]] && !((NSString *)self.pushToken).length)) {
        
        userInfo = @{
            NSLocalizedDescriptionKey: @"Push Notifications API access request configuration error",
            NSLocalizedFailureReasonErrorKey: @"Device token / identifier is missing or empty"
        };
    } else if ((self.pushType == PNAPNSPush || self.pushType == PNAPNS2Push) &&
               ![self.pushToken isKindOfClass:[NSData class]]) {
        NSString *serviceName = self.pushType == PNAPNSPush ? @"APNS" : @"APNS over HTTP/2";
        
        userInfo = @{
            NSLocalizedDescriptionKey: @"Push Notifications API access request configuration error",
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"%@ expects device "
                                               "token / identifier to be instance of NSData, "
                                               "but got: %@",
                                               serviceName,
                                               NSStringFromClass([self.pushToken class])]
        };
    } else if (self.pushType != PNAPNSPush && self.pushType != PNAPNS2Push &&
               ![self.pushToken isKindOfClass:[NSString class]]) {
        userInfo = @{
            NSLocalizedDescriptionKey: @"Push Notifications API access request configuration error",
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"FCM / GCM / MPNS expects "
                                               "device token / identifier to be instance of "
                                               "NSString, but got: %@",
                                               NSStringFromClass([self.pushToken class])]
        };
    }
    
    if (userInfo) {
        return [PNError errorWithDomain:PNAPIErrorDomain code:PNAPIErrorUnacceptableParameters userInfo:userInfo];
    }
    
    return nil;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSString *pushType = @"apns";
    if (self.pushType == PNAPNS2Push) pushType = @"apns2";
    else if (self.pushType == PNFCMPush) pushType = @"fcm";
    else if (self.pushType == PNMPNSPush) pushType = @"mpns";
    
    NSString *pushToken = @"missing";
    if (self.pushToken) {
        if ([self.pushToken isKindOfClass:[NSData class]])
            pushToken = [PNData HEXFromDevicePushToken:self.pushToken].lowercaseString;
        else pushToken = self.pushToken;
    }
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"environment": self.environment == PNAPNSDevelopment ? @"development" : @"production",
        @"pushToken": pushToken,
        @"pushType": pushType
    }];
    
    if (self.arbitraryQueryParameters) dictionary[@"arbitraryQueryParameters"] = self.arbitraryQueryParameters;
    if (self.topic) dictionary[@"topic"] = self.topic;
    
    return dictionary;
}

#pragma mark -


@end
