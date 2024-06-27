#import "PNObjectsPaginatedRequest.h"
#import "PNBaseObjectsRequest+Private.h"
#import "PNBaseRequest+Private.h"


#pragma mark Interface implementation

@implementation PNObjectsPaginatedRequest


#pragma mark - Properties

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];
    
    if ((self.includeFields & PNChannelTotalCountField) == PNChannelTotalCountField ||
        (self.includeFields & PNUUIDTotalCountField) == PNUUIDTotalCountField ||
        (self.includeFields & PNMembershipsTotalCountField) == PNMembershipsTotalCountField ||
        (self.includeFields & PNChannelMembersTotalCountField) == PNChannelMembersTotalCountField) {
        query[@"count"] = @"1";
    }
    
    if (self.sort.count > 0) query[@"sort"] = [self.sort componentsJoinedByString:@","];
    if (self.limit > 0) query[@"limit"] = @(self.limit).stringValue;
    if (self.filter.length > 0) query[@"filter"] = self.filter;
    if (self.start.length) query[@"start"] = self.start;
    if (self.end.length) query[@"end"] = self.end;
    
    return query.count ? query : nil;
}

#pragma mark - Initialization and Configuration

- (instancetype)initWithObject:(NSString *)objectType identifier:(NSString *)identifier {
    if ((self = [super initWithObject:objectType identifier:identifier])) _limit = 100;
    return self;
}

#pragma mark -


@end
