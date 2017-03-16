/**
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNPublishAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNPublishAPICallBuilder


#pragma mark - Configuration

- (PNPublishAPICallBuilder *(^)(NSString *channel))channel {
    
    return ^PNPublishAPICallBuilder* (NSString *channel) {
        
        [self setValue:channel forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNPublishAPICallBuilder *(^)(id message))message {
    
    return ^PNPublishAPICallBuilder* (id message) {
        
        [self setValue:message forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNPublishAPICallBuilder *(^)(NSDictionary *metadata))metadata {
    
    return ^PNPublishAPICallBuilder* (NSDictionary *metadata) {
        
        [self setValue:metadata forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNPublishAPICallBuilder *(^)(BOOL shouldStore))shouldStore {
    
    return ^PNPublishAPICallBuilder* (BOOL shouldStore) {
        
        [self setValue:@(shouldStore) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNPublishAPICallBuilder *(^)(NSUInteger ttl))ttl {
    
    return ^PNPublishAPICallBuilder* (NSUInteger ttl) {
        
        [self setValue:@(ttl) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNPublishAPICallBuilder *(^)(BOOL compress))compress {
    
    return ^PNPublishAPICallBuilder* (BOOL compress) {
        
        [self setValue:@(compress) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNPublishAPICallBuilder *(^)(BOOL))replicate {
    
    return ^PNPublishAPICallBuilder* (BOOL replicate) {
        
        [self setValue:@(replicate) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNPublishAPICallBuilder *(^)(NSDictionary *payload))payloads {
    
    return ^PNPublishAPICallBuilder* (NSDictionary *payload) {
        
        [self setValue:payload forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNPublishCompletionBlock block))performWithCompletion {
    
    return ^(PNPublishCompletionBlock block){ [super performWithBlock:block]; };
}

#pragma mark -


@end
