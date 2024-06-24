#import "PNChannelMembersManageData.h"
#import "PNPagedAppContextData+Private.h"


#pragma mark Interface implementation

@implementation PNChannelMembersManageData


#pragma mark - Properties

+ (Class)appContextObjectClass {
    return [PNChannelMember class];
}

#pragma mark -


@end
