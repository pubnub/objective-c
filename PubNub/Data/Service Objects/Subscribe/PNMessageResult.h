#import <PubNub/PNOperationResult.h>
#import <PubNub/PNSubscribeMessageEventData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Subscribe request processing `message` result.
@interface PNMessageResult : PNOperationResult


#pragma mark - Properties

/// Processed `message event` information.
@property (nonatomic, readonly, strong) PNSubscribeMessageEventData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
