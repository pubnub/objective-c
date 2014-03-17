//
//  PNPushNotificationsEnabledChannelsRequest.m
//  pubnub
//
//  This class allow to create request which will
//  retrieve list of channels on which push notifications
//  eas enabled.
//
//
//  Created by Sergey Mamontov on 05/10/13.
//
//

#import "PNPushNotificationsEnabledChannelsRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PubNub+Protected.h"
#import "PNBaseRequest+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub notification enabled channels request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface declaration

@interface PNPushNotificationsEnabledChannelsRequest ()


#pragma mark - Properties

// Stores reference on stringified push notification token
@property (nonatomic, strong) NSString *pushToken;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNPushNotificationsEnabledChannelsRequest


#pragma mark - Class methods

+ (PNPushNotificationsEnabledChannelsRequest *)requestWithDevicePushToken:(NSData *)pushToken {

    return [[self alloc] initWithDevicePushToken:pushToken];
}


#pragma mark - Instance methods

- (id)initWithDevicePushToken:(NSData *)pushToken {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.pushToken = [[pushToken HEXPushToken] lowercaseString];
    }


    return self;
}

- (NSTimeInterval)timeout {

    return [PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.pushNotificationEnabledChannelsCallback;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v1/push/sub-key/%@/devices/%@?callback=%@_%@&uuid=%@%@",
                                      [[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
                                      self.pushToken,
                                      [self callbackMethodName],
                                      self.shortIdentifier,
                                      [PubNub escapedClientIdentifier],
                                      ([self authorizationField]?[NSString stringWithFormat:@"&%@", [self authorizationField]]:@"")];
}

- (NSString *)debugResourcePath {

    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:4 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString])];

    return [resourcePathComponents componentsJoinedByString:@"/"];
}

#pragma mark -


@end
