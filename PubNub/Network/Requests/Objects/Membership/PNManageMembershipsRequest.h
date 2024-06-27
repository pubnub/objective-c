#import <PubNub/PNBaseObjectsMembershipRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Manage UUID's memberships` request.
@interface PNManageMembershipsRequest : PNBaseObjectsMembershipRequest


#pragma mark - Properties

/// List of `channels` within which `UUID` should be `set` as `member`.
///
/// With this specified, request will set `UUID's` membership in specified list of channels and associate `metadata`
/// with `UUID` in context of specified `channel` (if `custom` field is set).
///
/// > Note: Each entry is dictionary with `channel` and **optional** `custom` fields. `custom` should be dictionary with
/// simple objects: `NSString` and `NSNumber`.
@property(strong, nullable, nonatomic) NSArray<NSDictionary *> *setChannels;

/// List of `channels` from which `UUID` should be removed as `member`.
@property(strong, nullable, nonatomic) NSArray<NSString *> *removeChannels;

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Supported keys specified in **PNMembershipFields** enum.
/// > Note:  Default value (**PNMembershipsTotalCountField**) can be reset by setting 0.
@property(assign, nonatomic) PNMembershipFields includeFields;


#pragma mark - Initialization and Configuration

/// Create `Manage UUID's memberships` request.
///
/// - Parameter uuid: Identifier for which memberships should be managed. Will be set to current **PubNub**
/// configuration `uuid` if `nil` is set.
/// - Returns: Ready to use `manage UUID's memberships` request.
+ (instancetype)requestWithUUID:(nullable NSString *)uuid;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
