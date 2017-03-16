/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNClientStateUpdateStatus.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark - Interface implementation

@implementation PNClientStateUpdateData


#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNClientStateUpdateStatus ()


#pragma mark - Properties

@property (nonatomic, nonnull, strong) PNClientStateUpdateData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNClientStateUpdateStatus


#pragma mark - Information

- (PNClientStateUpdateData *)data {
    
    if (!_data) { _data = [PNClientStateUpdateData dataWithServiceResponse:self.serviceData]; }
    return _data;
}

#pragma mark -


@end
