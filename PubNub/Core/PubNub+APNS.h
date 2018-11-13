#import <Foundation/Foundation.h>
#import "PNAPNSModificationAPICallBuilder.h"
#import "PNAPNSAuditAPICallBuilder.h"
#import "PNAPNSAPICallBuilder.h"
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNAPNSEnabledChannelsResult, PNAcknowledgmentStatus, PNErrorStatus;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - API group interface

/**
 * @brief \b PubNub client core class extension to provide access to 'APNS' API group.
 *
 * @discussion Set of API which allow to manage push notifications on separate channels. If push
 * notifications has been enabled on channels, then device will start receiving notifications while
 * device inactive.
 *
 * @author Serhii Mamontov
 * @since 4.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PubNub (APNS)


#pragma mark - API builder support

/**
 * @brief Push notification API access builder.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNAPNSAPICallBuilder * (^push)(void);


#pragma mark - Push notifications state manipulation

/**
 * @brief Enabled push notifications on provided set of \c channels.
 *
 * @code
 * [self.client addPushNotificationsOnChannels:@[@"wwdc",@"google.io"]
 *                         withDevicePushToken:self.devicePushToken
 *                               andCompletion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle successful push notification enabling on passed channels.
 *     } else {
 *        // Handle modification error. Check 'category' property to find out possible issue because
 *        // of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param channels List of channel names for which push notifications should be enabled.
 * @param pushToken Device push token which should be used to enabled push notifications on
 *     specified set of channels.
 * @param block Push notifications addition on channels completion block.
 *
 * @since 4.0
 */
- (void)addPushNotificationsOnChannels:(NSArray<NSString *> *)channels
             withDevicePushToken:(NSData *)pushToken
                   andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(addPushNotificationsOnChannels(_:withDevicePushToken:andCompletion:));

/**
 * @brief Disable push notifications on provided set of \c channels.
 *
 * @code
 * [self.client removePushNotificationsFromChannels:@[@"wwdc",@"google.io"]
 *                              withDevicePushToken:self.devicePushToken
 *                                    andCompletion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle successful push notification enabling on passed channels.
 *     } else {
 *        // Handle modification error. Check 'category' property to find out possible issue because
 *        // of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param channels List of channel names for which push notifications should be disabled.
 * @param pushToken Device push token which should be used to disable push notifications on
 *     specified set of channels.
 * @param block Push notifications removal from channels completion block.
 *
 * @since 4.0
 */
- (void)removePushNotificationsFromChannels:(NSArray<NSString *> *)channels
             withDevicePushToken:(NSData *)pushToken
                   andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(removePushNotificationsFromChannels(_:withDevicePushToken:andCompletion:));

/**
 * @brief Disable push notifications from all channels which is registered with specified
 * \c pushToken.
 *
 * @code
 * [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.devicePushToken
 *                                                 andCompletion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle successful push notification disabling for all channels associated with
 *        // specified device push token.
 *     } else {
 *        // Handle modification error. Check 'category' property to find out possible issue because
 *        // of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param pushToken Device push token which should be used to disable push notifications on
 *     specified set of channels.
 * @param block Push notifications removal from device completion block.
 *
 * @since 4.0
 */
- (void)removeAllPushNotificationsFromDeviceWithPushToken:(NSData *)pushToken
                   andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(removeAllPushNotificationsFromDeviceWithPushToken(_:andCompletion:));


#pragma mark - Push notifications state audit

/**
 * @brief Request for all channels on which push notification has been enabled using specified
 * \c pushToken.
 *
 * @code
 * [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:self.devicePushToken
 *                     andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
 *
 *     if (!status.isError) {
 *        // Handle downloaded list of channels using: result.data.channels
 *     } else {
 *        // Handle audition error. Check 'category' property to find out possible issue because of
 *        // which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param pushToken Device push token against which search on \b PubNub service should be performed.
 * @param block Push notifications status audition completion block.
 *
 * @since 4.0
 */
- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(NSData *)pushToken
                                   andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block
    NS_SWIFT_NAME(pushNotificationEnabledChannelsForDeviceWithPushToken(_:andCompletion:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
