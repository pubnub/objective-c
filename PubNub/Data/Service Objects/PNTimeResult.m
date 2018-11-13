/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNTimeResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark - Interface implementation

@implementation PNTimeData


#pragma mark - Information

- (NSNumber *)timetoken {
    
    return (self.serviceData[@"timetoken"]?: @0);
}

#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNTimeResult ()


#pragma mark - Properties

@property (nonatomic, strong) PNTimeData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNTimeResult


#pragma mark - Information

- (PNTimeData *)data {
    
    if (!_data) { _data = [PNTimeData dataWithServiceResponse:self.serviceData]; }
    return _data;
}

#pragma mark -


@end
