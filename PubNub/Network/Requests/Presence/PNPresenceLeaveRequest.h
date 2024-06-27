#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface implementation

/// `Leave` request.
@interface PNPresenceLeaveRequest : PNBaseRequest


#pragma mark - Properties

/// Whether presence observation should be enabled for `channels` and `channelGroups` or not.
@property(assign, nonatomic, getter = shouldObservePresence) BOOL observePresence;

/// List of channel group names from which client should try to unsubscribe.
@property(copy, nullable, nonatomic, readonly) NSArray<NSString *> *channelGroups;

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// List of channel names from which client should try to unsubscribe.
@property(copy, nullable, nonatomic, readonly) NSArray<NSString *> *channels;


#pragma mark - Initialization and Configuration

/// Create `Leave` request.
///
/// - Parameters:
///   - channels: List of channel names from which client should try to unsubscribe.
///   - channelGroups: List of channel group names from which client should try to unsubscribe.
/// - Returns: Ready to use `Leave` request.
+ (instancetype)requestWithChannels:(nullable NSArray<NSString *> *)channels
                      channelGroups:(nullable NSArray<NSString *> *)channelGroups;

/// Create `Leave` request.
///
/// - Parameters:
///   - channels: List of channel names from which client should stop receiving presence updates.
///   - channelGroups: List of channel group names from which client should stop receiving presence updates.
/// - Returns: Ready to use `Leave` request.
+ (instancetype)requestWithPresenceChannels:(nullable NSArray<NSString *> *)channels
                              channelGroups:(nullable NSArray<NSString *> *)channelGroups;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
