#import <PubNub/PNOperationResult.h>
#import <PubNub/PNChannelGroupFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Fetch channel group channels request processing result.
@interface PNChannelGroupChannelsResult : PNOperationResult


#pragma mark - Properties

/// Channel group channels request response from remote service.
@property (nonatomic, nonnull, readonly, strong) PNChannelGroupFetchData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
