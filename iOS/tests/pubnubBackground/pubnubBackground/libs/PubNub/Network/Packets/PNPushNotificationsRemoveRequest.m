//
//  PNPushNotificationsRemoveRequest.m
//  pubnub
//
//  This class allwo to build request which will remove
//  push notifications from all channels on which
//  they was enabled before.
//
//
//  Created by Sergey Mamontov on 05/10/13.
//
//

#import "PNPushNotificationsRemoveRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
#import "NSData+PNAdditions.h"
#import "PubNub+Protected.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub notification remove request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Private interface delcaration

@interface PNPushNotificationsRemoveRequest ()


#pragma mark - Properties

// Stores reference on stringified push notification token
@property (nonatomic, strong) NSString *pushToken;
@property (nonatomic, strong) NSData *devicePushToken;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNPushNotificationsRemoveRequest


#pragma mark Class methods

+ (PNPushNotificationsRemoveRequest *)requestWithDevicePushToken:(NSData *)pushToken {

    return [[self alloc] initWithDevicePushToken:pushToken];
}


#pragma mark - Instance methods

- (id)initWithDevicePushToken:(NSData *)pushToken {

    // Check whether initialization successful or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.devicePushToken = pushToken;
        self.pushToken = [[pushToken HEXPushToken] lowercaseString];
    }


    return self;
}

- (NSTimeInterval)timeout {

    return [PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout;
}

- (NSString *)callbackMethodName {

    return PNServiceResponseCallbacks.pushNotificationRemoveCallback;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v1/push/sub-key/%@/devices/%@/remove?callback=%@_%@&uuid=%@%@&pnsdk=%@",
                                      [[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
                                      self.pushToken, [self callbackMethodName], self.shortIdentifier, [PubNub escapedClientIdentifier],
                                      ([self authorizationField]?[NSString stringWithFormat:@"&%@", [self authorizationField]]:@""),
                                      [self clientInformationField]];
}

- (NSString *)debugResourcePath {

    NSMutableArray *resourcePathComponents = [[[self resourcePath] componentsSeparatedByString:@"/"] mutableCopy];
    [resourcePathComponents replaceObjectAtIndex:4 withObject:PNObfuscateString([[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString])];

    return [resourcePathComponents componentsJoinedByString:@"/"];
}

#pragma mark -


@end
