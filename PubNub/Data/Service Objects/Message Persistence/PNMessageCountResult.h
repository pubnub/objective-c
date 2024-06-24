#import <PubNub/PNOperationResult.h>
#import <PubNub/PNHistoryMessageCountData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `Channels message count` request processing result.
@interface PNMessageCountResult : PNOperationResult


#pragma mark - Properties

/// Message count request processing information.
@property(strong, nonatomic, readonly) PNHistoryMessageCountData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
