#import "PNSetUUIDMetadataStatus.h"
#import "PNOperationResult+Private.h"
#import "PNStatus+Private.h"


#pragma mark Interface implementation

@implementation PNSetUUIDMetadataStatus


#pragma mark - Properties

+ (Class)statusDataClass {
    return [PNUUIDMetadataSetData class];
}

- (PNUUIDMetadataSetData *)data {
    return !self.isError ? self.responseData : nil;
}

#pragma mark -


@end
