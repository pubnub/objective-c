/**
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc. 
 */
#import "PNBaseObjectsRequest+Private.h"
#import "PNObjectsPaginatedRequest.h"
#import "PNRequest+Private.h"
#import "PNHelpers.h"


#pragma mark Interface implementation

@implementation PNObjectsPaginatedRequest


#pragma mark - Information

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];

    if (self.parametersError) {
        return parameters;
    }
    
    if ((self.includeFields & PNChannelTotalCountField) == PNChannelTotalCountField ||
        (self.includeFields & PNUUIDTotalCountField) == PNUUIDTotalCountField ||
        (self.includeFields & PNMembershipTotalCountField) == PNMembershipTotalCountField ||
        (self.includeFields & PNMemberTotalCountField) == PNMemberTotalCountField) {

        [parameters addQueryParameter:@"1" forFieldName:@"count"];
    }

    if (self.limit > 0) {
        [parameters addQueryParameter:@(self.limit).stringValue forFieldName:@"limit"];
    }
    
    if (self.sort.count > 0) {
        NSMutableArray *percentEncodedSort = [NSMutableArray new];
        
        for (NSString *criteria in self.sort) {
            [percentEncodedSort addObject:[PNString percentEscapedString:criteria]];
        }
        
        [parameters addQueryParameter:[percentEncodedSort componentsJoinedByString:@","]
                         forFieldName:@"sort"];
    }

    if (self.filter.length > 0) {
        [parameters addQueryParameter:[PNString percentEscapedString:self.filter]
                         forFieldName:@"filter"];
    }

    if (self.start.length) {
        [parameters addQueryParameter:self.start forFieldName:@"start"];
    }

    if (self.end.length) {
        [parameters addQueryParameter:self.end forFieldName:@"end"];
    }

    return parameters;
}

#pragma mark -


@end
