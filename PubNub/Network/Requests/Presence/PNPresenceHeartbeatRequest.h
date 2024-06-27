#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface implementation

/// `Heartbeat` request.
@interface PNPresenceHeartbeatRequest : PNBaseRequest


#pragma mark - Properties

/// List of channel group names from which client should try to unsubscribe.
@property(copy, nullable, nonatomic, readonly) NSArray<NSString *> *channelGroups;

/// List of channel names from which client should try to unsubscribe.
@property(copy, nullable, nonatomic, readonly) NSArray<NSString *> *channels;

/// User presence timeout interval.
@property(assign, nonatomic, readonly) NSInteger presenceHeartbeatValue;

/// `NSDictionary` with key-value pairs based on channel / group names and value which should be associated to it.
@property(copy, nullable, nonatomic) NSDictionary *state;


#pragma mark - Initialization and Configuration

/// Create `Heartbeat` request.
///
/// - Parameters:
///   - heartbeat: User presence timeout interval.
///   - channels: List of channel names for which user's presence should be announced.
///   - channelGroups: List of channel group names for which user's presence should be announced.
/// - Returns: Ready to use `Heartbeat` request.
+ (instancetype)requestWithHeartbeat:(NSInteger)heartbeat
                            channels:(nullable NSArray<NSString *> *)channels
                       channelGroups:(nullable NSArray<NSString *> *)channelGroups;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
