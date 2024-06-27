#import <PubNub/PNOperationResult.h>
#import <PubNub/PNSubscribePresenceEventData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Subscribe request processing `message action` result.
@interface PNPresenceEventResult : PNOperationResult


#pragma mark - Properties

/// Processed `presence event` information.
@property (nonatomic, readonly, strong) PNSubscribePresenceEventData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
