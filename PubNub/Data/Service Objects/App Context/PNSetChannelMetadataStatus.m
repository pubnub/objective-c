#import "PNSetChannelMetadataStatus.h"
#import "PNOperationResult+Private.h"
#import "PNStatus+Private.h"


#pragma mark Interface implementation

@implementation PNSetChannelMetadataStatus


#pragma mark - Properties

+ (Class)statusDataClass {
    return [PNChannelMetadataSetData class];
}

- (PNChannelMetadataSetData *)data {
    return !self.isError ? self.responseData : nil;
}

#pragma mark -


@end
