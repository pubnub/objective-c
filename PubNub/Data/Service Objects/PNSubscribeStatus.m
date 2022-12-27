/**
 * @author Serhii Mamontov
 * @version 5.2.0
 * @since 4.0.0
 * @copyright © 2010-2022 PubNub, Inc.
 */
#import "PNSubscribeStatus+Private.h"
#import "PNEnvelopeInformation.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"
#import "PNSpaceId.h"


#pragma mark Interface implementation

@implementation PNSubscriberData


#pragma mark - Information

- (NSString *)channel {
    return self.serviceData[@"channel"];
}

- (PNSpaceId *)spaceId {
    return self.envelope.spaceId;
}

- (PNMessageType *)messageType {
    return self.envelope.messageType;
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
