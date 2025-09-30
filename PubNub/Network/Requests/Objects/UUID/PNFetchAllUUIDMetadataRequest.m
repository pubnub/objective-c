#import "PNFetchAllUUIDMetadataRequest.h"
#import "PNBaseObjectsRequest+Private.h"
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

+ (instancetype)new {
    PNFetchAllUUIDMetadataRequest *request = [[self alloc] initWithObject:@"UUID" identifier:nil];
    request.includeFields |= PNUUIDTotalCountField|PNUUIDStatusField|PNUUIDTypeField;

    return request;
}

#pragma mark -


@end
