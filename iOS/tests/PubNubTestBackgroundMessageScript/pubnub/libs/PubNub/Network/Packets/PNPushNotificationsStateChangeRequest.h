//
//  PNPushNotificationsStateChangeRequest.h
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

#import "PNBaseRequest.h"


#pragma mark Structures

struct PNPushNotificationsStateStruct {

    __unsafe_unretained NSString *enable;
    __unsafe_unretained NSString *disable;
};

extern struct PNPushNotificationsStateStruct PNPushNotificationsState;


#pragma mark - Class forward

@class PNChannel;


@interface PNPushNotificationsStateChangeRequest : PNBaseRequest


#pragma mark - Properties

// Stores reference on list of channels on which client
// should change push notification state
@property (nonatomic, readonly, strong) NSArray *channels;

// Stores reference on stringified push notification token
@property (nonatomic, readonly, strong) NSData *devicePushToken;

// Stores reference on state which should be set for specified
// channel(s)
@property (nonatomic, readonly, strong) NSString *targetState;


#pragma mark - Class methods

/**
 * pushNotificationState should be one of the PNPushNotificationsStateStruct fields
 */
+ (PNPushNotificationsStateChangeRequest *)requestWithDevicePushToken:(NSData *)pushToken
                                                              toState:(NSString *)pushNotificationState
                                                           forChannel:(PNChannel *)channel;
+ (PNPushNotificationsStateChangeRequest *)requestWithDevicePushToken:(NSData *)pushToken
                                                              toState:(NSString *)pushNotificationState
                                                          forChannels:(NSArray *)channels;


#pragma mark - Instance methods

/**
 * pushNotificationState should be one of the PNPushNotificationsStateStruct fields
 */
- (id)initWithToken:(NSData *)pushToken forChannel:(PNChannel *)channel state:(NSString *)state;
- (id)initWithToken:(NSData *)pushToken forChannels:(NSArray *)channels state:(NSString *)state;

#pragma mark -


@end
