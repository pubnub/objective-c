#import "PNChannelMetadataFetchAllData.h"
#import "PNPagedAppContextData+Private.h"


#pragma mark Interface implementation

@implementation PNChannelMetadataFetchAllData


#pragma mark - Properties

+ (Class)appContextObjectClass {
    return [PNChannelMetadata class];
}

- (NSArray<PNChannelMetadata *> *)metadata {
    return (NSArray<PNChannelMetadata *> *)self.objects;
}

- (NSUInteger)totalCount {
    return super.totalCount;
}

#pragma mark -


@end

