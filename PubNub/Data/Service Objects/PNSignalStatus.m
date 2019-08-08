/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNSignalStatus.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNSignalStatusData


#pragma mark - Information

- (NSNumber *)timetoken {
    
    return (self.serviceData[@"timetoken"] ?: @0);
}

- (NSString *)information {
    
    return (self.serviceData[@"information"] ?: @"No Information");
}

#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNSignalStatus ()


#pragma mark - Properties

@property (nonatomic, nonnull, strong) PNSignalStatusData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNSignalStatus


#pragma mark - Information

- (PNSignalStatusData *)data {
    
    if (!_data) {
        _data = [PNSignalStatusData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
