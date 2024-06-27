#import <PubNub/PNBaseRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// General request for all `Message Action` API endpoints.
@interface PNBaseMessageActionRequest : PNBaseRequest


#pragma mark - Initialization and Configuration

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
