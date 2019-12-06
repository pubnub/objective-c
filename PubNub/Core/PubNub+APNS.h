#import <Foundation/Foundation.h>
#import "PNRemoveAllPushNotificationsRequest.h"
#import "PNRemovePushNotificationsRequest.h"
#import "PNAPNSModificationAPICallBuilder.h"
#import "PNAuditPushNotificationsRequest.h"
#import "PNAddPushNotificationsRequest.h"
#import "PNAPNSAuditAPICallBuilder.h"
#import "PNNotificationsPayload.h"
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
 * @version 4.12.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
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
 *        // Push notifications successful enabled on passed channels.
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
 * @brief Enable push notifications (sent using legacy APNs, FCM or MPNS) on provided set of
 * \c channels.
 *
 * @code
 * [self.client addPushNotificationsOnChannels:@[@"wwdc",@"google.io"]
 *                         withDevicePushToken:self.devicePushToken
 *                                    pushType:PNAPNSPush
 *                               andCompletion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Push notifications successful enabled on passed channels.
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
 * @param pushToken Device token / identifier which depending from passed \c pushType should be
 *     \a NSData (for \b PNAPNS2Push and \b PNAPNSPush) or \a NSString for other.
 * @param pushType One of \b PNPushType fields which specify service to manage notifications for
 *     device specified with \c pushToken.
 * @param block \c Add \c notifications \c for \c channels request completion block.
 *
 * @since 4.12.0
 */
- (void)addPushNotificationsOnChannels:(NSArray<NSString *> *)channels
             withDevicePushToken:(id)pushToken
                        pushType:(PNPushType)pushType
                   andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(addPushNotificationsOnChannels(_:withDevicePushToken:pushType:andCompletion:));

/**
 * @brief Enable push notifications (sent using APNs over HTTP/2) on provided set of \c channels.
 *
 * @code
 * [self.client addPushNotificationsOnChannels:@[@"wwdc",@"google.io"]
 *                         withDevicePushToken:self.devicePushToken
 *                                    pushType:PNAPNS2Push
 *                                 environment:PNAPNSProduction
 *                                       topic:@"com.my-application.bundle"
 *                               andCompletion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Push notifications successful enabled on passed channels.
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
 * @param pushToken Device token / identifier which depending from passed \c pushType should be
 *     \a NSData (for \b PNAPNS2Push and \b PNAPNSPush) or \a NSString for other.
 * @param pushType One of \b PNPushType fields which specify service to manage notifications for
 *     device specified with \c pushToken.
 * @param environment One of \b PNAPNSEnvironment fields which specify environment within which
 *     device should manage list of channels with enabled notifications (works only if \c pushType
 *     set to \b PNAPNS2Push).
 * @param topic Notifications topic name (usually it is application's bundle identifier).
 * @param block \c Add \c notifications \c for \c channels request completion block.
 *
 * @since 4.12.0
 */
- (void)addPushNotificationsOnChannels:(NSArray<NSString *> *)channels
             withDevicePushToken:(id)pushToken
                        pushType:(PNPushType)pushType
                     environment:(PNAPNSEnvironment)environment
                           topic:(NSString *)topic
                   andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(addPushNotificationsOnChannels(_:withDevicePushToken:pushType:environment:topic:andCompletion:));

/**
 * @brief Disable push notifications on provided set of \c channels.
 *
 * @code
 * [self.client removePushNotificationsFromChannels:@[@"wwdc",@"google.io"]
 *                              withDevicePushToken:self.devicePushToken
 *                                    andCompletion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Push notification successfully disabled on passed channels.
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
 * @brief Disable push notifications (sent using legacy APNs, FCM or MPNS) on provided set of
 * \c channels.
 *
 * @code
 * [self.client removePushNotificationsFromChannels:@[@"wwdc",@"google.io"]
 *                              withDevicePushToken:self.devicePushToken
 *                                         pushType:PNAPNSPush
 *                                    andCompletion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Push notification successfully disabled on passed channels.
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
 * @param pushToken Device token / identifier which depending from passed \c pushType should be
 *     \a NSData (for \b PNAPNS2Push and \b PNAPNSPush) or \a NSString for other.
 * @param pushType One of \b PNPushType fields which specify service to manage notifications for
 *     device specified with \c pushToken.
 * @param block \c Remove \c notifications \c from \c channels request completion block.
 *
 * @since 4.12.0
 */
- (void)removePushNotificationsFromChannels:(NSArray<NSString *> *)channels
             withDevicePushToken:(id)pushToken
                        pushType:(PNPushType)pushType
                   andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(removePushNotificationsFromChannels(_:withDevicePushToken:pushType:andCompletion:));

/**
 * @brief Disable push notifications (sent using APNs over HTTP/2) on provided set of \c channels.
 *
 * @code
 * [self.client removePushNotificationsFromChannels:@[@"wwdc",@"google.io"]
 *                              withDevicePushToken:self.devicePushToken
 *                                         pushType:PNAPNS2Push
 *                                      environment:PNAPNSDevelopment
 *                                            topic:@"com.my-application.bundle"
 *                                    andCompletion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Push notification successfully disabled on passed channels.
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
 * @param pushToken Device token / identifier which depending from passed \c pushType should be
 *     \a NSData (for \b PNAPNS2Push and \b PNAPNSPush) or \a NSString for other.
 * @param pushType One of \b PNPushType fields which specify service to manage notifications for
 *     device specified with \c pushToken.
 * @param environment One of \b PNAPNSEnvironment fields which specify environment within which
 *     device should manage list of channels with enabled notifications (works only if \c pushType
 *     set to \b PNAPNS2Push).
 * @param topic Notifications topic name (usually it is application's bundle identifier).
 * @param block \c Remove \c notifications \c from \c channels request completion block.
 *
 * @since 4.12.0
 */
- (void)removePushNotificationsFromChannels:(NSArray<NSString *> *)channels
             withDevicePushToken:(id)pushToken
                        pushType:(PNPushType)pushType
                     environment:(PNAPNSEnvironment)environment
                           topic:(NSString *)topic
                   andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(removePushNotificationsFromChannels(_:withDevicePushToken:pushType:environment:topic:andCompletion:));

/**
 * @brief Disable push notifications from all channels which is registered with specified
 * \c pushToken.
 *
 * @code
 * [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.devicePushToken
 *                                                 andCompletion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Push notification successfully disabled for all channels associated with specified
 *        // device push token.
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

/**
 * @brief Disable push notifications (sent using legacy APNs, FCM or MPNS) from all channels which
 * is registered with specified \c pushToken.
 *
 * @code
 * [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.devicePushToken
 *                                                       pushType:PNAPNSPush
 *                                                  andCompletion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Push notification successfully disabled for all channels associated with specified
 *        // device push token.
 *     } else {
 *        // Handle modification error. Check 'category' property to find out possible issue because
 *        // of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param pushToken Device token / identifier which depending from passed \c pushType should be
 *     \a NSData (for \b PNAPNS2Push and \b PNAPNSPush) or \a NSString for other.
 * @param pushType One of \b PNPushType fields which specify service to manage notifications for
 *     device specified with \c pushToken.
 * @param block \c Remove \c all \c notifications request completion block.
 *
 * @since 4.12.0
 */
- (void)removeAllPushNotificationsFromDeviceWithPushToken:(id)pushToken
                        pushType:(PNPushType)pushType
                   andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(removeAllPushNotificationsFromDeviceWithPushToken(_:pushType:andCompletion:));

/**
 * @brief Disable push notifications (sent using APNs over HTTP/2) from all channels
 * which is registered with specified \c pushToken.
 *
 * @code
 * [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.devicePushToken
 *                                                      pushType:PNAPNS2Push
 *                                                   environment:PNAPNSDevelopment
 *                                                         topic:@"com.my-application.bundle"
 *                                                 andCompletion:^(PNAcknowledgmentStatus *status) {
 *
 *     if (!status.isError) {
 *        // Push notification successfully disabled for all channels associated with specified
 *        // device push token.
 *     } else {
 *        // Handle modification error. Check 'category' property to find out possible issue because
 *        // of which request did fail.
 *        //
 *        // Request can be resent using: [status retry];
 *     }
 * }];
 * @endcode
 *
 * @param pushToken Device token / identifier which depending from passed \c pushType should be
 *     \a NSData (for \b PNAPNS2Push and \b PNAPNSPush) or \a NSString for other.
 * @param pushType One of \b PNPushType fields which specify service to manage notifications for
 *     device specified with \c pushToken.
 * @param environment One of \b PNAPNSEnvironment fields which specify environment within which
 *     device should manage list of channels with enabled notifications (works only if \c pushType
 *     set to \b PNAPNS2Push).
 * @param topic Notifications topic name (usually it is application's bundle identifier).
 * @param block \c Remove \c all \c notifications request completion block.
 *
 * @since 4.12.0
 */
- (void)removeAllPushNotificationsFromDeviceWithPushToken:(id)pushToken
                        pushType:(PNPushType)pushType
                     environment:(PNAPNSEnvironment)environment
                           topic:(NSString *)topic
                   andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(removeAllPushNotificationsFromDeviceWithPushToken(_:pushType:environment:topic:andCompletion:));


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

/**
 * @brief Request for all channels on which push notification (sent using legacy APNs, FCM or MPNS)
 * has been enabled using specified \c pushToken.
 *
 * @code
 * [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:self.devicePushToken
 *                          pushType:PNAPNSPush
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
 * @param pushToken Device token / identifier which depending from passed \c pushType should be
 *     \a NSData (for \b PNAPNS2Push and \b PNAPNSPush) or \a NSString for other.
 * @param pushType One of \b PNPushType fields which specify service to manage notifications for
 *     device specified with \c pushToken.
 * @param block \c Audit \c notifications \c enabled \c channels request completion block.
 *
 * @since 4.12.0
 */
- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(id)pushToken
                                        pushType:(PNPushType)pushType
                                   andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block
    NS_SWIFT_NAME(pushNotificationEnabledChannelsForDeviceWithPushToken(_:pushType:andCompletion:));

/**
 * @brief Request for all channels on which push notification (sent using APNs over HTTP/2) has been
 * enabled using specified \c pushToken.
 *
 * @code
 * PNAuditPushNotificationsRequest *request = nil;
 * request = [PNAuditPushNotificationsRequest requestWithDevicePushToken:self.devicePushToken
 *                                                              pushType:PNAPNS2Push];
 * request.topic = @"com.my-application.bundle";
 * request.environment = PNAPNSProduction;
 *
 * [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:self.devicePushToken
 *                          pushType:PNAPNS2Push
 *                       environment:PNAPNSDevelopment
 *                             topic:@"com.my-application.bundle"
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
 * @param pushToken Device token / identifier which depending from passed \c pushType should be
 *     \a NSData (for \b PNAPNS2Push and \b PNAPNSPush) or \a NSString for other.
 * @param pushType One of \b PNPushType fields which specify service to manage notifications for
 *     device specified with \c pushToken.
 * @param environment One of \b PNAPNSEnvironment fields which specify environment within which
 *     device should manage list of channels with enabled notifications (works only if \c pushType
 *     set to \b PNAPNS2Push).
 * @param topic Notifications topic name (usually it is application's bundle identifier).
 * @param block \c Audit \c notifications \c enabled \c channels request completion block.
 *
 * @since 4.12.0
 */
- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(id)pushToken
                                        pushType:(PNPushType)pushType
                                     environment:(PNAPNSEnvironment)environment
                                           topic:(NSString *)topic
                                   andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block
    NS_SWIFT_NAME(pushNotificationEnabledChannelsForDeviceWithPushToken(_:pushType:environment:topic:andCompletion:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
