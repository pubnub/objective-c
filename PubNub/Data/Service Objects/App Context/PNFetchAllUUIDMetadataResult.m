#import "PNFetchAllUUIDMetadataResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNFetchAllUUIDMetadataResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNUUIDMetadataFetchAllData class];
}

- (PNUUIDMetadataFetchAllData *)data {
    return self.responseData;
}

#pragma mark -


@end
