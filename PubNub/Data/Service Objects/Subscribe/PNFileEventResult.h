#import <PubNub/PNOperationResult.h>
#import <PubNub/PNSubscribeFileEventData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Subscribe request processing `file` result.
@interface PNFileEventResult : PNOperationResult


#pragma mark - Properties

/// Processed `file event` information.
@property (nonatomic, readonly, strong) PNSubscribeFileEventData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
