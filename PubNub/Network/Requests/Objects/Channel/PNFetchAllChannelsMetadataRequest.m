#import "PNFetchAllChannelsMetadataRequest.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"


#pragma mark Interface implementation

@implementation PNFetchAllChannelsMetadataRequest


#pragma mark - Properties

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchAllChannelsMetadataOperation;
}

- (BOOL)isIdentifierRequired {
    return NO;
}


#pragma mark - Initialization and Configuration

- (instancetype)init {
    if ((self = [super init])) self.includeFields = PNChannelTotalCountField;
    return self;
}

#pragma mark -


@end
