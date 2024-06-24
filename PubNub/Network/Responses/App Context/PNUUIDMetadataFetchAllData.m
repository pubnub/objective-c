#import "PNUUIDMetadataFetchAllData.h"
#import "PNPagedAppContextData+Private.h"


#pragma mark Interface implementation

@implementation PNUUIDMetadataFetchAllData


#pragma mark - Properties

+ (Class)appContextObjectClass {
    return [PNChannelMember class];
}

#pragma mark -


@end
