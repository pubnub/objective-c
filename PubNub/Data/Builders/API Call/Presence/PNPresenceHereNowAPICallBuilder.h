#import <PubNub/PNPresenceAPICallBuilder.h>


#pragma mark Class forward

@class PNPresenceChannelGroupHereNowAPICallBuilder, PNPresenceChannelHereNowAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Presence 'here now' API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNPresenceHereNowAPICallBuilder : PNPresenceAPICallBuilder


#pragma mark - Channel

/**
 * @brief On channel users' presence API access builder block.
 *
 * @discussion Channel for which here now information should be received.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceChannelHereNowAPICallBuilder * (^channel)(NSString *channel);

/**
 * @brief Users' presence on list of channels API access builder block.
 *
 * @discussion List of channels for which here now information should be received.
 *
 * @return API call configuration builder.
 *
 * @since 4.15.8
 */
@property (nonatomic, readonly, strong) PNPresenceChannelHereNowAPICallBuilder * (^channels)(NSArray<NSString *> *channels);


#pragma mark - Channel Group

/**
 * @brief On channel group users' presence API access builder block.
 *
 * @discussion Channel group name for which here now information should be received.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceChannelGroupHereNowAPICallBuilder * (^channelGroup)(NSString *channelGroup);

/**
 * @brief Users' presence on list of channel groups API access builder block.
 *
 * @discussion List of channel group names for which here now information should be received.
 *
 * @return API call configuration builder.
 *
 * @since 4.15.8
 */
@property (nonatomic, readonly, strong) PNPresenceChannelGroupHereNowAPICallBuilder * (^channelGroups)(NSArray<NSString *> *channelGroup);


#pragma mark - Global

/**
 * @brief Users' state information detalization level addition block.
 *
 * @discussion One of \b PNHereNowVerbosityLevel fields to instruct what exactly data it
 *     expected in response.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceHereNowAPICallBuilder * (^verbosity)(PNHereNowVerbosityLevel verbosity);

/**
 * @brief Perform API call.
 *
 * @discussion Here now fetch completion block.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNGlobalHereNowCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @discussion List of arbitrary percent encoded query parameters which should be sent along with
 *     original API call.
 *
 * @return API call configuration builder.
 *
 * @since 4.8.2
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-property-type"
@property (nonatomic, readonly, strong) PNPresenceHereNowAPICallBuilder * (^queryParam)(NSDictionary *params);
#pragma clang diagnostic pop

#pragma mark -


@end

NS_ASSUME_NONNULL_END
