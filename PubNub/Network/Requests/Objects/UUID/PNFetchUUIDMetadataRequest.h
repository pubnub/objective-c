#import <PubNub/PNBaseObjectsRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch UUID metadata` request.
@interface PNFetchUUIDMetadataRequest : PNBaseObjectsRequest


#pragma mark - Properties

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Supported keys specified in **PNUUIDFields** enum.
/// > Note:  Default value (**PNUUIDCustomField**) can be reset by setting 0.
@property(assign, nonatomic) PNUUIDFields includeFields;


#pragma mark - Initialization and Configuration

/// Create `Fetch UUID metadata` request.
///
/// - Parameter uuid: Identifier for `metadata` should be fetched. Will be set to current **PubNub** configuration
/// `uuid` if `nil` is set.
/// - Returns: Ready to use `fetch UUID metadata` request.
+ (instancetype)requestWithUUID:(nullable NSString *)uuid;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
