/**
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNAPNSAuditAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNAPNSAuditAPICallBuilder


#pragma mark - Configuration

- (PNAPNSAuditAPICallBuilder *(^)(NSData *token))token {
    
    return ^PNAPNSAuditAPICallBuilder* (NSData *token) {
        
        [self setValue:token forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNPushNotificationsStateAuditCompletionBlock block))performWithCompletion {
    
    return ^(PNPushNotificationsStateAuditCompletionBlock block) { [super performWithBlock:block]; };
}

#pragma mark -


@end
