#import "PNAPICallBuilder.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PNUnsubscribeChannelsOrGroupsAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Unsubscribe API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNUnsubscribeAPICallBuilder : PNAPICallBuilder


#pragma mark - Channels and Channel Groups

/**
 * @brief Channels un-subscription API access builder block.
 *
 * @param channels List of channel names from which client should try to unsubscribe.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNUnsubscribeChannelsOrGroupsAPICallBuilder * (^channels)(NSArray<NSString *> *channels);

/**
 * @brief Channel groups un-subscription API access builder block.
 *
 * @param channelGroups List of channel group names from which client should try to unsubscribe.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNUnsubscribeChannelsOrGroupsAPICallBuilder * (^channelGroups)(NSArray<NSString *> *channelGroups);


#pragma mark - Presence

/**
 * @brief Presence channel names addition block.
 *
 * @param presenceChannels List of channel names for which client should try to unsubscribe from
 *     presence observing channels.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNUnsubscribeAPICallBuilder * (^presenceChannels)(NSArray<NSString *> *presenceChannels);


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
@property (nonatomic, readonly, strong) PNUnsubscribeAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
