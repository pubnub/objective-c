/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNAPNSEnabledChannelsResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNAPNSEnabledChannelsData

#pragma mark - Information

- (NSArray<NSString *> *)channels {
    
    return (self.serviceData[@"channels"]?: @[]);
}

#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNAPNSEnabledChannelsResult ()


#pragma mark - Properties

@property (nonatomic, nonnull, strong) PNAPNSEnabledChannelsData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNAPNSEnabledChannelsResult


#pragma mark - Information

- (PNAPNSEnabledChannelsData *)data {
    
    if (!_data) { _data = [PNAPNSEnabledChannelsData dataWithServiceResponse:self.serviceData]; }
    return _data;
}

#pragma mark - 


@end
