/**
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNStateModificationAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNStateModificationAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNStateModificationAPICallBuilder * (^)(NSString *uuid))uuid {
    
    return ^PNStateModificationAPICallBuilder * (NSString *uuid) {
        [self setValue:uuid forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNStateModificationAPICallBuilder * (^)(NSDictionary *state))state {
    
    return ^PNStateModificationAPICallBuilder * (NSDictionary *state) {
        [self setValue:state forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNStateModificationAPICallBuilder * (^)(NSString *channel))channel {

    return ^PNStateModificationAPICallBuilder * (NSString *channel) {
        return self.channels(@[channel]);
    };
}

- (PNStateModificationAPICallBuilder * (^)(NSArray<NSString *> *channels))channels {

    return ^PNStateModificationAPICallBuilder * (NSArray<NSString *> *channels) {
        [self setValue:channels forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNStateModificationAPICallBuilder * (^)(NSString *channelGroup))channelGroup {
    
    return ^PNStateModificationAPICallBuilder * (NSString *channelGroup) {
        return self.channelGroups(@[channelGroup]);
    };
}

- (PNStateModificationAPICallBuilder * (^)(NSArray<NSString *> *channelGroups))channelGroups {

    return ^PNStateModificationAPICallBuilder * (NSArray<NSString *> *channelGroups) {
        [self setValue:channelGroups forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNSetStateCompletionBlock block))performWithCompletion {
    
    return ^(PNSetStateCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark - 


@end
