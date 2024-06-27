#import <PubNub/PNBaseObjectsMembershipRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Remove channel's members` request.
@interface PNRemoveChannelMembersRequest : PNBaseObjectsMembershipRequest


#pragma mark - Information

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Supported keys specified in **PNChannelMemberFields** enum.
/// > Note: Default value (**PNChannelMembersTotalCountField) can be reset by setting 0.
@property(assign, nonatomic) PNChannelMemberFields includeFields;


#pragma mark - Initialization & Configuration

/// Create `Remove channel's members` request.
///
/// - Parameters:
///   - channel: Name of channel from which members should be removed.
///   - uuids: List of `UUIDs` which should be removed from `channel's` list.
/// - Returns: Ready to use `remove channel's members` request.
+ (instancetype)requestWithChannel:(NSString *)channel uuids:(NSArray<NSString *> *)uuids;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
