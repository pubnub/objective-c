#import <PubNub/PNBaseObjectsRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Remove UUID metadata` request.
@interface PNRemoveUUIDMetadataRequest : PNBaseObjectsRequest


#pragma mark - Initialization and Configuration

/// Create `Remove UUID metadata` request.
///
/// - Parameter uuid: Identifier for which `metadata` should be removed. Will be set to current **PubNub** configuration
/// `uuid` if `nil` is set.
/// - Returns: Ready to use `remove UUID metadata` request.
+ (instancetype)requestWithUUID:(nullable NSString *)uuid;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
