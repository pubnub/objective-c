#import "PNAPNSAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief APNS state modification API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNAPNSModificationAPICallBuilder : PNAPNSAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Device push token addition block.
 *
 * @note This method will forward call to 'apnsToken' block.
 *
 * @param token Device push token which should be used to change notifications state on specified
 *     set of channels.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder * (^token)(NSData *token);

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
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder * (^apnsToken)(NSData *token);

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
@property (nonatomic, readonly, strong) PNAPNSModificationAPICallBuilder * (^fcmToken)(NSString *token);

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
