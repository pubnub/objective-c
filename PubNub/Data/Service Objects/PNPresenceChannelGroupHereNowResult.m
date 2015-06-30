/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNPresenceChannelGroupHereNowResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceChannelGroupHereNowData


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPresenceChannelGroupHereNowResult


#pragma mark - Information

- (PNPresenceChannelGroupHereNowData *)data {
    
    return [PNPresenceChannelGroupHereNowData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end
