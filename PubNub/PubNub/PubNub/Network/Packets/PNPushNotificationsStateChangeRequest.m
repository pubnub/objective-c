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
#import "PNBaseRequest+Protected.h"
#import "NSString+PNAddition.h"
#import "NSData+PNAdditions.h"
#import "PNConfiguration.h"
#import "PNMacro.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub notification state changing request must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


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
@property (nonatomic, strong) NSData *devicePushToken;

// Stores reference on state which should be set for specified
// channel(s)
@property (nonatomic, strong) NSString *targetState;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation PNPushNotificationsStateChangeRequest


#pragma mark - Class methods

+ (PNPushNotificationsStateChangeRequest *)requestWithDevicePushToken:(NSData *)pushToken
                                                              toState:(NSString *)pushNotificationState
                                                           forChannel:(PNChannel *)channel {

    return [self requestWithDevicePushToken:pushToken toState:pushNotificationState forChannels:@[channel]];
}

+ (PNPushNotificationsStateChangeRequest *)requestWithDevicePushToken:(NSData *)pushToken
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
        self.devicePushToken = pushToken;
        self.pushToken = [[pushToken pn_HEXPushToken] lowercaseString];
    }


    return self;
}

- (void)finalizeWithConfiguration:(PNConfiguration *)configuration clientIdentifier:(NSString *)clientIdentifier {
    
    [super finalizeWithConfiguration:configuration clientIdentifier:clientIdentifier];
    
    self.subscriptionKey = configuration.subscriptionKey;
    self.clientIdentifier = clientIdentifier;
}

- (NSString *)callbackMethodName {

    NSString *callbackMethodName = PNServiceResponseCallbacks.channelPushNotificationsEnableCallback;
    if ([self.targetState isEqualToString:PNPushNotificationsState.disable]) {

        callbackMethodName = PNServiceResponseCallbacks.channelPushNotificationsDisableCallback;
    }


    return callbackMethodName;
}

- (NSString *)resourcePath {

    return [NSString stringWithFormat:@"/v1/push/sub-key/%@/devices/%@?%@=%@&callback=%@_%@&uuid=%@%@&pnsdk=%@",
                                      [self.subscriptionKey pn_percentEscapedString],
                                      self.pushToken, self.targetState, [[self.channels valueForKey:@"escapedName"] componentsJoinedByString:@","],
                                      [self callbackMethodName], self.shortIdentifier,
                                      [self.clientIdentifier stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                      ([self authorizationField] ? [NSString stringWithFormat:@"&%@", [self authorizationField]] : @""),
                                      [self clientInformationField]];
}

- (NSString *)debugResourcePath {
    
    NSString *subscriptionKey = [self.subscriptionKey pn_percentEscapedString];
    return [[self resourcePath] stringByReplacingOccurrencesOfString:subscriptionKey withString:PNObfuscateString(subscriptionKey)];
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<%@|%@>", NSStringFromClass([self class]), [self debugResourcePath]];
}

#pragma mark -


@end
