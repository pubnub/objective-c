/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PNSubscribeStatus.h"
#import "PNSubscribeStatus+Private.h"
#import "PNEnvelopeInformation.h"
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

- (NSNumber *)region {
    
    return self.serviceData[@"region"];
}

- (NSDictionary *)userMetadata {
    
    return self.envelope.metadata;
}

- (PNEnvelopeInformation *)envelope {
    
    return self.serviceData[@"envelope"];
}

#pragma mark -


@end



@implementation PNSubscribeStatus

@dynamic currentTimetoken, lastTimeToken, subscribedChannels, subscribedChannelGroups;


#pragma mark - Information

- (PNSubscriberData *)data {
    
    if (!_data) { _data = [PNSubscriberData dataWithServiceResponse:self.serviceData]; }
    return _data;
}

#pragma mark -


@end
