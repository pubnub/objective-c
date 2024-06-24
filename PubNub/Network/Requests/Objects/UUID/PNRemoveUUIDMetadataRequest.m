#import "PNRemoveUUIDMetadataRequest.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"


#pragma mark Interface implementation

@implementation PNRemoveUUIDMetadataRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNRemoveUUIDMetadataOperation;
}

- (TransportMethod)httpMethod {
    return TransportDELETEMethod;
}


#pragma mark - Initialization and Configuration

+ (instancetype)new {
    return [self requestWithUUID:nil];
}

+ (instancetype)requestWithUUID:(NSString *)uuid {
    return [[self alloc] initWithObject:@"UUID" identifier:uuid];
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}

#pragma mark -


@end
