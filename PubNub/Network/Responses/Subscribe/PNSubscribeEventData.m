#import "PNSubscribeEventData+Private.h"
#import <PubNub/PNCodable.h>
#import "PNHelpers.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// General real-time subscription update private extension.
@interface PNSubscribeEventData () <PNCodable>


#pragma mark - Properties

/// Actual name of subscription through which event has been delivered.
///
/// Actual name of subscription through which event has been delivered.PubNub client can be used to subscribe to the
/// group of channels to receive updates and (group name will be set for field). With this approach there will be no
/// need to separately add *N* number of channels to `subscribe` method call.
@property(strong, nonatomic) NSString *subscription;

/// Name of channel where update received.
@property(strong, nonatomic) NSString *channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSubscribeEventData


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"shardIdentifier": @"a",
        @"debugFlags": @"f",
        @"messageType": @"e",
        @"senderIdentifier": @"i",
        @"sequenceNumber": @"s",
        @"publishTimetoken": @"p",
        @"userTimetoken": @"o",
        @"channel": @"c",
        @"subscription": @"b",
        @"userMetadata": @"mt",
    };
}

+ (NSArray<NSString *> *)optionalKeys {
    return @[
        @"messageType",
        @"senderIdentifier",
        @"sequenceNumber",
        @"userTimetoken",
        @"subscription",
        @"userMetadata"
    ];
}

+ (NSArray<NSString *> *)ignoredKeys {
    return @[@"timetoken"];
}

- (NSString *)subscription {
    return _subscription ? [PNChannel channelForPresence:_subscription] : self.channel;
}

- (NSNumber *)timetoken {
    return self.publishTimetoken.timetoken;
}

- (NSString *)channel {
    return [PNChannel channelForPresence:_channel];
}

- (NSNumber *)region {
    return self.publishTimetoken.reqion;
}

#pragma mark -


@end
