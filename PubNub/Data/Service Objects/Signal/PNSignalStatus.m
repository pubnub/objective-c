#import "PNSignalStatus.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNSignalStatus


#pragma mark - Properties

- (PNSignalData *)data {
    return !self.isError ? self.responseData : nil;
}

#pragma mark -


@end
