#import <PubNub/PNBaseObjectsRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch channel metadata` request.
@interface PNFetchChannelMetadataRequest : PNBaseObjectsRequest


#pragma mark - Properties

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Supported keys specified in **PNChannelFields** enum.
/// > Note:  Default value (**PNChannelCustomField**) can be reset by setting 0.
@property(assign, nonatomic) PNChannelFields includeFields;


#pragma mark - Initialization and Configuration

/// Create `Fetch channel metadata` request.
///
/// - Parameter channel: Name of channel for which `metadata` should be fetched.
/// - Returns: Ready to use `fetch channel metadata` request.
+ (instancetype)requestWithChannel:(NSString *)channel;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
