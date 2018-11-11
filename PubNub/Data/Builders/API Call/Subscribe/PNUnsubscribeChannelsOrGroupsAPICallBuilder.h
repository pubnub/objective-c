#import "PNUnsubscribeAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unsubscribe API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNUnsubscribeChannelsOrGroupsAPICallBuilder : PNUnsubscribeAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Presence channels / channel groups removal flag addition block.
 *
 * @param withPresence Whether client should disable presence observation on specified
 *     channel groups or keep listening for presence event on them.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNUnsubscribeChannelsOrGroupsAPICallBuilder * (^withPresence)(BOOL withPresence);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @note Client will unsubscribe from all channels if none of channel / groups options is set.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) dispatch_block_t perform;


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
@property (nonatomic, readonly, strong) PNUnsubscribeChannelsOrGroupsAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
