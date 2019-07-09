/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNSignalStatus.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNSignalData


#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNSignalStatus ()


#pragma mark - Properties

@property (nonatomic, nonnull, strong) PNSignalData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNSignalStatus


#pragma mark - Information

- (PNSignalData *)data {
    
    if (!_data) {
        _data = [PNSignalData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
