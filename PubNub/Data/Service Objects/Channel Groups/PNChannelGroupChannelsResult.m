#import "PNChannelGroupChannelsResult.h"
#import "PNOperationResult+Private.h"


#pragma mark Interface implementation

@implementation PNChannelGroupChannelsResult


#pragma mark - Properties

+ (Class)responseDataClass {
    return [PNChannelGroupFetchData class];
}

- (PNChannelGroupFetchData *)data {
    return self.responseData;
}

#pragma mark -


@end
