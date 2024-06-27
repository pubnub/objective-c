#import <PubNub/PNSubscribeStatus.h>
#import <PubNub/PNSubscribeData.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNSubscribeStatus (Private)


#pragma mark - Properties

/// Whether this is initial subscribe request processing status or not.
@property(assign, nonatomic, getter = isInitialSubscription) BOOL initialSubscription;

///  Structured `PNResult` `data` field information.
@property (nonatomic, readonly, strong) PNSubscribeData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
