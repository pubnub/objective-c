/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNSubscribeStatus.h"
#import "PNSubscribeStatus+Private.h"
#import "PNEnvelopeInformation.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNSubscriberData


#pragma mark - Information

- (nullable NSString *)subscribedChannel {
    
    return self.serviceData[@"subscribedChannel"];
}

- (nullable NSString *)actualChannel {
    
    return self.serviceData[@"actualChannel"];
}

- (NSNumber *)timetoken {
    
    return (self.serviceData[@"timetoken"]?: @0);
}

- (NSNumber *)region {
    
    return (self.serviceData[@"region"]?: @0);
}

- (nullable NSDictionary<NSString *, id> *)userMetadata {
    
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
