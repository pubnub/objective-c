#import <PubNub/PNBaseObjectsMembershipRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Remove UUID's memberships` request.
@interface PNRemoveMembershipsRequest : PNBaseObjectsMembershipRequest


#pragma mark - Properties

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Supported keys specified in **PNMembershipFields** enum.
/// > Note: Default value (**PNMembershipsTotalCountField**) can be reset by setting 0.
@property(assign, nonatomic) PNMembershipFields includeFields;


#pragma mark - Initialization and Configuration

/// Create `Remove UUID's memberships` request.
///
/// - Parameters:
///   - uuid: Identifier for which memberships information should be removed.  Will be set to current **PubNub**
///   configuration `uuid` if `nil` is set.
///   - channels: List of`channels` from which `UUID` should be removed as `member`.
/// - Returns: Ready to use `remove UUID's memberships` request.
+ (instancetype)requestWithUUID:(nullable NSString *)uuid channels:(NSArray<NSString *> *)channels;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
