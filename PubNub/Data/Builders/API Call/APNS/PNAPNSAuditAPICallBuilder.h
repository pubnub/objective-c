#import "PNAPNSAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief APNS state audit API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNAPNSAuditAPICallBuilder : PNAPNSAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Device push token addition block.
 *
 * @note This method will forward call to 'apnsToken' block.
 *
 * @param token Device push token against which search on \b PubNub service should be performed.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNAPNSAuditAPICallBuilder * (^token)(NSData *token);

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
@property (nonatomic, readonly, strong) PNAPNSAuditAPICallBuilder * (^apnsToken)(NSData *token);

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
@property (nonatomic, readonly, strong) PNAPNSAuditAPICallBuilder * (^fcmToken)(NSString *token);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Push notifications status audition completion block.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNPushNotificationsStateAuditCompletionBlock block);


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
@property (nonatomic, readonly, strong) PNAPNSAuditAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
