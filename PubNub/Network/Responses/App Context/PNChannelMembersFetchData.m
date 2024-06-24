#import "PNChannelMembersFetchData.h"
#import "PNPagedAppContextData+Private.h"


#pragma mark Interface implementation

@implementation PNChannelMembersFetchData


#pragma mark - Properties

+ (Class)appContextObjectClass {
    return [PNChannelMember class];
}

#pragma mark -


@end
