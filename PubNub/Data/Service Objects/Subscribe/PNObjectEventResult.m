#import "PNObjectEventResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNObjectEventResult


#pragma mark - Properties

- (PNSubscribeObjectEventData *)data {
    return self.responseData;
}

#pragma mark -


@end
