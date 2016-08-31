/**
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNAPNSModificationAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNAPNSModificationAPICallBuilder


#pragma mark - Configuration

- (PNAPNSModificationAPICallBuilder *(^)(NSData *token))token {
    
    return ^PNAPNSModificationAPICallBuilder* (NSData *token) {
        
        [self setValue:token forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNAPNSModificationAPICallBuilder *(^)(NSArray<NSString *> *channels))channels {
    
    return ^PNAPNSModificationAPICallBuilder* (NSArray<NSString *> *channels) {
        
        [self setValue:channels forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNPushNotificationsStateModificationCompletionBlock block))performWithCompletion {
    
    return ^(PNPushNotificationsStateModificationCompletionBlock block){ [super performWithBlock:block]; };
}

#pragma mark -


@end
