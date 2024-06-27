#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `List channel group channels` request.
///
/// The **PubNub** client will retrieve a list of channels which have been registered for the specified channel group.
@interface PNChannelGroupFetchRequest : PNBaseRequest


#pragma mark - Properties

/// Arbitrary percent encoded query parameters which should be sent along with original API call.
@property(strong, nullable, nonatomic) NSDictionary *arbitraryQueryParameters;

/// Name of the channel group for which list of registered channels should be retrieved.
@property(copy, nullable, nonatomic, readonly) NSString *channelGroup;


#pragma mark - Initialization and Configuration

/// Create `list all channel groups` request.
///
/// - Returns: Ready to use `list all channel groups` request.
+ (instancetype)requestChannelGroups;

/// Create `list channel group channels` request.
///
/// - Parameter channelGroup: Name of the channel group for which list of registered channels should be retrieved.
/// - Returns: Ready to use `list channel group channels` request.
+ (instancetype)requestWithChannelGroup:(NSString *)channelGroup;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
