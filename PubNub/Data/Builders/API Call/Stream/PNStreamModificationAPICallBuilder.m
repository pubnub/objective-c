/**
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNStreamModificationAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNStreamModificationAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNStreamModificationAPICallBuilder * (^)(NSString *channelGroup))channelGroup {
    
    return ^PNStreamModificationAPICallBuilder * (NSString *channelGroup) {
        [self setValue:channelGroup forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNStreamModificationAPICallBuilder * (^)(NSArray<NSString *> *channels))channels {
    
    return ^PNStreamModificationAPICallBuilder * (NSArray<NSString *> *channels) {
        [self setValue:channels forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNChannelGroupChangeCompletionBlock block))performWithCompletion {
    
    return ^(PNChannelGroupChangeCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
