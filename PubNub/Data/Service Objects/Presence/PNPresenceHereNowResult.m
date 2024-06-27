#import "PNPresenceHereNowResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceHereNowResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNPresenceHereNowFetchData class];
}

- (PNPresenceHereNowFetchData *)data {
    return self.responseData;
}

#pragma mark -


@end
