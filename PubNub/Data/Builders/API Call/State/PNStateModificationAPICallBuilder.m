/**
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNStateModificationAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNStateModificationAPICallBuilder


#pragma mark - Configuration

- (PNStateModificationAPICallBuilder *(^)(NSString *uuid))uuid {
    
    return ^PNStateModificationAPICallBuilder* (NSString *uuid) {
        
        [self setValue:uuid forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNStateModificationAPICallBuilder *(^)(NSDictionary *state))state {
    
    return ^PNStateModificationAPICallBuilder* (NSDictionary *state) {
        
        [self setValue:state forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNStateModificationAPICallBuilder *(^)(NSString *channel))channel {
    
    return ^PNStateModificationAPICallBuilder* (NSString *channel) {
        
        [self setValue:channel forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNStateModificationAPICallBuilder *(^)(NSString *channelGroup))channelGroup {
    
    return ^PNStateModificationAPICallBuilder* (NSString *channelGroup) {
        
        [self setValue:channelGroup forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNSetStateCompletionBlock block))performWithCompletion {
    
    return ^(PNSetStateCompletionBlock block){ [super performWithBlock:block]; };
}

#pragma mark - 


@end
