/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNTimeResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNTimeData


#pragma mark - Information

- (NSNumber *)timetoken {
    
    return self.serviceData[@"timetoken"];
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNTimeResult


#pragma mark - Information

- (PNTimeData *)data {
    
    return [PNTimeData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end
