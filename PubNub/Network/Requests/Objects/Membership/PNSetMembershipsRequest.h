#import <PubNub/PNBaseObjectsMembershipRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Set UUID's memberships` request.
@interface PNSetMembershipsRequest : PNBaseObjectsMembershipRequest


#pragma mark - Properties

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Supported keys specified in **PNMembershipFields** enum.
/// > Note:  Default value (**PNMembershipsTotalCountField**) can be reset by setting 0.
@property(assign, nonatomic) PNMembershipFields includeFields;


#pragma mark - Initialization and Configuration

/// Create `Set UUID's memberships` request.
///
/// Request will set `UUID's metadata` associated with membership.
///
/// - Parameters:
///   - uuid: Identifier for which memberships `metadata` should be set. Will be set to current **PubNub** configuration
///   `uuid` if `nil` is set.
///   - channels: List of `channels` for which `metadata` associated with `UUID` should be set. Each entry is dictionary
///   with `channel` and **optional** `custom` fields. `custom` should be dictionary with simple objects: `NSString` and
///   `NSNumber`
/// - Returns: Ready to use `set UUID's memberships` request.
+ (instancetype)requestWithUUID:(nullable NSString *)uuid channels:(NSArray<NSDictionary *> *)channels;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
