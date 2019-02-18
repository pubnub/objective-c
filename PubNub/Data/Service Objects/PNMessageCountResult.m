/**
 * @since 4.8.4
 *
 * @author Sergey Mamontov
 * @version 4.8.3
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNMessageCountResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNMessageCountData


#pragma mark - Information

- (NSDictionary<NSString *,NSNumber *> *)channels {
    
    return (self.serviceData[@"channels"] ?: @{});
}

#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNMessageCountResult ()


#pragma mark - Information

@property (nonatomic, strong) PNMessageCountData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNMessageCountResult


#pragma mark - Information

- (PNMessageCountData *)data {
    
    if (!_data) {
        _data = [PNMessageCountData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
