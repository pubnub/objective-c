#import <PubNub/PNBaseObjectsMembershipRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Set channel's members` request.
@interface PNSetChannelMembersRequest : PNBaseObjectsMembershipRequest


#pragma mark - Properties

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Supported keys specified in **PNChannelMemberFields** enum.
/// > Note:  Default value (**PNChannelMembersTotalCountField**) can be reset by setting 0.
@property(assign, nonatomic) PNChannelMemberFields includeFields;


#pragma mark - Initialization and Configuration

/// Create `Set channel's members` request.
///
/// Request will set `UUID's metadata` associated with it in context of `channel`.
///
/// - Parameters:
///   - channel: Name of channel for which members `metadata` should be set.
///   - uuids: List of `UUIDs` for which `metadata` associated with each of them in context of `channel` should be set.
///   Each entry is dictionary with `uuid` and **optional** `custom` fields. `custom` should be dictionary with simple
///   objects: `NSString` and `NSNumber`.
/// - Returns: Ready to use `set channel's members` request.
+ (instancetype)requestWithChannel:(NSString *)channel uuids:(NSArray<NSDictionary *> *)uuids;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
