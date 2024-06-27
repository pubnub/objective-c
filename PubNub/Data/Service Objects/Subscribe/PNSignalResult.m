#import "PNSignalResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNSignalResult


#pragma mark - Properties

- (PNSubscribeSignalEventData *)data {
    return self.responseData;
}

#pragma mark -


@end
