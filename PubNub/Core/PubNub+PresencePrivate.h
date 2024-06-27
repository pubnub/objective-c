#import "PubNub+Presence.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PubNub (PresencePrivate)


#pragma mark - Heartbeat support

/// Announce user presence on specified `channels` and `channel groups`.
///
/// - Parameters:
///   - request: Request with information required to announce presence.
///   - block: Presence announce request completion block.
- (void)heartbeatWithRequest:(PNPresenceHeartbeatRequest *)request completion:(PNStatusBlock)block;

/// Issue heartbeat request to **PubNub** network.
///
/// Heartbeat help **PubNub** presence service to control subscribers availability.
///
/// - Parameter block: Block which should be called with service information.
- (void)heartbeatWithCompletion:(PNStatusBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
