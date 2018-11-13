#import "PNPresenceAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Presence 'where now' API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNPresenceWhereNowAPICallBuilder : PNPresenceAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Unique user identifier addition block.
 *
 * @param uuid UUID for which request should be performed.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceWhereNowAPICallBuilder * (^uuid)(NSString *uuid);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Where now fetch completion block.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNWhereNowCompletionBlock block);


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
@property (nonatomic, readonly, strong) PNPresenceWhereNowAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
