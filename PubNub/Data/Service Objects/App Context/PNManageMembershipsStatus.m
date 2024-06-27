#import "PNManageMembershipsStatus.h"
#import "PNOperationResult+Private.h"
#import "PNStatus+Private.h"


#pragma mark Interface implementation

@implementation PNManageMembershipsStatus


#pragma mark - Properties

+ (Class)statusDataClass {
    return [PNMembershipsManageData class];
}

- (PNMembershipsManageData *)data {
    return !self.isError ? self.responseData : nil;
}

#pragma mark -


@end
