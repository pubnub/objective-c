#import <PubNub/PNOperationResult.h>
#import <PubNub/PNSubscribeObjectEventData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Subscribe request processing `app context` result.
@interface PNObjectEventResult : PNOperationResult


#pragma mark - Properties

/// Processed `app context event` information.
@property (nonatomic, readonly, strong) PNSubscribeObjectEventData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
