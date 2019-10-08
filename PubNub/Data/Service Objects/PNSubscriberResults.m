/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "NSDateFormatter+PNCacheable.h"
#import "PNSubscribeStatus+Private.h"
#import "PNMessageAction+Private.h"
#import "PNServiceData+Private.h"
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


@interface PNMembershipEventResult ()


#pragma mark - Properties

@property (nonatomic, strong) PNMembershipEventData *data;

#pragma mark -


@end


@interface PNSpaceEventResult ()


#pragma mark - Properties

@property (nonatomic, strong) PNSpaceEventData *data;

#pragma mark -


@end


@interface PNUserEventResult ()


#pragma mark - Properties

@property (nonatomic, strong) PNUserEventData *data;

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


@implementation PNMembershipEventData


#pragma mark - Information

- (NSNumber *)timestamp {
    return @(((NSNumber *)self.serviceData[@"timetoken"]).unsignedLongLongValue/10000000);
}

- (NSString *)spaceId {
    return self.serviceData[@"membership"][@"spaceId"];
}

- (NSString *)userId {
    return self.serviceData[@"membership"][@"userId"];
}

- (NSDictionary *)custom {
    return self.serviceData[@"membership"][@"custom"];
}

- (NSDate *)created {
    NSString *dateString = self.serviceData[@"membership"][@"created"];
    
    return dateString ? [[NSDateFormatter pn_objectsDateFormatter] dateFromString:dateString] : nil;
}

- (NSDate *)updated {
    NSString *dateString = self.serviceData[@"membership"][@"updated"];
    
    return dateString ? [[NSDateFormatter pn_objectsDateFormatter] dateFromString:dateString] : nil;
}

- (NSString *)event {
    return self.serviceData[@"event"];
}

- (NSString *)eTag {
    return self.serviceData[@"membership"][@"eTag"];
}

#pragma mark -


@end


@implementation PNSpaceEventData


#pragma mark - Information

- (NSArray<NSString *> *)modifiedFields {
    return self.serviceData[@"updatedFields"];
}

- (NSDictionary *)custom {
    return self.serviceData[@"space"][@"custom"];
}

- (NSString *)information {
    return self.serviceData[@"space"][@"information"];
}

- (NSString *)identifier {
    return self.serviceData[@"space"][@"id"];
}

- (NSNumber *)timestamp {
    return @(((NSNumber *)self.serviceData[@"timetoken"]).unsignedLongLongValue/10000000);
}

- (NSString *)event {
    return self.serviceData[@"event"];
}

- (NSDate *)updated {
    NSString *dateString = self.serviceData[@"space"][@"updated"];
    
    return dateString ? [[NSDateFormatter pn_objectsDateFormatter] dateFromString:dateString] : nil;
}

- (NSString *)name {
    return self.serviceData[@"space"][@"name"];
}

- (NSString *)eTag {
    return self.serviceData[@"space"][@"eTag"];
}

#pragma mark -


@end


@implementation PNUserEventData


#pragma mark - Information

- (NSArray<NSString *> *)modifiedFields {
    return self.serviceData[@"updatedFields"];
}

- (NSString *)externalId {
    return self.serviceData[@"user"][@"externalId"];
}

- (NSString *)profileUrl {
    return self.serviceData[@"user"][@"profileUrl"];
}

- (NSDictionary *)custom {
    return self.serviceData[@"user"][@"custom"];
}

- (NSString *)identifier {
    return self.serviceData[@"user"][@"id"];
}

- (NSNumber *)timestamp {
    return @(((NSNumber *)self.serviceData[@"timetoken"]).unsignedLongLongValue/10000000);
}

- (NSString *)email {
    return self.serviceData[@"user"][@"email"];
}

- (NSString *)event {
    return self.serviceData[@"event"];
}

- (NSDate *)updated {
    NSString *dateString = self.serviceData[@"user"][@"updated"];
    
    return dateString ? [[NSDateFormatter pn_objectsDateFormatter] dateFromString:dateString] : nil;
}

- (NSString *)name {
    return self.serviceData[@"user"][@"name"];
}

- (NSString *)eTag {
    return self.serviceData[@"user"][@"eTag"];
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


@implementation PNMembershipEventResult


#pragma mark - Information

- (PNMembershipEventData *)data {
    if (!_data) {
        _data = [PNMembershipEventData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end


@implementation PNSpaceEventResult


#pragma mark - Information

- (PNSpaceEventData *)data {
    if (!_data) {
        _data = [PNSpaceEventData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end


@implementation PNUserEventResult


#pragma mark - Information

- (PNUserEventData *)data {
    if (!_data) {
        _data = [PNUserEventData dataWithServiceResponse:self.serviceData];
    }
    
    return _data;
}

#pragma mark -


@end
