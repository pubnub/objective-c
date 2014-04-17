//
//  PNPushNotificationHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 4/5/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface PNPushNotificationHelper : NSObject


#pragma mark - Properties

/**
 Stores whether helper should enable push notifications during request or not.
 */
@property (nonatomic, assign, getter = isEnablingPushNotifications) BOOL enablingPushNotifications;


#pragma mark - Instance methods

/**
 Add specified channel to the list which will be used for push notification state manipulation.
 
 @param channel
 \b PNChannel instance for which push notification state will be changed in future.
 */
- (void)addChannel:(PNChannel *)channel;

/**
 Remove concrete channel from list of channels for push notification state manipulation.
 
 @param channel
 \b PNChannel instance for which push notification state will be changed in future.
 */
- (void)removeChannel:(PNChannel *)channel;

/**
 Checking whether provided channel is in list for  push notification manipulation or not.
 
 @return \c YES if channel has been prevously added through \c -addChannel: method.
 */
- (BOOL)willChangePushNotificationStateForChanne:(PNChannel *)channel;

/**
 Retrieve list of channels which is available for push notification state manipulation.
 */
- (NSArray *)channels;

/**
 Check whether helper has all required data for push notification state modification or not.
 
 @return \c YES if there is at least one channel selected by user.
 */
- (BOOL)isAbleToChangePushNotificationState;

/**
 Ask \b PubNub service about list of channels for which push notification has been enabled.
 */
- (void)requestPushNotificationEnabledChannelsWithBlock:(void(^)(void))handlerBlock;

/**
 Perform channels push notification state manipulation.
 
 @param handlerBlock
 Block which will be called when process will be completed and pass two parameters: reference on list of channels and
 error (if request failed).
 */
- (void)performRequestWithBlock:(void(^)(NSArray *, PNError *))handlerBlock;

/**
 Reset all cached helper's data.
 */
- (void)reset;


#pragma mark -


@end
