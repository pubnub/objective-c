#import "PNMembershipsFetchData.h"
#import "PNPagedAppContextData+Private.h"


#pragma mark Interface implementation

@implementation PNMembershipsFetchData


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
