#import <PubNub/PNBasePushNotificationsRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Iinterface declaration

/// `Push Notifications Manage` request.
@interface PNPushNotificationManageRequest : PNBasePushNotificationsRequest


#pragma mark - Properties

/// List of channel names for which push notifications should be managed.
@property(strong, nullable, nonatomic, readonly) NSArray<NSString *> *channels;


#pragma mark - Initialization and Configuration

/// Create `Add notifications for channels` request.
///
/// - Parameters:
///   - channels: List of channel names for which push notifications should be enabled.
///   - token: Device token / identifier which depending from passed `pushType` should be `NSData` (for **PNAPNS2Push**
///   and **PNAPNSPush**) or `NSString` for other.
///   - pushType: One of **PNPushType** fields which specify service to manage notifications for device specified with
///   `token`.
/// - Returns: Ready to use `add notifications for channels` request.
+ (instancetype)requestToAddChannels:(NSArray<NSString *> *)channels
                   toDeviceWithToken:(id)token
                            pushType:(PNPushType)pushType;

/// Create `Remove notifications for channels` request.
///
/// - Parameters:
///   - channels: List of channel names for which push notifications should be disabled.
///   - token: Device token / identifier which depending from passed `pushType` should be `NSData` (for **PNAPNS2Push**
///   and **PNAPNSPush**) or `NSString` for other.
///   - pushType: One of **PNPushType** fields which specify service to manage notifications for device specified with
///   `token`.
/// - Returns: Ready to use `remove notifications for channels` request.
+ (instancetype)requestToRemoveChannels:(NSArray<NSString *> *)channels
                    fromDeviceWithToken:(id)token
                               pushType:(PNPushType)pushType;

/// Create `Remove device notifications` request.
///
/// - Parameters:
///   - token: Device token / identifier which depending from passed `pushType` should be `NSData` (for **PNAPNS2Push**
///   and **PNAPNSPush**) or `NSString` for other.
///   - pushType: One of **PNPushType** fields which specify service to manage notifications for device specified with
///   `token`.
/// - Returns: Ready to use `remove device notifications` request.
+ (instancetype)requestToRemoveDeviceWithToken:(id)token pushType:(PNPushType)pushType;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
