//
//  PNPushNotificationsStateChangeRequest.m
//  pubnub
//
//  This request allow to change push notification
//  availability on channel(s) and depending on what
//  will be set, device will start receive push notifications
//  if there is new messages in channel(s).
//
//
//  Created by Sergey Mamontov on 05/10/13.
//
//

#import "PNPushNotificationsStateChangeRequest.h"
#import "PNServiceResponseCallbacks.h"
#import "PubNub+Protected.h"


#pragma mark Extenrs

struct PNPushNotificationsStateStruct PNPushNotificationsState = {

    .enable = @"add",
    .disable = @"remove"
};


#pragma mark - Private interfacde declaration

@interface PNPushNotificationsStateChangeRequest ()


#pragma mark - Properties

// Stores reference on list of channels on which client
// should change push notification state
@property (nonatomic, strong) NSArray *channels;

// Stores reference on stringified push notification token
@property (nonatomic, strong) NSString *pushToken;

// Stores reference on state which should be set for specified
// channel(s)
@property (nonatomic, strong) NSString *targetState;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNPushNotificationsStateChangeRequest


#pragma mark - Class methods

+ (PNPushNotificationsStateChangeRequest *)reqauestWithDevicePushToken:(NSData *)pushToken
                                                               toState:(NSString *)pushNotificationState
                                                            forChannel:(PNChannel *)channel {

    return [self reqauestWithDevicePushToken:pushToken toState:pushNotificationState forChannels:@[channel]];
}

+ (PNPushNotificationsStateChangeRequest *)reqauestWithDevicePushToken:(NSData *)pushToken
                                                               toState:(NSString *)pushNotificationState
                                                           forChannels:(NSArray *)channels {

    return [[self alloc] initWithToken:pushToken forChannels:channels state:pushNotificationState];
}


#pragma mark - Instance methods

- (id)initWithToken:(NSData *)pushToken forChannel:(PNChannel *)channel state:(NSString *)state {

    return [self initWithToken:pushToken forChannels:@[channel] state:state];
}

- (id)initWithToken:(NSData *)pushToken forChannels:(NSArray *)channels state:(NSString *)state {

    // Check whether initialization successfull or not
    if ((self = [super init])) {

        self.sendingByUserRequest = YES;
        self.channels = [NSArray arrayWithArray:channels];
        self.targetState = state;
        self.pushToken = [pushToken HEXPushToken];
    }


    return self;
}

- (NSTimeInterval)timeout {

    return [PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout;
}

- (NSString *)callbackMethodName {

    NSString *callbackMethodName = PNServiceResponseCallbacks.channelPushNotificationsEnableCallback;
    if ([self.targetState isEqualToString:PNPushNotificationsState.disable]) {

        callbackMethodName = PNServiceResponseCallbacks.channelPushNotificationsDisableCallback;
    }


    return callbackMethodName;
}

- (NSString *)resourcePath {

    // Compose state changing resource path based on desired push notifications
    // state for specified channel(s)
    NSString *resourcePathBase = [NSString stringWithFormat:@"/v1/push/sub-key/%@", [PubNub sharedInstance].configuration.subscriptionKey];
    if ([self.targetState isEqualToString:PNPushNotificationsState.enable]) {

        resourcePathBase = [resourcePathBase stringByAppendingString:@"/devices"];
    }


    return [NSString stringWithFormat:@"%@/%@?%@=%@&callback=%@_%@&uuid=%@",
            resourcePathBase,
            self.pushToken,
            self.targetState,
            [[self.channels valueForKey:@"escapedName"] componentsJoinedByString:@","],
            [self callbackMethodName],
            self.shortIdentifier,
            [PubNub escapedClientIdentifier]];
}

#pragma mark -


@end
