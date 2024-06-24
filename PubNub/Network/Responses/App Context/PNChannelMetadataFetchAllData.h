#import <PubNub/PNPagedAppContextData.h>
#import <PubNub/PNChannelMetadata.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch all channels` request response.
@interface PNChannelMetadataFetchAllData : PNPagedAppContextData


#pragma mark - Properties

/// List of `channels metadata` objects created for current subscribe key.
@property(strong, nonatomic, readonly) NSArray<PNChannelMetadata *> *metadata;

/// Total number of objects created for current subscribe key.
///
/// > Note: Value will be `0` in case if ``PNChannelFields/PNChannelTotalCountField`` not added to `includeFields` of
/// ``PubNub/PNFetchAllChannelsMetadataRequest``.
@property(assign, nonatomic, readonly) NSUInteger totalCount;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
