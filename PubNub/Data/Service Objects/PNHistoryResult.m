/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNHistoryResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNHistoryData


#pragma mark - Information

- (NSArray *)messages {
    
    return self.serviceData[@"messages"];
}

- (NSNumber *)start {
    
    return self.serviceData[@"start"];
}

- (NSNumber *)end {
    
    return self.serviceData[@"end"];
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNHistoryResult


#pragma mark - Information

- (PNHistoryData *)data {
    
    return [PNHistoryData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end
