#import "PNPresenceAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Client's presence management API call builder.
 *
 * @discussion Builder interface which provide access to endpoints which allow to manager
 * subscriber's presence (outside of subscription cycle, virtual).
 *
 * @author Serhii Mamontov
 * @since 4.7.5
 * @copyright © 2010-2018 PubNub, Inc.
 */

@interface PNPresenceHeartbeatAPICallBuilder : PNPresenceAPICallBuilder


#pragma mark - Configuration

/**
 * @brief  Channel names addition block.
 *
 * @param channels List of \c channels for which client should change it's presence state according
 *     to \c connected flag value.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNPresenceHeartbeatAPICallBuilder * (^channels)(NSArray<NSString *> *channels);

/**
 * @brief  Channel group names addition block.
 *
 * @param channelGroups List of channel \c groups for which client should change it's presence state
 *     according to \c connected flag value.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNPresenceHeartbeatAPICallBuilder * (^channelGroups)(NSArray<NSString *> *channelGroups);

/**
 * @brief User's state for channel / groups addition block.
 *
 * @param state Client's state which should be set for passed objects (same as state passed during
 *     subscription or using state change API).
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNPresenceHeartbeatAPICallBuilder * (^state)(NSDictionary<NSString *, NSDictionary *> *state);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block Client's presence modification completion block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNStatusBlock __nullable block);


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
@property (nonatomic, readonly, strong) PNPresenceHeartbeatAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
