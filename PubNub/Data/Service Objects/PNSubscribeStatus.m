/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNSubscribeStatus+Private.h"
#import "PNEnvelopeInformation.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNSubscriberData


#pragma mark - Information

- (NSString *)channel {
    
    return self.serviceData[@"channel"];
}

- (NSString *)subscription {
    
    return self.serviceData[@"subscription"];
}

- (NSNumber *)timetoken {
    
    return (self.serviceData[@"timetoken"]?: @0);
}

- (NSNumber *)region {
    
    return (self.serviceData[@"region"]?: @0);
}

- (NSDictionary<NSString *, id> *)userMetadata {
    
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
