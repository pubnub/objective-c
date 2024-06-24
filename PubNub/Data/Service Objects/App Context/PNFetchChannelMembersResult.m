#import "PNFetchChannelMembersResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNFetchChannelMembersResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNChannelMembersFetchData class];
}

- (PNChannelMembersFetchData *)data {
    return self.responseData;
}

#pragma mark -


@end
