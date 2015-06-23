/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNClientStateUpdateStatus.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNClientStateUpdateData


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNClientStateUpdateStatus


#pragma mark - Information

- (PNChannelClientStateData *)data {
    
    return [PNChannelClientStateData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end
