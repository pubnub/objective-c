#import "PNChannelGroupsResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNChannelGroupsResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNChannelGroupFetchData class];
}

- (PNChannelGroupFetchData *)data {
    return self.responseData;
}

#pragma mark -


@end
