/**
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNPublishSizeAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNPublishSizeAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNPublishSizeAPICallBuilder * (^)(NSString *channel))channel {
    
    return ^PNPublishSizeAPICallBuilder * (NSString *channel) {
        [self setValue:channel forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNPublishSizeAPICallBuilder * (^)(id message))message {
    
    return ^PNPublishSizeAPICallBuilder * (id message) {
        [self setValue:message forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNPublishSizeAPICallBuilder * (^)(NSDictionary *metadata))metadata {
    
    return ^PNPublishSizeAPICallBuilder * (NSDictionary *metadata) {
        [self setValue:metadata forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNPublishSizeAPICallBuilder * (^)(BOOL shouldStore))shouldStore {
    
    return ^PNPublishSizeAPICallBuilder * (BOOL shouldStore) {
        [self setValue:@(shouldStore) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNPublishSizeAPICallBuilder * (^)(NSUInteger ttl))ttl {
    
    return ^PNPublishSizeAPICallBuilder * (NSUInteger ttl) {
        [self setValue:@(ttl) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNPublishSizeAPICallBuilder * (^)(BOOL compress))compress {
    
    return ^PNPublishSizeAPICallBuilder * (BOOL compress) {
        [self setValue:@(compress) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNPublishSizeAPICallBuilder * (^)(BOOL))replicate {
    
    return ^PNPublishSizeAPICallBuilder * (BOOL replicate) {
        [self setValue:@(replicate) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNMessageSizeCalculationCompletionBlock block))performWithCompletion {
    
    return ^(PNMessageSizeCalculationCompletionBlock block) {
        [super performWithBlock:block];
    };
}


#pragma mark -


@end
