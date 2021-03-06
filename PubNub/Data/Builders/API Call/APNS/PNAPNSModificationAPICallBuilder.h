#import "PNAPNSAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief APNS state modification API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.12.0
 * @since 4.5.4
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNAPNSModificationAPICallBuilder : PNAPNSAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Device token / identifier addition block.
 *
 * @param token Device token / identifier which should be used to change notifications state on
 *     specified set of channels. Depending from passed \c pushType should be \a NSData (for
 *     \b PNAPNS2Push and \b PNAPNSPush) or \a NSString for other.
 *
 * @return API call configuration builder.
 *
 * @since 4.12.0
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder * (^token)(id token);

/**
 * @brief Device APNS push token addition block.
 *
 * @param token Device APNS-provided push token against which search on \b PubNub service should be
 *     performed.
 *
 * @return API call configuration builder.
 *
 * @since 4.8.9
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder * (^apnsToken)(NSData *token)
    DEPRECATED_MSG_ATTRIBUTE("This method will be deprecated after 4.12.0. Instead please use "
                             "'token' along with 'pushType' set to 'PNAPNSPush'.");

/**
 * @brief Device FCM push token addition block.
 *
 * @param token Device FCM-provided push token against which search on \b PubNub service should be
 *     performed.
 *
 * @return API call configuration builder.
 *
 * @since 4.8.9
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder * (^fcmToken)(NSString *token)
    DEPRECATED_MSG_ATTRIBUTE("This method will be deprecated after 4.12.0. Instead please use "
                             "'token' along with 'pushType' set to 'PNFCMPush'.");

/**
 * @brief List of target channels addition block.
 *
 * @note Use valid \c token and \c nil for this property to disable all push notifications for
 * device.
 *
 * @param channel List of channels for which APNS state should be changed.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder *(^channels)(NSArray<NSString *> * _Nullable channels);

/**
 * @brief Environment in which channel notifications managed.
 *
 * @note This field works only if request initialized with \c pushType set to \b PNAPNS2Push
 * (by default set to \b PNAPNSDevelopment).
 *
 * @param environment One of \b PNAPNSEnvironment fields which specify environment within which
 *   device should manage list of channels with enabled notifications.
 *
 * @return API call configuration builder.
 *
 * @since 4.12.0
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder * (^environment)(PNAPNSEnvironment environment);

/**
 * @brief Push notifications service.
 *
 * @param pushType One of \b PNPushType fields which specify service to manage notifications for
 *     device specified with \c pushToken (will be set to \b PNAPNSPush by default).
 *
 * @return API call configuration builder.
 *
 * @since 4.12.0
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder * (^pushType)(PNPushType pushType);

/**
 * @brief Notifications topic name.
 *
 * @note This field works only if request initialized with \c pushType set to \b PNAPNS2Push
 * (by default set to \b NSBundle.mainBundle.bundleIdentifier).
 *
 * @param environment Notifications topic name (usually it is application's bundle identifier)
 *
 * @return API call configuration builder.
 *
 * @since 4.12.0
 */
 @property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder *(^topic)(NSString *topic);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Push notifications status modification completion block.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNPushNotificationsStateModificationCompletionBlock _Nullable block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent encoded query parameters which should be sent along with
 *     original API call.
 *
 * @return API call configuration builder.
 *
 * @since 4.8.2
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
