#import "PNClientStateUpdateStatus.h"
#import "PNOperationResult+Private.h"
#import "PNStatus+Private.h"


#pragma mark - Interface implementation

@implementation PNClientStateUpdateStatus


#pragma mark - Information

+ (Class)statusDataClass {
    return [PNPresenceUserStateSetData class];
}

- (PNPresenceUserStateSetData *)data {
    return !self.isError ? self.responseData : nil;
}

#pragma mark -


@end
