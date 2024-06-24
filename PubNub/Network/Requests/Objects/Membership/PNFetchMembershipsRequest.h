#import <PubNub/PNObjectsPaginatedRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch UUID memberships` request.
@interface PNFetchMembershipsRequest : PNObjectsPaginatedRequest


#pragma mark - Properties

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Supported keys specified in **PNMembershipFields** enum.
/// > Note:  Default value (**PNMembershipsTotalCountField**) can be reset by setting 0.
@property(assign, nonatomic) PNMembershipFields includeFields;


#pragma mark - Initialization and Configuration

/// Create `Fetch UUID's memberships` request.
///
/// - Parameter uuid: Identifier for which memberships in `channels` should be fetched. Will be set to current
/// **PubNub** configuration `uuid` if `nil` is set.
/// - Returns: Ready to use `fetch UUID's memberships` request.
+ (instancetype)requestWithUUID:(nullable NSString *)uuid;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
