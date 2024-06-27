#import "PNPresenceWhereNowResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceWhereNowResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNPresenceWhereNowFetchData class];
}

- (PNPresenceWhereNowFetchData *)data {
    return self.responseData;
}

#pragma mark -


@end
