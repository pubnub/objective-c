#import "PNMembershipsManageData.h"
#import "PNPagedAppContextData+Private.h"


#pragma mark Interface implementation

@implementation PNMembershipsManageData


#pragma mark - Properties

+ (Class)appContextObjectClass {
    return [PNMembership class];
}

#pragma mark -


@end
