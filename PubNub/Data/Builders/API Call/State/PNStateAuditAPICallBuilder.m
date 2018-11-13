/**
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNStateAuditAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNStateAuditAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNStateAuditAPICallBuilder * (^)(NSString *uuid))uuid {
    
    return ^PNStateAuditAPICallBuilder * (NSString *uuid) {
        [self setValue:uuid forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNStateAuditAPICallBuilder * (^)(NSString *channel))channel {

    return ^PNStateAuditAPICallBuilder * (NSString *channel) {
        return self.channels(@[channel]);
    };
}

- (PNStateAuditAPICallBuilder * (^)(NSArray<NSString *> *channels))channels {

    return ^PNStateAuditAPICallBuilder * (NSArray<NSString *> *channels) {
        [self setValue:channels forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNStateAuditAPICallBuilder * (^)(NSString *channelGroup))channelGroup {
    
    return ^PNStateAuditAPICallBuilder * (NSString *channelGroup) {
        return self.channelGroups(@[channelGroup]);
    };
}

- (PNStateAuditAPICallBuilder * (^)(NSArray<NSString *> *channelGroups))channelGroups {

    return ^PNStateAuditAPICallBuilder * (NSArray<NSString *> *channelGroups) {
        [self setValue:channelGroups forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNGetStateCompletionBlock block))performWithCompletion {
    
    return ^(PNGetStateCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark - 


@end
