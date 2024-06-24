#import <PubNub/PNObjectsPaginatedRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch all metadata` request.
@interface PNFetchAllUUIDMetadataRequest : PNObjectsPaginatedRequest


#pragma mark - Properties

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Supported keys specified in **PNUUIDFields** enum.
/// > Note:  Default value (**PNChannelCustomField**) can be reset by setting 0.
@property(assign, nonatomic) PNUUIDFields includeFields;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
