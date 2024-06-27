#import "PNFileEventResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNFileEventResult


#pragma mark - Properties

- (PNSubscribeFileEventData *)data {
    return self.responseData;
}

#pragma mark -


@end
