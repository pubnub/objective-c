#import <PubNub/PNBaseObjectsMembershipRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Manage channel's memebers` request.
@interface PNManageChannelMembersRequest : PNBaseObjectsMembershipRequest


#pragma mark - Properties

/// List of `UUIDs` which should be added to `channel's members` list.
///
/// With this specified, request will update `channel's` members list by addition of specified list of `UUIDs` and
/// associate `metadata` with `UUID` in context of `channel` (if `custom` field is set).
///
/// > Note: Each entry is dictionary with `uuid` and **optional** `custom` fields. `custom` should be dictionary with
/// simple objects: `NSString` and `NSNumber`.
@property(strong, nullable, nonatomic) NSArray<NSDictionary *> *setMembers;

/// List of `UUIDs` which should be removed from `channel's` list.
@property(strong, nullable, nonatomic) NSArray<NSString *> *removeMembers;

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Supported keys specified in **PNChannelMemberFields** enum.
/// > Note:  Default value (**PNChannelMembersTotalCountField**) can be reset by setting 0.
@property (nonatomic, assign) PNChannelMemberFields includeFields;


#pragma mark - Initialization and Configuration

/// Create `Manage channel's members` request.
///
/// - Parameter channel: Name of channel for which members list should be updated.
/// - Returns: Ready to use `manage channel's` members request.
+ (instancetype)requestWithChannel:(NSString *)channel;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
