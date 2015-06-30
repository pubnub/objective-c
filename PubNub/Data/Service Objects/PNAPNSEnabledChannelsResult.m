/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNAPNSEnabledChannelsResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNAPNSEnabledChannelsData

#pragma mark - Information

- (NSArray *)channels {
    
    return self.serviceData[@"channels"];
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNAPNSEnabledChannelsResult


#pragma mark - Information

- (PNAPNSEnabledChannelsData *)data {
    
    return [PNAPNSEnabledChannelsData dataWithServiceResponse:self.serviceData];
}

#pragma mark - 


@end
