/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
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

- (nullable NSString *)uuid {
    
    return self.serviceData[@"uuid"];
}

- (NSNumber *)occupancy {
    
    return self.serviceData[@"occupancy"];
}

- (nullable NSDictionary<NSString *, id> *)state {
    
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

- (nullable id)message {
    
    return self.serviceData[@"message"];
}

#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNMessageResult ()


#pragma mark - Properties

@property (nonatomic, strong) PNMessageData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNMessageResult


#pragma mark - Information

- (PNMessageData *)data {
    
    if (!_data) { _data = [PNMessageData dataWithServiceResponse:self.serviceData]; }
    return _data;
}

#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNPresenceEventResult ()


#pragma mark - Properties

@property (nonatomic, strong) PNPresenceEventData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPresenceEventResult


#pragma mark - Information

- (PNPresenceEventData *)data {
    
    if (!_data) { _data = [PNPresenceEventData dataWithServiceResponse:self.serviceData]; }
    return _data;
}

#pragma mark -


@end
