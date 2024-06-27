#import <PubNub/PNBaseRequest.h>
#import <PubNub/PNStructures.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// General request for all `Push Notifications` API endpoints.
@interface PNBasePushNotificationsRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// One of **PNPushType** fields which specify service to manage notifications for device specified with `pushToken`.
@property(assign, nonatomic, readonly) PNPushType pushType;

/// One of **PNAPNSEnvironment** fields which specify environment within which device should manage list of channels
/// with enabled notifications.
///
/// > Note: This field works only if request initialized with `pushType` set to **PNAPNS2Push** (by default set to
/// **PNAPNSDevelopment**).
@property(assign, nonatomic) PNAPNSEnvironment environment;

/// Notifications topic name (usually it is application's bundle identifier).
///
/// > Note: This field works only if request initialized with `pushType` set to **PNAPNS2Push** (by default set to
/// **NSBundle.mainBundle.bundleIdentifier**).
@property(copy, nullable, nonatomic) NSString *topic;

/// OS/library-provided device push token.
@property(copy, nonatomic, readonly) id pushToken;


#pragma mark - Initialization and Configuration

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
