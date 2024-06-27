#import <PubNub/PNBaseOperationData.h>
#import <PubNub/PNChannelMetadata.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/// `Fetch channel metadata` request response.
@interface PNChannelMetadataFetchData : PNBaseOperationData


#pragma mark - Properties

/// `Fetch channel metadata` request processed information.
@property(strong, nonatomic, readonly) PNChannelMetadata *metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
