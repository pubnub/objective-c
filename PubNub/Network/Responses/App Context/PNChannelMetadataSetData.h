#import <PubNub/PNBaseOperationData.h>
#import <PubNub/PNChannelMetadata.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/// `Set Channel metadata` request response.
@interface PNChannelMetadataSetData : PNBaseOperationData


#pragma mark - Information

/// Associated `channel's metadata` object.
@property(strong, nullable, nonatomic, readonly) PNChannelMetadata *metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
