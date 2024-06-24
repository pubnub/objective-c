#import "PNHistoryResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interfaces implementation

@implementation PNHistoryResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNHistoryFetchData class];
}

- (PNHistoryFetchData *)data {
    return self.responseData;
}

#pragma mark -


@end
