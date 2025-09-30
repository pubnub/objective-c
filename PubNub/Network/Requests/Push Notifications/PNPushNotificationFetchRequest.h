#import <PubNub/PNBasePushNotificationsRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `List` notification enabled channels` request.
@interface PNPushNotificationFetchRequest : PNBasePushNotificationsRequest


#pragma mark - Initialization and Configuration

/// Create `fetch push notifications` API access request.
///
/// - Parameters:
///   - pushToken: Device token / identifier which depending from passed `pushType` should be `NSData` (for
///   **PNAPNS2Push** and **PNAPNSPush**) or `NSString` for other.
///   - pushType: One of **PNPushType** fields which specify service to manage notifications for device specified with
///   `pushToken`.
/// - Returns: Ready to use `fetch push notifications` API access request.
+ (instancetype)requestWithDevicePushToken:(id)pushToken pushType:(PNPushType)pushType;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
