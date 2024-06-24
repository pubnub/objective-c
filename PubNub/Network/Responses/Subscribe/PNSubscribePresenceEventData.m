#import "PNSubscribePresenceEventData.h"
#import <PubNub/PNCodable.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// `Presence event` details private extension.
@interface PNSubscribePresenceEventDetails () <PNCodable>


#pragma mark -


@end


#pragma mark - Private interface implementation

/// `Presence event` data private extension.
@interface PNSubscribePresenceEventData () <PNCodable>


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSubscribePresenceEventDetails


#pragma mark - Properies

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{
        @"timetoken": @"timestamp",
        @"uuid": @"uuid",
        @"join": @"join",
        @"leave": @"leave",
        @"timeout": @"timeout",
        @"occupancy": @"occupancy",
        @"state": @"state",
    };
}

+ (NSArray<NSString *> *)optionalKeys {
    return @[@"uuid", @"join", @"leave", @"timeout"];
}

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNSubscribePresenceEventData


#pragma mark - Properties

+ (NSDictionary<NSString *,NSString *> *)codingKeys {
    return @{ @"presenceEvent":@"action", @"presence":@"presence" };
}

#pragma mark -

@end
