#import "PNFetchMessageActionsResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNFetchMessageActionsResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNMessageActionsFetchData class];
}

- (PNMessageActionsFetchData *)data {
    return self.responseData;
}

#pragma mark -


@end
