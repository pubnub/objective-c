#import "PNMembershipsFetchData.h"
#import "PNPagedAppContextData+Private.h"


#pragma mark Interface implementation

@implementation PNMembershipsFetchData


#pragma mark - Properties

+ (Class)appContextObjectClass {
    return [PNMembership class];
}

#pragma mark -


@end
