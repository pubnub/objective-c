#import <PubNub/PNOperationResult.h>
#import <PubNub/PNHistoryFetchData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Fetch history` request processing result.
@interface PNHistoryResult : PNOperationResult


#pragma mark -  Properties

/// `Fetch history` request processed information.
@property(strong, nonatomic, readonly) PNHistoryFetchData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
