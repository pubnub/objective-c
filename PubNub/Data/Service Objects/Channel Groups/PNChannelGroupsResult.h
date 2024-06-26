#import <PubNub/PNOperationResult.h>
#import <PubNub/PNChannelGroupFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Fetch channel groups request processing result.
@interface PNChannelGroupsResult : PNOperationResult


#pragma mark - Properties

/// Channel group channels request response from remote service.
@property (nonatomic, nonnull, readonly, strong) PNChannelGroupFetchData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
