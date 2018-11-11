#import "PNAPICallBuilder.h"
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief History / storage modification API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.7.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNDeleteMessageAPICallBuilder : PNAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Channel name addition block.
 *
 * @param channel Name of the channel from which events should be removed.
 *
 * @return API call configuration builder.
 *
 * @since 4.7.0
 */
@property (nonatomic, readonly, strong) PNDeleteMessageAPICallBuilder * (^channel)(NSString *channel);

/**
 * @brief Removed interval start timetoken addition block.
 *
 * @param start Timetoken for oldest event starting from which events should be removed.
 *     Value will be converted to required precision internally. If no \c end value provided, will
 *     be removed all events till specified \c start date (not inclusive).
 *
 * @return API call configuration builder.
 *
 * @since 4.7.0
 */
@property (nonatomic, readonly, strong) PNDeleteMessageAPICallBuilder * (^start)(NSNumber *start);

/**
 * @brief Removed interval end timetoken addition block.
 *
 * @param end Timetoken for latest event till which events should be removed.
 *     Value will be converted to required precision internally. If no \c start value provided, will
 *     be removed all events starting from specified \c end date (inclusive).
 *
 * @return API call configuration builder.
 *
 * @since 4.7.0
 */
@property (nonatomic, readonly, strong) PNDeleteMessageAPICallBuilder * (^end)(NSNumber *end);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Events remove completion block.
 *
 * @since 4.7.0
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNMessageDeleteCompletionBlock block);


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
@property (nonatomic, readonly, strong) PNDeleteMessageAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
