#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


#pragma mark API group protocols

/**
 @brief      Protocol which describe push notification state audit data object structure.
 @discussion Contain information about channels, for which push notifications has been enabled
             earlier.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNPushNotificationStateData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Channels with active push notifications.
 
 @return List of channel names for which client enabled push notifications earlier.
 
 @since 4.0
 */
- (NSDictionary *)channels;

@end


/**
 @brief  Protocol which describe operation processing resulting object with typed with \c data field
         with corresponding data type.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNPushNotificationsStateAuditResult <PNResult>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Reference on service response data casted to required type.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNPushNotificationStateData> *data;

@end


#pragma mark - Types

/**
 @brief  Push notifications state modification completion block.
 
 @param status Reference on status instance which hold information about procesing results.
 
 @since 4.0
 */
typedef void(^PNPushNotificationsStateModificationCompletionBlock)(PNStatus<PNStatus> *status);

/**
 @brief  Push notifications state audit completion block.
 
 @param status Reference on status instance which hold information about procesing results.
 
 @since 4.0
 */
typedef void(^PNPushNotificationsStateAuditCompletionBlock)(PNResult<PNPushNotificationsStateAuditResult> *result,
                                                            PNStatus<PNStatus> *status);


#pragma mark - API group interface

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
                         andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block;

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
                              andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block;

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
                           andCompletion:(PNPushNotificationsStateModificationCompletionBlock)block;


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
                                  andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block;

#pragma mark -


@end
