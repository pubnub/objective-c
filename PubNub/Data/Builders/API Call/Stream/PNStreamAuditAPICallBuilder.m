/**
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNStreamAuditAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNStreamAuditAPICallBuilder


#pragma mark - Configuration

- (PNStreamAuditAPICallBuilder *(^)(NSString *channelGroup))channelGroup {
    
    return ^PNStreamAuditAPICallBuilder* (NSString *channelGroup) {
        
        [self setValue:channelGroup forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNGroupChannelsAuditCompletionBlock block))performWithCompletion {
    
    return ^(PNGroupChannelsAuditCompletionBlock block){ [super performWithBlock:block]; };
}

#pragma mark -


@end
