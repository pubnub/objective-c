#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


/**
 @brief      \b PubNub client core class extension to provide access to 'APNS' API group.
 @discussion Set of API which allow to manage push notifications on separate channels.
             If push notifications has been enabled on channels, then device will start receiving 
             notifications while device inactive.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PubNub (APNS)


///------------------------------------------------
/// @name Push notifications state manipulation
///------------------------------------------------

/**
 @brief  Enabled push notifications on provided set of \c channels.
 
 @param channels  List of channel names for which push notifications should be enabled.
 @param pushToken Device push token which should be used to enabled push notifications on specified
                  set of channels.
 @param block     Push notifications addition on channels processing completion block which pass 
                  only one argument - request processing status to report about how data pushing
                  was successful or not.
 
 @since 4.0
 */
- (void)addPushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken
                         andCompletion:(PNStatusBlock)block;

/**
 @brief   Disable push notifications on provided set of \c channels.
 @warning If \c nil will be passed as \c channels then client will remove push notifications from 
          all channels which associated with \c pushToken.
 
 @param channels  List of channel names for which push notifications should be disabled.
 @param pushToken Device push token which should be used to disable push notifications on specified
                  set of channels.
 @param block     Push notifications removal from channels processing completion block which pass 
                  only one argument - request processing status to report about how data pushing
                  was successful or not.
 
 @since 4.0
 */
- (void)removePushNotificationsFromChannels:(NSArray *)channels
                        withDevicePushToken:(NSData *)pushToken
                              andCompletion:(PNStatusBlock)block;

/**
 @brief  Disable push notifications from all channels which is registered with specified 
         \c pushToken.
 
 @param pushToken Device push token which should be used to disable push notifications on specified
                  set of channels.
 @param block     Push notifications removal from device processing completion block which pass only
                  one argument - request processing status to report about how data pushing was 
                  successful or not.
 
 @since 4.0
 */
- (void)removeAllPushNotificationsFromDeviceWithPushToken:(NSData *)pushToken
                                            andCompletion:(PNStatusBlock)block;


///------------------------------------------------
/// @name Push notifications state audit
///------------------------------------------------

/**
 @brief  Request for all channels on which push notification has been enabled using specified
         \c pushToken.
 
 @param pushToken Device push token against which search on \b PubNub service should be performed.
 @param block     Push notifications status processing completion block which pass two arguments:
                  \c result - in case of successful request processing \c data field will contain
                  results of push notifications audit operation; \c status - in case if error
                  occurred during request processing.
 
 @since 4.0
 */
- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(NSData *)pushToken
                                                andCompletion:(PNCompletionBlock)block;

#pragma mark -


@end
