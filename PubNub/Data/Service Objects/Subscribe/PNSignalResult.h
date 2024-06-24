#import <PubNub/PNOperationResult.h>
#import <PubNub/PNSubscribeSignalEventData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Subscribe request processing `signal` result.
@interface PNSignalResult : PNOperationResult


#pragma mark - Properties

/// Processed `signal event` information.
@property (nonatomic, readonly, strong) PNSubscribeSignalEventData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
