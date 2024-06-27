#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Channel group manage` request.
@interface PNChannelGroupManageRequest : PNBaseRequest


#pragma mark - Properties

/// List of channels which can be used to manage channel group channels list.
@property(strong, nullable, nonatomic, readonly) NSArray<NSString *> *channels;

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// Name of channel group for which manage will be done.
@property(strong, nullable, nonatomic, readonly) NSString *channelGroup;


#pragma mark - Initialization and Configuration

/// Create `channel group channels addition` request.
///
/// - Parameters:
///   - channels: List of channels which should be added to the channel group.
///   - channelGroup: Name of the channel group into which channels should be added.
/// - Returns: Ready to use `manage channel group` request.
+ (instancetype)requestToAddChannels:(NSArray<NSString *> *)channels toChannelGroup:(NSString *)channelGroup;

/// Create `channel group channels removal` request.
///
/// - Parameters:
///   - channels: List of channels which should be removed from the channel group.
///   - channelGroup: Name of the channel group from which channels should be removed.
/// - Returns: Ready to use `manage channel group` request.
+ (instancetype)requestToRemoveChannels:(NSArray<NSString *> *)channels fromChannelGroup:(NSString *)channelGroup;

/// Create `channel group removal` request.
///
/// - Parameter channelGroup: Name of the channel group which should be removed.
/// - Returns: Ready to use `manage channel group` request.
+ (instancetype)requestToRemoveChannelGroup:(NSString *)channelGroup;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END

