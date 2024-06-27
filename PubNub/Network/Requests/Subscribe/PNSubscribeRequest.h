#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Subscribe` request.
@interface PNSubscribeRequest : PNBaseRequest


#pragma mark - Properties

/// Whether presence observation should be enabled for `channels` and `channelGroups` or not.
@property(assign, nonatomic, getter = shouldObservePresence) BOOL observePresence;

/// List of channel group names on which client should try to subscribe.
@property(copy, nullable, nonatomic, readonly) NSArray<NSString *> *channelGroups;

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// List of channel names on which client should try to subscribe.
@property(copy, nullable, nonatomic, readonly) NSArray<NSString *> *channels;

/// `NSDictionary` with key-value pairs based on channel / group names and value which should be associated to it.
@property(copy, nullable, nonatomic) NSDictionary *state;

/// Time from which client should try to catch up on messages.
@property(copy, nullable, nonatomic) NSNumber *timetoken;

/// ///Stores reference on **PubNub** server region identifier (which generated `timetoken` value).
@property(copy, nullable, nonatomic) NSNumber *region;


#pragma mark - Initialization and Configuration

/// Create `Subscribe` request.
///
/// - Parameters:
///   - channels: List of channel names on which client should try to subscribe.
///   - channelGroups: List of channel group names on which client should try to subscribe.
/// - Returns: Ready to use `Subscribe` request.
+ (instancetype)requestWithChannels:(nullable NSArray<NSString *> *)channels
                      channelGroups:(nullable NSArray<NSString *> *)channelGroups;

/// Create `Subscribe` request.
///
/// - Parameters:
///   - channels: List of channel names from which client should try to listen for presence updates.
///   - channelGroups: List of channel group names from which client should try to listen for presence updates.
/// - Returns: Ready to use `Subscribe` request.
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
