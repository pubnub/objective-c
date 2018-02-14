#import "PNPresenceAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Client's presence management API call builder.
 * @discussion Class describe interface which provide access to endpoints which allow to manager
 *             subscriber's presence (outside of subscription cycle, virtual).
 *
 * @author Sergey Mamontov
 * @since 4.7.5
 * @copyright © 2009-2017 PubNub, Inc.
 */

@interface PNPresenceHeartbeatAPICallBuilder : PNPresenceAPICallBuilder


///------------------------------------------------
/// @name Configuration
///------------------------------------------------

/**
 * @brief      Specify list of \c channels.
 * @discussion On block call return block which consume list of \c channels for which client's presence
 *             state should be changed according to passed \c connected value.
 */
@property (nonatomic, readonly, strong) PNPresenceHeartbeatAPICallBuilder *(^channels)(NSArray<NSString *> *channels);

/**
 * @brief      Specify list of \c groups.
 * @discussion On block call return block which consume list of \c groups for which client's presence
 *             state should be changed according to passed \c connected value.
 */
@property (nonatomic, readonly, strong) PNPresenceHeartbeatAPICallBuilder *(^channelGroups)(NSArray<NSString *> *channelGroups);

/**
 * @brief      Specify client's \c state.
 * @discussion On block call return block which consume client's \c state for passed objects (channels
 *             and/or groups) which will be set with heartbeat request (identical to passing state during
 *             subscription).
 */
@property (nonatomic, readonly, strong) PNPresenceHeartbeatAPICallBuilder *(^state)(NSDictionary<NSString *, NSDictionary *> *state);


///------------------------------------------------
/// @name Execution
///------------------------------------------------

/**
 * @brief      Perform composed API call.
 * @discussion Will perform request with passed to builder values. In case if error will occur, it will be
 *             reported to event listener's callback.
 * @discussion On block call return block which consume (\b required) presence change completion block
 *             which pass only one argument - operation processing status object.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNStatusBlock __nullable block);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
