/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNPresenceChannelHereNowResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceChannelHereNowData


#pragma mark - Information

- (nullable id)uuids {
    
    return self.serviceData[@"uuids"];
}

- (NSNumber *)occupancy {
    
    return (self.serviceData[@"occupancy"]?: @0);
}

#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNPresenceChannelHereNowResult ()


#pragma mark - Properties

@property (nonatomic, nonnull, strong) PNPresenceChannelHereNowData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPresenceChannelHereNowResult


#pragma mark - Information

- (PNPresenceChannelHereNowData *)data {
    
    if (!_data) { _data = [PNPresenceChannelHereNowData dataWithServiceResponse:self.serviceData]; }
    return _data;
}

#pragma mark -


@end
