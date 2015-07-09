/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNErrorStatus+Private.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark - Interface implementation

@implementation PNErrorData

- (NSArray *)channels {
    
    return self.serviceData[@"channels"];
}

- (NSArray *)channelGroups {
    
    return self.serviceData[@"channelGroups"];
}

- (NSString *)information {
    
    return self.serviceData[@"information"];
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
    
    return [PNErrorData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end
