/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNPresenceChannelHereNowResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceChannelHereNowData


#pragma mark - Information

- (id)uuids {
    
    return self.serviceData[@"uuids"];
}

- (NSNumber *)occupancy {
    
    return self.serviceData[@"occupancy"];
}

#pragma mark -


@end



#pragma mark - Interface implementation

@implementation PNPresenceChannelHereNowResult


#pragma mark - Information

- (PNPresenceChannelHereNowData *)data {
    
    return [PNPresenceChannelHereNowData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end
