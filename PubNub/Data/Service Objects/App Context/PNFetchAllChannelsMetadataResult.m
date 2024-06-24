#import "PNFetchAllChannelsMetadataResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNFetchAllChannelsMetadataResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNChannelMetadataFetchAllData class];
}

- (PNChannelMetadataFetchAllData *)data {
    return self.responseData;
}

#pragma mark -


@end
