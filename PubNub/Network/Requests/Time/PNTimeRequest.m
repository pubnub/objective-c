#import "PNTimeRequest.h"
#import "PNBaseRequest+Private.h"


#pragma mark Interface implementation

@implementation PNTimeRequest


#pragma mark - Parameters

- (PNOperationType)operation {
    return PNTimeOperation;
}

- (NSDictionary *)query {
    NSMutableDictionary *query = [([super query] ?: @{}) mutableCopy];

    if (self.arbitraryQueryParameters.count) [query addEntriesFromDictionary:self.arbitraryQueryParameters];

    return query.count ? query : nil;
}

- (NSString *)path {
    return @"/time/0";
}


#pragma mark - Prepare

- (PNError *)validate {
    return nil;
}

#pragma mark -


@end
