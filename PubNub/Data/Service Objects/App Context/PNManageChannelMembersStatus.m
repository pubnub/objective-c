#import "PNManageChannelMembersStatus.h"
#import "PNOperationResult+Private.h"
#import "PNStatus+Private.h"


#pragma mark Interface implementation

@implementation PNManageChannelMembersStatus


#pragma mark - Properties

+ (Class)statusDataClass {
    return [PNChannelMembersManageData class];
}

- (PNChannelMembersManageData *)data {
    return !self.isError ? self.responseData : nil;
}

#pragma mark -


@end
