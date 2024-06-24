#import "PNPresenceEventResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceEventResult


#pragma mark - Properties

- (PNSubscribePresenceEventData *)data {
    return self.responseData;
}

#pragma mark -


@end
