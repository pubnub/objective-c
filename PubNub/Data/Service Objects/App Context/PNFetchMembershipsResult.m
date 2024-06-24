#import "PNFetchMembershipsResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNFetchMembershipsResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNMembershipsFetchData class];
}

- (PNMembershipsFetchData *)data {
    return self.responseData;
}

#pragma mark -


@end
