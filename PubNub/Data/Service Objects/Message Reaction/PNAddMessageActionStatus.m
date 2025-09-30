#import "PNAddMessageActionStatus.h"
#import "PNOperationResult+Private.h"
#import "PNStatus+Private.h"
#import "PNErrorData.h"


#pragma mark Interface implementation

@implementation PNAddMessageActionStatus


#pragma mark - Properties

+ (Class)statusDataClass {
    return [PNMessageActionFetchData class];
}

- (PNMessageActionFetchData *)data {
    return !self.isError ? self.responseData : nil;
}

#pragma mark -


@end
