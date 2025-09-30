#import "PNBasePushNotificationsRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General request for all `Push Notifications` API endpoints private extension.
@interface PNBasePushNotificationsRequest (Private)


#pragma mark - Initialization and Configuration

/// Create general `Push notifications` API access request.
///
/// - Parameters:
///   - pushToken: Device token / identifier which depending from passed `pushType` should be `NSData` (for
///   **PNAPNS2Push** and **PNAPNSPush**) or `NSString` for other.
///   - pushType: One of **PNPushType** fields which specify service to manage notifications for device specified with
///   `pushToken`.
/// - Returns: Ready to use `push notifications` API access request.
+ (instancetype)requestWithDevicePushToken:(id)pushToken pushType:(PNPushType)pushType;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
