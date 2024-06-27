#import "PNFetchUUIDMetadataResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNFetchUUIDMetadataResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNUUIDMetadataFetchData class];
}

- (PNUUIDMetadataFetchData *)data {
    return self.responseData;
}

#pragma mark -


@end
