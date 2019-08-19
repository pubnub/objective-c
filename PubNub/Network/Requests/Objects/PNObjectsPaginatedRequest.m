/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNObjectsPaginatedRequest.h"
#import "PNRequest+Private.h"


#pragma mark Interface implementation

@implementation PNObjectsPaginatedRequest


#pragma mark - Information

- (PNRequestParameters *)requestParameters {
    PNRequestParameters *parameters = [super requestParameters];

    if (self.shouldIncludeCount) {
        [parameters addQueryParameter:@"1" forFieldName:@"count"];
    }

    if (self.limit > 0) {
        [parameters addQueryParameter:@(self.limit).stringValue forFieldName:@"limit"];
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
