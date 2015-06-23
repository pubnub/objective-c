/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNSubscribeStatus.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNSubscriberData


#pragma mark - Information

- (NSString *)subscribedChannel {
    
    return self.serviceData[@"subscribedChannel"];
}

- (NSString *)actualChannel {
    
    return self.serviceData[@"actualChannel"];
}

- (NSNumber *)timetoken {
    
    return self.serviceData[@"timetoken"];
}

#pragma mark -


@end



@implementation PNSubscribeStatus

@dynamic currentTimetoken, lastTimeToken, subscribedChannels, subscribedChannelGroups;


#pragma mark - Information

- (PNSubscriberData *)data {
    
    return [PNSubscriberData dataWithServiceResponse:self.serviceData];
}

#pragma mark -


@end
