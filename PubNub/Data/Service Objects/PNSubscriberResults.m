/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "NSDateFormatter+PNCacheable.h"
#import "PNChannelMetadata+Private.h"
#import "PNSubscribeStatus+Private.h"
#import "PNMessageAction+Private.h"
#import "PNUUIDMetadata+Private.h"
#import "PNServiceData+Private.h"
#import "PNMembership+Private.h"
#import "PNSubscriberResults.h"
#import "PNResult+Private.h"

#pragma mark Protected interfaces declaration

@interface PNMessageResult ()


#pragma mark - Properties

@property (nonatomic, strong) PNMessageData *data;

#pragma mark -


@end


@interface PNSignalResult ()


#pragma mark - Properties

@property (nonatomic, strong) PNSignalData *data;

#pragma mark -


@end


@interface PNMessageActionResult ()


#pragma mark - Properties

@property (nonatomic, strong) PNMessageActionData *data;

#pragma mark -


@end


@interface PNPresenceEventResult ()


#pragma mark - Properties

@property (nonatomic, strong) PNPresenceEventData *data;

#pragma mark -


@end


@interface PNObjectEventResult ()


#pragma mark - Properties

@property (nonatomic, strong) PNObjectEventData *data;

#pragma mark -


@end


#pragma mark - Interfaces implementation

@implementation PNPresenceDetailsData


#pragma mark - Infogmration

- (NSNumber *)timetoken {
    return self.serviceData[@"timetoken"];
}

- (NSString *)uuid {
    return self.serviceData[@"uuid"];
}

- (NSArray<NSString *> *)join {
    return self.serviceData[@"join"];
}

- (NSArray<NSString *> *)leave {
    return self.serviceData[@"leave"];
}

- (NSArray<NSString *> *)timeout {
    return self.serviceData[@"timeout"];
}

- (NSNumber *)occupancy {
    return self.serviceData[@"occupancy"];
}

- (NSDictionary<NSString *, id> *)state {
    return self.serviceData[@"state"];
}

#pragma mark -


@end


@implementation PNPresenceEventData


#pragma mark - Information

- (NSString *)presenceEvent {
    return self.serviceData[@"presenceEvent"];
}

- (PNPresenceDetailsData *)presence {
    return [PNPresenceDetailsData dataWithServiceResponse:self.serviceData[@"presence"]];
}

#pragma mark -


@end


@implementation PNMessageData


#pragma mark - Information

- (NSString *)publisher {
    return self.envelope.senderIdentifier;
}

- (id)message {
    return self.serviceData[@"message"];
}

#pragma mark -


@end


@implementation PNSignalData

#pragma mark -

@end


@implementation PNMessageActionData


#pragma mark - Information

- (PNMessageAction *)action {
    return [PNMessageAction actionFromDictionary:self.serviceData[@"action"]];
}

- (NSString *)event {
    return self.serviceData[@"event"];
}

#pragma mark -


@end


@implementation PNObjectEventData


#pragma mark - Information

- (PNChannelMetadata *)channelMetadata {
    if (![self.type isEqualToString:@"channel"]) {
        return nil;
    }

    return [PNChannelMetadata channelMetadataFromDictionary:self.serviceData[@"channel"]];
}

- (PNUUIDMetadata *)uuidMetadata {
    if (![self.type isEqualToString:@"uuid"]) {
        return nil;
    }

    return [PNUUIDMetadata uuidMetadataFromDictionary:self.serviceData[@"uuid"]];
}

- (PNMembership *)membership {
    if (![self.type isEqualToString:@"membership"]) {
        return nil;
    }
    
    return [PNMembership membershipFromDictionary:self.serviceData[@"membership"]];
}

- (NSNumber *)timestamp {
    return @(((NSNumber *)self.serviceData[@"timetoken"]).unsignedLongLongValue / 10000000);
}

- (NSString *)event {
    return self.serviceData[@"event"];
}

- (NSString *)type {
    return self.serviceData[@"type"];
}

#pragma mark -


@end


@implementation PNMessageResult


#pragma mark - Information

- (PNMessageData *)data {
    if (!_data) {
        _data = [PNMessageData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end


@implementation PNSignalResult


#pragma mark - Information

- (PNSignalData *)data {
    if (!_data) {
        _data = [PNSignalData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end


@implementation PNMessageActionResult


#pragma mark - Information

- (PNMessageActionData *)data {
    if (!_data) {
        _data = [PNMessageActionData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end


@implementation PNPresenceEventResult


#pragma mark - Information

- (PNPresenceEventData *)data {
    if (!_data) {
        _data = [PNPresenceEventData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end


@implementation PNObjectEventResult


#pragma mark - Information

- (PNObjectEventData *)data {
    if (!_data) {
        _data = [PNObjectEventData dataWithServiceResponse:self.serviceData];
    }

    return _data;
}

#pragma mark -

@end
