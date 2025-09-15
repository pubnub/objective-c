#import "PNFetchUUIDMetadataRequest.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"
#import "PNTransportRequest.h"


#pragma mark Interface implementation

@implementation PNFetchUUIDMetadataRequest


#pragma mark - Properties

@dynamic includeFields;


- (PNOperationType)operation {
    return PNFetchUUIDMetadataOperation;
}


#pragma mark - Initialization and Configuration

+ (instancetype)new {
    return [self requestWithUUID:nil];
}

+ (instancetype)requestWithUUID:(NSString *)uuid {
    return [[self alloc] initWithObject:@"UUID" identifier:uuid];
}

- (instancetype)initWithObject:(NSString *)objectType identifier:(NSString *)identifier {
    if ((self = [super initWithObject:objectType identifier:identifier])) {
        self.includeFields |= PNUUIDCustomField|PNUUIDStatusField|PNUUIDTypeField;
    }
    
    return self;
}

- (instancetype)init {
    [self throwUnavailableInitInterface];

    return nil;
}

#pragma mark -


@end
