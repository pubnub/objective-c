#import "PNMembershipsManageData.h"
#import "PNPagedAppContextData+Private.h"


#pragma mark Interface implementation

@implementation PNMembershipsManageData


#pragma mark - Properties

+ (Class)appContextObjectClass {
    return [PNMembership class];
}

- (NSArray<PNMembership *> *)memberships {
    return (NSArray<PNMembership *> *)self.objects;
}

- (NSUInteger)totalCount {
    return super.totalCount;
}

#pragma mark -


@end
