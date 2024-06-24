#import "PNMessageActionResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNMessageActionResult


#pragma mark - Properties

- (PNSubscribeMessageActionEventData *)data {
    return self.responseData;
}

#pragma mark -


@end
