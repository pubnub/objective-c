/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNChannelGroupChannelsResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark - Interface implementation

@implementation PNChannelGroupChannelsData


#pragma mark - Information

- (NSArray<NSString *> *)channels {
    
    return (self.serviceData[@"channels"]?: @[]);
}

#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNChannelGroupChannelsResult ()


#pragma mark - Properties

@property (nonatomic, nonnull, strong) PNChannelGroupChannelsData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNChannelGroupChannelsResult


#pragma mark - Information

- (PNChannelGroupChannelsData *)data {
    
    if (!_data) { _data = [PNChannelGroupChannelsData dataWithServiceResponse:self.serviceData]; }
    return _data;
}

#pragma mark -


@end
