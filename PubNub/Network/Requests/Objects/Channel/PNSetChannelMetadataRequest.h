#import <PubNub/PNBaseObjectsRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Set channel metadata` request.
@interface PNSetChannelMetadataRequest : PNBaseObjectsRequest


#pragma mark - Properties

/// Optional entity tag from a previously received ``PNChannelMetadata``.
///
/// The request will fail if this parameter is specified and the ETag value on the server doesn't match.
@property(strong, nullable, nonatomic) NSString *ifMatchesEtag;

/// Additional / complex attributes which should be stored in `metadata` associated with specified `channel`.
@property(nonatomic, nullable, strong) NSDictionary *custom;

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Supported keys specified in **PNChannelFields** enum.
/// > Note:  Default value (**PNChannelCustomField**) can be reset by setting `0`.
@property(assign, nonatomic) PNChannelFields includeFields;

/// Description which should be stored in `metadata` associated with specified `channel`.
@property(copy, nullable, nonatomic) NSString *information;

/// UUID's `metadata` object `status`.
@property(strong, nullable, nonatomic) NSString *status;

/// UUID's `metadata` object `type`.
@property(strong, nullable, nonatomic) NSString *type;

/// Name which should be stored in `metadata` associated with specified `channel`.
@property(copy, nonatomic) NSString *name;


#pragma mark - Initialization and Configuration

/// Create `Set channel metadata` request.
///
/// - Parameter channel: Name of channel for which `metadata` should be set.
/// - Returns: Ready to use `set channel metadata` request.
+ (instancetype)requestWithChannel:(NSString *)channel;

/// Forbids request initialization.
///
/// - Returns: Initialized request.
/// - Throws: Interface not available exception and requirement to use provided constructor method.
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
