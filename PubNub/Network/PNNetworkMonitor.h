#import "PubNub+Core.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Network paths change monitor.
///
/// Monitor, observe, and notify (through logs with reachability level).
@interface PNNetworkMonitor : NSObject


#pragma mark - Initialization and Configuration

/// Create and configure a network monitor for the **PubNub** client.
///
/// - Parameter client: **PubNub** client for which network monitoring will be done.
/// - Returns: Ready-to-use network monitor instance.
+ (instancetype)monitorForClient:(PubNub *)client;


#pragma mark - Lifecycle

/// Invalidate monitor and release used resources.
- (void)invalidate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
