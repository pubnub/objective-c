#import <PubNub/PubNub+Core.h>

// Request
#import <PubNub/PNPushNotificationManageRequest.h>
#import <PubNub/PNPushNotificationFetchRequest.h>

// Response
#import <PubNub/PNAPNSEnabledChannelsResult.h>
#import <PubNub/PNNotificationsPayload.h>

// Deprecated
#import <PubNub/PNAPNSModificationAPICallBuilder.h>
#import <PubNub/PNAPNSAuditAPICallBuilder.h>
#import <PubNub/PNAPNSAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface implementation

/// **PubNub** `Push Notification` APIs.
///
/// A set of APIs which allow fetching and managing a list of channels with push notifications enabled for the device.
@interface PubNub (APNS)


#pragma mark - Push notification API builder interdace (deprecated)

/// Push notification API access builder.
@property (nonatomic, readonly, strong) PNAPNSAPICallBuilder * (^push)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");


#pragma mark - Push notifications state manipulation

/// Manage notifications for device.
///
/// Depending from used request it is possible to change channel notifications avaiability for device or disable all
/// notifications for device.
///
/// #### Examples:
/// ##### Enable notification for channels:
/// ```objc
/// NSData *deviceToken = [NSData new]; // For FCM it should be string token.
/// NSArray<NSString *> *channels = @[@"channel-a", @"channel-b"];
/// PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:channels
///                                                                                toDeviceWithToken:deviceToken
///                                                                                         pushType:PNAPNS2Push];
///
/// [self.client managePushNotificationWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Push notifications successful enabled on passed channels.
///     } else {
///         // Handle modification error. Check `category` property to find out possible issue because of which request
///         // did fail.
///     }
/// }];
/// ```
///
/// ##### Disable notification for channels:
/// ```objc
/// NSData *deviceToken = [NSData new]; // For FCM it should be string token.
/// NSArray<NSString *> *channels = @[@"channel-a", @"channel-b"];
/// PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToRemoveChannels:channels
///                                                                                 fromDeviceWithToken:deviceToken
///                                                                                            pushType:PNAPNS2Push];
///
/// [self.client managePushNotificationWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Push notification successfully disabled on passed channels.
///     } else {
///         // Handle modification error. Check `category` property to find out possible issue because of which request
///         // did fail.
///     }
/// }];
/// ```
///
/// ##### Disable device notifications:
/// ```objc
/// NSData *deviceToken = [NSData new]; // For FCM it should be string token.
/// NSArray<NSString *> *channels = @[@"channel-a", @"channel-b"];
/// PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToRemoveDeviceWithToken:deviceToken
///                                                                                                   pushType:PNAPNS2Push];
///
/// [self.client managePushNotificationWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Push notification successfully disabled for all channels associated with specified device push token.
///     } else {
///         // Handle modification error. Check `category` property to find out possible issue because of which request
///         // did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information required to manage push notification enabled channels for device.
///   - block: Push notification enabled channels modification request completion block.
- (void)managePushNotificationWithRequest:(PNPushNotificationManageRequest *)request
                               completion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(managePushNotificationWithRequest(_:completion:));

