#import "PNPublishStatus.h"
#import "PNOperationResult+Private.h"
#import "PNStatus+Private.h"


#pragma mark Interface implementation

@implementation PNPublishStatus


#pragma mark - Properties

+ (Class)statusDataClass {
    return [PNPublishData class];
}

- (PNPublishData *)data {
    return !self.isError ? self.responseData : nil;
}

#pragma mark -


@end
