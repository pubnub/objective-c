/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNSubscriberResults.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceDetailsData


#pragma mark - Infogmration

- (NSNumber *)timetoken {
    
    return self.serviceData[@"timetoken"];
}

- (NSString *)uuid {
    
    return self.serviceData[@"uuid"];
}

- (NSNumber *)occupancy {
    
    return self.serviceData[@"occupancy"];
}

- (NSDictionary *)state {
    
    return self.serviceData[@"state"];
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPresenceEventData


#pragma mark - Information

- (NSString *)presenceEvent {
    
    return self.serviceData[@"presenceEvent"];
}

- (PNPresenceDetailsData *)presence {
    
    return [PNPresenceDetailsData dataWithServiceResponse:self.serviceData[@"presence"]];
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNMessageData


#pragma mark - Information

- (id)message {
    
    return self.serviceData[@"message"];
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNMessageResult


#pragma mark - Information

- (PNMessageData *)data {
    
    return [PNMessageData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPresenceEventResult


#pragma mark - Information

- (PNPresenceEventData *)data {
    
    return [PNPresenceEventData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end
