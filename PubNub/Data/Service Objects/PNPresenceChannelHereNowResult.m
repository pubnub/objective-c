/**
 * @author Serhii Mamontov
 * @version 4.15.8
 * @since 4.0.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNPresenceChannelHereNowResult.h"
#import "PNOperationResult+Private.h"
#import "PNServiceData+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceChannelHereNowData


#pragma mark - Information

- (id)uuids {
    return self.channels.allValues.firstObject[@"uuids"];
}

- (NSDictionary<NSString *,NSDictionary *> *)channels {
    return self.serviceData[@"channels"];
}

- (NSNumber *)totalOccupancy {
    return self.serviceData[@"channels"] ? self.serviceData[@"totalOccupancy"] : @0;
}

- (NSNumber *)occupancy {
    return self.channels.allValues.firstObject[@"occupancy"] ?: @0;
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
    if (!_data) {
        _data = [PNPresenceChannelHereNowData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
