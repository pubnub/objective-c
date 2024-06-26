#import "PNSignalStatus.h"
#import "PNOperationResult+Private.h"
#import "PNStatus+Private.h"


#pragma mark Interface implementation

@implementation PNSignalStatus


#pragma mark - Properties

+ (Class)statusDataClass {
    return [PNSignalData class];
}

- (PNSignalData *)data {
    return !self.isError ? self.responseData : nil;
}

#pragma mark -


@end
