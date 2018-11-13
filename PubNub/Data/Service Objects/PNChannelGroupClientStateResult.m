/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNChannelGroupClientStateResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark - Interface implementation

@implementation PNChannelGroupClientStateData


#pragma mark - Information

- (NSDictionary<NSString *, NSDictionary *> *)channels {
    
    return (self.serviceData[@"channels"]?: @{});
}

#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNChannelGroupClientStateResult ()


#pragma mark - Properties

@property (nonatomic, nonnull, strong) PNChannelGroupClientStateData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNChannelGroupClientStateResult


#pragma mark - Information

- (PNChannelGroupClientStateData *)data {
    
    if (!_data) { _data = [PNChannelGroupClientStateData dataWithServiceResponse:self.serviceData]; }
    return _data;
}

#pragma mark -


@end
