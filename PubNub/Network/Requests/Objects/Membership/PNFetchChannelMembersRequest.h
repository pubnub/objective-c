#import <PubNub/PNObjectsPaginatedRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch channel's members` request.
@interface PNFetchChannelMembersRequest : PNObjectsPaginatedRequest


#pragma mark - Properties

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Supported keys specified in **PNChannelMemberFields** enum.
/// > Note:  Default value (**PNChannelMembersTotalCountField**) can be reset by setting 0.
@property(assign, nonatomic) PNChannelMemberFields includeFields;


#pragma mark - Initialization and Configuration

/// Create `Fetch channel's members` request.
///
/// - Parameter channel: Name of channel for which members list should be fetched.
/// - Returns: Ready to use `fetch channel's members` request.
+ (instancetype)requestWithChannel:(NSString *)channel;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
