/**
 * @author Serhii Mamontov
 * @since 4.7.5
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNPresenceHeartbeatAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceHeartbeatAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNPresenceHeartbeatAPICallBuilder * (^)(NSArray<NSString *> *channels))channels {

    return ^PNPresenceHeartbeatAPICallBuilder * (NSArray<NSString *> *channels) {
        if ([channels isKindOfClass:[NSArray class]]) {
            [self setValue:channels forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNPresenceHeartbeatAPICallBuilder * (^)(NSArray<NSString *> *channelGroups))channelGroups {

    return ^PNPresenceHeartbeatAPICallBuilder * (NSArray<NSString *> *channelGroups) {
        if ([channelGroups isKindOfClass:[NSArray class]]) {
            [self setValue:channelGroups forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNPresenceHeartbeatAPICallBuilder * (^)(NSDictionary<NSString *, NSDictionary *> *state))state {

    return ^PNPresenceHeartbeatAPICallBuilder * (NSDictionary<NSString *, NSDictionary *> *state) {
        if ([state isKindOfClass:[NSDictionary class]]) {
            [self setValue:state forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNStatusBlock block))performWithCompletion {

    return ^(PNStatusBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