/// Enabled push notifications on provided set of `channels`.
///
/// #### Example:
/// ```objc
/// [self.client addPushNotificationsOnChannels:@[@"wwdc",@"google.io"]
///                         withDevicePushToken:self.devicePushToken
///                               andCompletion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Push notifications successful enabled on passed channels.
///     } else {
///         // Handle modification error. Check `category` property to find out possible issue because of which request
///         // did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channels: List of channel names for which push notifications should be enabled.
///   - pushToken: Device push token which should be used to enabled push notifications on specified set of channels.
///   - block: Push notifications addition on channels completion block.
- (void)addPushNotificationsOnChannels:(NSArray<NSString *> *)channels
                   withDevicePushToken:(NSData *)pushToken
                         andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(addPushNotificationsOnChannels(_:withDevicePushToken:andCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-managePushNotificationWithRequest:completion:' method instead.");

/// Enable push notifications (sent using legacy APNs, FCM or MPNS) on provided set of `channels`.
///
/// #### Example:
/// ```objc
/// [self.client addPushNotificationsOnChannels:@[@"wwdc",@"google.io"]
///                         withDevicePushToken:self.devicePushToken
///                                    pushType:PNAPNSPush
///                               andCompletion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Push notifications successful enabled on passed channels.
///     } else {
///         // Handle modification error. Check `category` property to find out possible issue because of which request
///         // did fail.
///         //
///         // Request can be resent using: `[status retry];`
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channels: List of channel names for which push notifications should be enabled.
///   - pushToken: Device token / identifier which depending from passed `pushType` should be `NSData` (for
///   **PNAPNS2Push** and **PNAPNSPush**) or `NSString` for other.
///   - pushType: One of **PNPushType** fields which specify service to manage notifications for device specified with
///   `pushToken`.
///   - block: Push notifications addition on channels completion block.
- (void)addPushNotificationsOnChannels:(NSArray<NSString *> *)channels
                   withDevicePushToken:(id)pushToken
                              pushType:(PNPushType)pushType
                         andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(addPushNotificationsOnChannels(_:withDevicePushToken:pushType:andCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-managePushNotificationWithRequest:completion:' method instead.");

/// Enable push notifications (sent using APNs over HTTP/2) on provided set of `channels`.
///
/// #### Example:
/// ```objc
/// [self.client addPushNotificationsOnChannels:@[@"wwdc",@"google.io"]
///                         withDevicePushToken:self.devicePushToken
///                                    pushType:PNAPNS2Push
///                                 environment:PNAPNSProduction
///                                       topic:@"com.my-application.bundle"
///                               andCompletion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Push notifications successful enabled on passed channels.
///     } else {
///         // Handle modification error. Check `category` property to find out possible issue because of which request
///         // did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channels: List of channel names for which push notifications should be enabled.
///   - pushToken: Device token / identifier which depending from passed `pushType` should be `NSData` (for 
///   **PNAPNS2Push** and **PNAPNSPush**) or `NSString` for other.
///   - pushType: One of **PNPushType** fields which specify service to manage notifications for device specified with
///   `pushToken`.
///   - environment: One of **PNAPNSEnvironment** fields which specify environment within which device should manage
///   list of channels with enabled notifications (works only if `pushType` set to **PNAPNS2Push**).
///   - topic: Notifications topic name (usually it is application's bundle identifier).
///   - block: Push notifications addition on channels completion block.
- (void)addPushNotificationsOnChannels:(NSArray<NSString *> *)channels
                   withDevicePushToken:(id)pushToken
                              pushType:(PNPushType)pushType
                           environment:(PNAPNSEnvironment)environment
                                 topic:(NSString *)topic
                         andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(addPushNotificationsOnChannels(_:withDevicePushToken:pushType:environment:topic:andCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-managePushNotificationWithRequest:completion:' method instead.");

/// Disable push notifications on provided set of `channels`.
///
/// #### Example:
/// ```objc
/// [self.client removePushNotificationsFromChannels:@[@"wwdc",@"google.io"]
///                              withDevicePushToken:self.devicePushToken
///                                    andCompletion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Push notification successfully disabled on passed channels.
///     } else {
///         // Handle modification error. Check `category` property to find out possible issue because
///         // of which request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channels: List of channel names for which push notifications should be disabled.
///   - pushToken: Device push token which should be used to disable push notifications on specified set of channels.
///   - block: Push notifications removal from channels completion block.
- (void)removePushNotificationsFromChannels:(NSArray<NSString *> *)channels
                        withDevicePushToken:(NSData *)pushToken
                              andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(removePushNotificationsFromChannels(_:withDevicePushToken:andCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-managePushNotificationWithRequest:completion:' method instead.");

/// Disable push notifications (sent using legacy APNs, FCM or MPNS) on provided set of `channels`.
///
/// #### Example:
/// ```objc 
/// [self.client removePushNotificationsFromChannels:@[@"wwdc",@"google.io"]
///                              withDevicePushToken:self.devicePushToken
///                                         pushType:PNAPNSPush
///                                    andCompletion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Push notification successfully disabled on passed channels.
///     } else {
///         // Handle modification error. Check `category` property to find out possible issue because of which request
///         // did fail.
///         //
///         // Request can be resent using: `[status retry];`
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channels: List of channel names for which push notifications should be disabled.
///   - pushToken: Device token / identifier which depending from passed `pushType` should be `NSData` (for
///   **PNAPNS2Push** and **PNAPNSPush**) or `NSString` for other.
///   - pushType: One of **PNPushType** fields which specify service to manage notifications for device specified with
///   `pushToken`.
///   - block: Push notifications removal from channels completion block.
- (void)removePushNotificationsFromChannels:(NSArray<NSString *> *)channels
                        withDevicePushToken:(id)pushToken
                                   pushType:(PNPushType)pushType
                              andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(removePushNotificationsFromChannels(_:withDevicePushToken:pushType:andCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-managePushNotificationWithRequest:completion:' method instead.");

/// Disable push notifications (sent using APNs over HTTP/2) on provided set of `channels`.
///
/// #### Example:
/// ```objc
/// [self.client removePushNotificationsFromChannels:@[@"wwdc",@"google.io"]
///                              withDevicePushToken:self.devicePushToken
///                                         pushType:PNAPNS2Push
///                                      environment:PNAPNSDevelopment
///                                            topic:@"com.my-application.bundle"
///                                    andCompletion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Push notification successfully disabled on passed channels.
///     } else {
///         // Handle modification error. Check `category` property to find out possible issue because of which request
///         // did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channels: List of channel names for which push notifications should be disabled.
///   - pushToken: Device token / identifier which depending from passed `pushType` should be `NSData` (for
///   **PNAPNS2Push** and **PNAPNSPush**) or `NSString` for other.
///   - pushType: One of **PNPushType** fields which specify service to manage notifications for device specified with
///   `pushToken`.
///   - environment: One of **PNAPNSEnvironment** fields which specify environment within which device should manage
///   list of channels with enabled notifications (works only if `pushType` set to **PNAPNS2Push**).
///   - topic: Notifications topic name (usually it is application's bundle identifier).
///   - block: Push notifications removal from channels completion block.
- (void)removePushNotificationsFromChannels:(NSArray<NSString *> *)channels
                        withDevicePushToken:(id)pushToken
                                   pushType:(PNPushType)pushType
                                environment:(PNAPNSEnvironment)environment
                           topic:(NSString *)topic
                              andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(removePushNotificationsFromChannels(_:withDevicePushToken:pushType:environment:topic:andCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-managePushNotificationWithRequest:completion:' method instead.");

/// Disable push notifications from all channels which is registered with specified`pushToken`.
///
/// #### Example:
/// ```objc
/// [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.devicePushToken
///                                                 andCompletion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Push notification successfully disabled for all channels associated with specified device push token.
///     } else {
///         // Handle modification error. Check `category` property to find out possible issue because of which request
///         // did fail.
///         //
///         // Request can be resent using: `[status retry];`
///     }
/// }];
/// ```
///
/// - Parameters:
///   - pushToken: Device push token which should be used to disable push notifications on specified set of channels.
///   - block: Push notifications removal from device completion block.
- (void)removeAllPushNotificationsFromDeviceWithPushToken:(NSData *)pushToken
                                            andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(removeAllPushNotificationsFromDeviceWithPushToken(_:andCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-managePushNotificationWithRequest:completion:' method instead.");

/// Disable push notifications (sent using legacy APNs, FCM or MPNS) from all channels which is registered with
/// specified `pushToken`.
///
/// #### Example:
/// ```objc 
/// [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.devicePushToken
///                                                       pushType:PNAPNSPush
///                                                  andCompletion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Push notification successfully disabled for all channels associated with specified device push token.
///     } else {
///         // Handle modification error. Check `category` property to find out possible issue because of which request
///         // did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - pushToken: Device token / identifier which depending from passed `pushType` should be `NSData` (for
///   **PNAPNS2Push** and **PNAPNSPush**) or `NSString` for other.
///   - pushType: One of **PNPushType** fields which specify service to manage notifications for device specified with
///   `pushToken`.
///   - block: Push notifications removal from device completion block.
- (void)removeAllPushNotificationsFromDeviceWithPushToken:(id)pushToken
                                                 pushType:(PNPushType)pushType
                                            andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(removeAllPushNotificationsFromDeviceWithPushToken(_:pushType:andCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-managePushNotificationWithRequest:completion:' method instead.");

/// Disable push notifications (sent using APNs over HTTP/2) from all channels which is registered with specified
/// `pushToken`.
///
/// #### Example:
/// ```objc
/// [self.client removeAllPushNotificationsFromDeviceWithPushToken:self.devicePushToken
///                                                      pushType:PNAPNS2Push
///                                                   environment:PNAPNSDevelopment
///                                                         topic:@"com.my-application.bundle"
///                                                 andCompletion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Push notification successfully disabled for all channels associated with specified device push token.
///     } else {
///         // Handle modification error. Check `category` property to find out possible issue because of which request
///         // did fail.
///         //
///         // Request can be resent using: `[status retry];`
///     }
/// }];
/// ```
///
/// - Parameters:
///   - pushToken: Device token / identifier which depending from passed `pushType` should be \a `NSData` (for
///   **PNAPNS2Push** and **PNAPNSPush**) or `NSString` for other.
///   - pushType: One of **PNPushType** fields which specify service to manage notifications for device specified with
///   `pushToken`.
///   - environment: One of **PNAPNSEnvironment** fields which specify environment within which device should manage
///   list of channels with enabled notifications (works only if `pushType` set to **PNAPNS2Push**).
///   - topic: Notifications topic name (usually it is application's bundle identifier).
///   - block: Push notifications removal from device completion block.
- (void)removeAllPushNotificationsFromDeviceWithPushToken:(id)pushToken
                                                 pushType:(PNPushType)pushType
                                              environment:(PNAPNSEnvironment)environment
                                                    topic:(NSString *)topic
                                            andCompletion:(nullable PNPushNotificationsStateModificationCompletionBlock)block
    NS_SWIFT_NAME(removeAllPushNotificationsFromDeviceWithPushToken(_:pushType:environment:topic:andCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-managePushNotificationWithRequest:completion:' method instead.");


#pragma mark - Push notifications state audit

/// List notification enabled channels for device.
///
/// Depending from used request it is possible to change channel notifications avaiability for device or disable all
/// notifications for device.
///
/// #### Example:
/// ```objc
/// NSData *deviceToken = [NSData new]; // For FCM it should be string token.
/// PNPushNotificationFetchRequest *request = [PNPushNotificationFetchRequest requestWithDevicePushToken:deviceToken
///                                                                                               pushType:PNAPNS2Push];
///
/// [self.client fetchPushNotificationWithRequest:request completion:^(PNAcknowledgmentStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded list of channels using: `result.data.channels`.
///     } else {
///         // Handle audition error. Check `category` property to find out possible issue because of which request did
///         // fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information about device for which push notification enabled channels list should be
///   retrieved.
///   - block: Push notification enabled channels retrieve request completion block.   
- (void)fetchPushNotificationWithRequest:(PNPushNotificationFetchRequest *)request
                              completion:(PNPushNotificationsStateAuditCompletionBlock)block
    NS_SWIFT_NAME(fetchPushNotificationWithRequest(_:completion:));

/// Request for all channels on which push notification has been enabled using specified `pushToken`.
///
/// #### Example:
/// ```objc
/// [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:self.devicePushToken
///                                           completion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded list of channels using: `result.data.channels`.
///     } else {
///         // Handle audition error. Check `category` property to find out possible issue because of which request did
///         // fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - pushToken: Device push token against which search on **PubNub** service should be performed.
///   - block: Push notifications status audition completion block.
- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(NSData *)pushToken
                                                andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block
    NS_SWIFT_NAME(pushNotificationEnabledChannelsForDeviceWithPushToken(_:andCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-fetchPushNotificationWithRequest:completion:' method instead.");

/// Request for all channels on which push notification (sent using legacy APNs, FCM or MPNS) has been enabled using
/// specified `pushToken`.
///
/// #### Example:
/// ```objc
/// [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:self.devicePushToken
///                          pushType:PNAPNSPush
///                     andCompletion:^(PNAPNSEnabledChannelsResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded list of channels using: `result.data.channels`.
///     } else {
///         // Handle audition error. Check `category` property to find out possible issue because of which request did
///         // fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - pushToken: Device token / identifier which depending from passed `pushType` should be `NSData` (for
///   **PNAPNS2Push** and **PNAPNSPush**) or `NSString` for other.
///   - pushType: One of **PNPushType** fields which specify service to manage notifications for device specified with
///   `pushToken`.
///   - block: Push notifications status audition completion block.
- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(id)pushToken
                                                     pushType:(PNPushType)pushType
                                                andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block
    NS_SWIFT_NAME(pushNotificationEnabledChannelsForDeviceWithPushToken(_:pushType:andCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-fetchPushNotificationWithRequest:completion:' method instead.");

/// Request for all channels on which push notification (sent using APNs over HTTP/2) has been enabled using specified
/// `pushToken`.
///
/// #### Example:
/// ```objc
/// [self.client pushNotificationEnabledChannelsForDeviceWithPushToken:self.devicePushToken
///                                                           pushType:PNAPNS2Push
///                                                        environment:PNAPNSDevelopment
///                                                              topic:@"com.my-application.bundle"
///                                                      andCompletion:^(PNAPNSEnabledChannelsResult *result,
///                                                                      PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded list of channels using: `result.data.channels`.
///     } else {
///         // Handle audition error. Check `category` property to find out possible issue because of which request did
///         // fail.
///         //
///         // Request can be resent using: `[status retry];`
///     }
/// }];
/// ```
///
/// - Parameters:
///   - pushToken: Device token / identifier which depending from passed `pushType` should be `NSData` (for
///   **PNAPNS2Push** and **PNAPNSPush**) or `NSString` for other.
///   - pushType: One of **PNPushType** fields which specify service to manage notifications for device specified with
///   `pushToken`.
///   - environment: One of **PNAPNSEnvironment** fields which specify environment within which device should manage
///   list of channels with enabled notifications (works only if `pushType` set to **PNAPNS2Push**).
///   - topic: Notifications topic name (usually it is application's bundle identifier).
///   - block: Push notifications status audition completion block.
- (void)pushNotificationEnabledChannelsForDeviceWithPushToken:(id)pushToken
                                                     pushType:(PNPushType)pushType
                                                  environment:(PNAPNSEnvironment)environment
                                                        topic:(NSString *)topic
                                                andCompletion:(PNPushNotificationsStateAuditCompletionBlock)block
    NS_SWIFT_NAME(pushNotificationEnabledChannelsForDeviceWithPushToken(_:pushType:environment:topic:andCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-fetchPushNotificationWithRequest:completion:' method instead.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
