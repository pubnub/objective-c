#import "PNStructures.h"
#import "PNRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Base class for all 'Push Notifications' API endpoints which has shared query options.
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.12.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNBasePushNotificationsRequest : PNRequest


#pragma mark - Information

/**
 * @brief One of \b PNPushType fields which specify service to manage notifications for device
 * specified with \c pushToken.
 */
@property (nonatomic, readonly, assign) PNPushType pushType;

/**
 * @brief One of \b PNAPNSEnvironment fields which specify environment within which device should
 * manage list of channels with enabled notifications.
 *
 * @note This field works only if request initialized with \c pushType set to \b PNAPNS2Push
 * (by default set to \b PNAPNSDevelopment).
 */
@property (nonatomic, assign) PNAPNSEnvironment environment;

/**
 * @brief Notifications topic name (usually it is application's bundle identifier).
 *
 * @note This field works only if request initialized with \c pushType set to \b PNAPNS2Push
 * (by default set to \b NSBundle.mainBundle.bundleIdentifier).
 */
@property (nonatomic, nullable, copy) NSString *topic;

/**
 * @brief OS/library-provided device push token.
 */
@property (nonatomic, readonly, copy) id pushToken;

/**
 * @brief Arbitrary percent encoded query parameters which should be sent along with original API
 * call.
 */
@property (nonatomic, nullable, strong) NSDictionary *arbitraryQueryParameters;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c push \c notifications API access request.
 *
 * @param pushToken Device token / identifier which depending from passed \c pushType should be
 *     \a NSData (for \b PNAPNS2Push and \b PNAPNSPush) or \a NSString for other.
 * @param pushType One of \b PNPushType fields which specify service to manage notifications for
 *     device specified with \c pushToken.
 *
 * @return Configured and ready to use \c push \c notifications API access request.
 */
+ (instancetype)requestWithDevicePushToken:(id)pushToken pushType:(PNPushType)pushType;

/**
 * @brief Forbids request initialization.
 *
 * @throws Interface not available exception and requirement to use provided constructor method.
 *
 * @return Initialized request.
 */
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
