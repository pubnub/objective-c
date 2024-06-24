#import "PNMessageResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNMessageResult


#pragma mark - Properties

- (PNSubscribeMessageEventData *)data {
    return self.responseData;
}

#pragma mark -


@end
