#import "PNSubscribeStatus+Private.h"
#import "PNOperationResult+Private.h"
#import "PNStatus+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNSubscribeStatus ()

#pragma mark - Properties

/// Whether this is initial subscribe request processing status or not.
@property(assign, nonatomic, getter = isInitialSubscription) BOOL initialSubscription;

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSubscribeStatus

@dynamic currentTimetoken, lastTimeToken, subscribedChannels, subscribedChannelGroups;


#pragma mark - Information

+ (Class)statusDataClass {
    return [PNSubscribeData class];
}

- (PNSubscribeData *)data {
    return !self.isError ? self.responseData : nil;
}

#pragma mark -


@end
