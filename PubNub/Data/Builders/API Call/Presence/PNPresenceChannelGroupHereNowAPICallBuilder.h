#import "PNPresenceHereNowAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Channel group's 'here now' API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNPresenceChannelGroupHereNowAPICallBuilder : PNPresenceHereNowAPICallBuilder


#pragma mark - Configuration

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
@property (nonatomic, readonly, strong) PNPresenceChannelGroupHereNowAPICallBuilder * (^verbosity)(PNHereNowVerbosityLevel verbosity);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Here now fetch completion block.
 *
 * @since 4.5.4
 */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wincompatible-property-type"
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNChannelGroupHereNowCompletionBlock block);
#pragma clang diagnostic pop


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
@property (nonatomic, readonly, strong) PNPresenceChannelGroupHereNowAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
