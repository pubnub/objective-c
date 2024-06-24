#import <PubNub/PNOperationResult.h>
#import <PubNub/PNMessageActionsFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/// `Fetch message actions` request processing result.
@interface PNFetchMessageActionsResult : PNOperationResult


#pragma mark - Properties

/// `Fetch message actions` request processed data.
@property(strong, nonatomic, readonly) PNMessageActionsFetchData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
