/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNChannelGroupChannelsResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNChannelGroupChannelsData


#pragma mark - Information

- (NSArray *)channels {
    
    return self.serviceData[@"channels"];
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNChannelGroupChannelsResult


#pragma mark - Information

- (PNChannelGroupChannelsData *)data {
    
    return [PNChannelGroupChannelsData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end
