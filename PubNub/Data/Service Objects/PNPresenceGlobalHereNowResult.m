/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNPresenceGlobalHereNowResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceGlobalHereNowData


#pragma mark - Information

- (NSDictionary *)channels {
    
    return self.serviceData[@"channels"];
}

- (NSNumber *)totalChannels {
    
    return self.serviceData[@"totalChannels"];
}

- (NSNumber *)totalOccupancy {
    
    return self.serviceData[@"totalOccupancy"];
}

#pragma mark -


@end

#pragma mark - Interface implementation

@implementation PNPresenceGlobalHereNowResult


#pragma mark - Information

- (PNPresenceGlobalHereNowData *)data {
    
    return [PNPresenceGlobalHereNowData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end
