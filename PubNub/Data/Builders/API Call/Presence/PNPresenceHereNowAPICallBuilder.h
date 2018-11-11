#import "PNPresenceAPICallBuilder.h"


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
 * @param channel Channel for which here now information should be received.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceChannelHereNowAPICallBuilder * (^channel)(NSString *channel);


#pragma mark - Channel Group

/**
 * @brief On channel group users' presence API access builder block.
 *
 * @param channelGroup Channel group name for which here now information should be received.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceChannelGroupHereNowAPICallBuilder * (^channelGroup)(NSString *channelGroup);


#pragma mark - Global

/**
 * @brief Users' state information detalization level addition block.
 *
 * @param verbosity One of \b PNHereNowVerbosityLevel fields to instruct what exactly data it
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
 * @param block Here now fetch completion block.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNGlobalHereNowCompletionBlock block);


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
@property (nonatomic, readonly, strong) PNPresenceHereNowAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
