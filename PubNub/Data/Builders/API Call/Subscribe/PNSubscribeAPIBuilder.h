#import "PNAPICallBuilder.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PNSubscribeChannelsOrGroupsAPIBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Subscribe API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNSubscribeAPIBuilder : PNAPICallBuilder


#pragma mark - Channels and Channel Groups

/**
 * @brief Channels subscription API access builder block.
 *
 * @param channels List of channel names on which client should try to subscribe.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNSubscribeChannelsOrGroupsAPIBuilder * (^channels)(NSArray<NSString *> *channels);

/**
 * @brief Channel groups subscription API access builder block.
 *
 * @param channelGroups List of channel group names on which client should try to subscribe.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNSubscribeChannelsOrGroupsAPIBuilder * (^channelGroups)(NSArray<NSString *> *channelGroups);


#pragma mark - Presence

/**
 * @brief Presence channel names addition block.
 *
 * @param channels List of channel names for which client should try to subscribe on presence
 *     observing channels.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNSubscribeAPIBuilder * (^presenceChannels)(NSArray<NSString *> *presenceChannels);


#pragma mark - Execution

/**
 * @brief Perform API call.
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
@property (nonatomic, readonly, strong) PNSubscribeAPIBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
