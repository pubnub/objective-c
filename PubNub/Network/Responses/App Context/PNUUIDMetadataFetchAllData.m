#import "PNUUIDMetadataFetchAllData.h"
#import "PNPagedAppContextData+Private.h"
#import "PNBaseOperationData+Private.h"


#pragma mark Interface implementation

@implementation PNUUIDMetadataFetchAllData


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"metadata": @"data",
        @"totalCount": @"totalCount"
    };
}

+ (Class)appContextObjectClass {
    return [PNUUIDMetadata class];
}

- (NSArray<PNUUIDMetadata *> *)metadata {
    return (NSArray<PNUUIDMetadata *> *)self.objects;
}

- (NSUInteger)totalCount {
    return super.totalCount;
}

#pragma mark -


@end
