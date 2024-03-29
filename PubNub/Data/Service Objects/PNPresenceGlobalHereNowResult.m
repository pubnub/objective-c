/**
 * @author Serhii Mamontov
 * @version 4.15.8
 * @since 4.0.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNPresenceGlobalHereNowResult.h"
#import "PNOperationResult+Private.h"
#import "PNServiceData+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceGlobalHereNowData


#pragma mark - Information

- (NSDictionary<NSString *, NSDictionary *> *)channels {
    return self.serviceData[@"channels"] ?: @{};
}

- (NSNumber *)totalChannels {
    return self.serviceData[@"totalChannels"] ?: @0;
}

- (NSNumber *)totalOccupancy {
    return self.serviceData[@"totalOccupancy"] ?: @0;
}

#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNPresenceGlobalHereNowResult ()


#pragma mark - Properties

@property (nonatomic, nonnull, strong) PNPresenceGlobalHereNowData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPresenceGlobalHereNowResult


#pragma mark - Information

- (PNPresenceGlobalHereNowData *)data {
    if (!_data) {
        _data = [PNPresenceGlobalHereNowData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
