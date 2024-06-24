#import "PNFetchChannelMetadataResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNFetchChannelMetadataResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNChannelMetadataFetchData class];
}

- (PNChannelMetadataFetchData *)data {
    return self.responseData;
}

#pragma mark -


@end
