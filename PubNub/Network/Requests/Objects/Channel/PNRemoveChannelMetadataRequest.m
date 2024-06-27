#import "PNRemoveChannelMetadataRequest.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"


#pragma mark Interface implementation

@implementation PNRemoveChannelMetadataRequest


#pragma mark - Properties

- (PNOperationType)operation {
    return PNRemoveChannelMetadataOperation;
}

- (TransportMethod)httpMethod {
    return TransportDELETEMethod;
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannel:(NSString *)channel {
    return [[self alloc] initWithObject:@"Channel" identifier:channel];
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}

#pragma mark -


@end
