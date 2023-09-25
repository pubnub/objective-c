/**
 * @author Serhii Mamontov
 * @version 4.15.8
 * @since 4.0.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNPresenceChannelGroupHereNowResult.h"
#import "PNOperationResult+Private.h"
#import "PNServiceData+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceChannelGroupHereNowData


#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNPresenceChannelGroupHereNowResult ()


#pragma mark - Properties

@property (nonatomic, nonnull, strong) PNPresenceChannelGroupHereNowData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPresenceChannelGroupHereNowResult


#pragma mark - Information

- (PNPresenceChannelGroupHereNowData *)data {
    if (!_data) {
        _data = [PNPresenceChannelGroupHereNowData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
