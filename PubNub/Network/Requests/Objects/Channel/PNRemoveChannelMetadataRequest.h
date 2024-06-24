#import <PubNub/PNBaseObjectsRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Remove channel metadata` request.
@interface PNRemoveChannelMetadataRequest : PNBaseObjectsRequest


#pragma mark - Initialization and Configuration

/// Create `Remove channel metadata` request.
///
/// - Parameter channel: Name of channel for which `metadata` should be removed.
/// - Returns: Ready to use `remove channel metadata` request.
+ (instancetype)requestWithChannel:(NSString *)channel;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
