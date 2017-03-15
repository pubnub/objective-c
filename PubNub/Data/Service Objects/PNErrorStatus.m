/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNErrorStatus+Private.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNErrorData

- (NSArray<NSString *> *)channels {
    
    return (self.serviceData[@"channels"]?: @[]);
}

- (NSArray<NSString *> *)channelGroups {
    
    return (self.serviceData[@"channelGroups"]?: @[]);
}

- (NSString *)information {
    
    return (self.serviceData[@"information"]?: @"No Error Information");
}

- (id)data {
    
    return self.serviceData[@"data"];
}

#pragma mark -


@end


@implementation PNErrorStatus


#pragma mark - Information

- (id)copyWithZone:(NSZone *)zone {
    
    PNErrorStatus *status = [super copyWithZone:zone];
    status.associatedObject = self.associatedObject;
    
    return status;
}

- (PNErrorData *)errorData {
    
    if (!_errorData) { _errorData = [PNErrorData dataWithServiceResponse:self.serviceData]; }
    return _errorData;
}

#pragma mark -


@end
