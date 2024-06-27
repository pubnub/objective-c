#import "PNPresenceStateFetchResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceStateFetchResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNPresenceUserStateFetchData class];
}

- (PNPresenceUserStateFetchData *)data {
    return self.responseData;
}

#pragma mark -


@end
