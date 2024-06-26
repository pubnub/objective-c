#import "PNChannelMembersFetchData.h"
#import "PNPagedAppContextData+Private.h"


#pragma mark Interface implementation

@implementation PNChannelMembersFetchData


#pragma mark - Properties

+ (Class)appContextObjectClass {
    return [PNChannelMember class];
}

- (NSArray<PNChannelMember *> *)members {
    return (NSArray<PNChannelMember *> *)self.objects;
}

- (NSUInteger)totalCount {
    return super.totalCount;
}

#pragma mark -


@end
