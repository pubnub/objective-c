#import "PNFetchChannelMetadataRequest.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"


#pragma mark Interface implementation

@implementation PNFetchChannelMetadataRequest


#pragma mark - Properties

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchChannelMetadataOperation;
}


#pragma mark - Initialization and Configuration

+ (instancetype)requestWithChannel:(NSString *)channel {
    return [[self alloc] initWithObject:@"Channel" identifier:channel];
}

- (instancetype)initWithObject:(NSString *)objectType identifier:(NSString *)identifier {
    if ((self = [super initWithObject:objectType identifier:identifier])) self.includeFields = PNChannelCustomField;
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}

#pragma mark -


@end
