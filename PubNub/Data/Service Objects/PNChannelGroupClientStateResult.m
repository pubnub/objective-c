/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNChannelGroupClientStateResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNChannelGroupClientStateData


#pragma mark - Information

- (NSDictionary *)channels {
    
    return self.serviceData[@"channels"];
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNChannelGroupClientStateResult


#pragma mark - Information

-(PNChannelGroupClientStateData *)data {
    
    return [PNChannelGroupClientStateData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end
