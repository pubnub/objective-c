#import "PNFetchAllUUIDMetadataRequest.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"


#pragma mark Interface implementation

@implementation PNFetchAllUUIDMetadataRequest


#pragma mark - Properties

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchAllUUIDMetadataOperation;
}

- (BOOL)isIdentifierRequired {
    return NO;
}


#pragma mark - Initialization and Configuration

- (instancetype)init {
    if ((self = [super init])) self.includeFields = PNUUIDTotalCountField;
    return self;
}

#pragma mark -


@end
