#import <PubNub/PNOperationResult.h>
#import <PubNub/PNChannelMetadataFetchAllData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch all channels metadata` request processing result.
@interface PNFetchAllChannelsMetadataResult : PNOperationResult


#pragma mark - Properties

/// `Fetch all channels metadata` request processed information.
@property(strong, nonatomic, readonly) PNChannelMetadataFetchAllData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
