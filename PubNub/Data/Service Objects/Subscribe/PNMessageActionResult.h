#import <PubNub/PNOperationResult.h>
#import <PubNub/PNSubscribeMessageActionEventData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Subscribe request processing `message action` result.
@interface PNMessageActionResult : PNOperationResult


#pragma mark - Properties

/// Processed `message action event` information.
@property (nonatomic, readonly, strong) PNSubscribeMessageActionEventData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END

