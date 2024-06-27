#import <PubNub/PNObjectsPaginatedRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch all channels metadata` request.
@interface PNFetchAllChannelsMetadataRequest : PNObjectsPaginatedRequest


#pragma mark - Properties

/// Bitfield set to fields which should be returned with response.
///
/// > Note: Supported keys specified in **PNChannelFields** enum.
/// > Note:  Default value (**PNChannelTotalCountField**) can be reset by setting 0.
@property(assign, nonatomic) PNChannelFields includeFields;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
