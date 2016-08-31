/**
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNStateAuditAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNStateAuditAPICallBuilder


#pragma mark - Configuration

- (PNStateAuditAPICallBuilder *(^)(NSString *uuid))uuid {
    
    return ^PNStateAuditAPICallBuilder* (NSString *uuid) {
        
        [self setValue:uuid forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNStateAuditAPICallBuilder *(^)(NSString *channel))channel {
    
    return ^PNStateAuditAPICallBuilder* (NSString *channel) {
        
        [self setValue:channel forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNStateAuditAPICallBuilder *(^)(NSString *channelGroup))channelGroup {
    
    return ^PNStateAuditAPICallBuilder* (NSString *channelGroup) {
        
        [self setValue:channelGroup forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNChannelStateCompletionBlock block))performWithCompletion {
    
    return ^(PNChannelStateCompletionBlock block){ [super performWithBlock:block]; };
}

#pragma mark - 


@end
