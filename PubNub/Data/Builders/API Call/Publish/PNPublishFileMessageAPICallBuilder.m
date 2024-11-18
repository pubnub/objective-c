/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNPublishFileMessageAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNPublishFileMessageAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNPublishFileMessageAPICallBuilder * (^)(NSString *fileIdentifier))fileIdentifier {
    return ^PNPublishFileMessageAPICallBuilder * (NSString *fileIdentifier) {
        if ([fileIdentifier isKindOfClass:[NSString class]]) {
            [self setValue:fileIdentifier forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNPublishFileMessageAPICallBuilder * (^)(NSString *fileName))fileName {
    return ^PNPublishFileMessageAPICallBuilder * (NSString *fileName) {
        if ([fileName isKindOfClass:[NSString class]]) {
            [self setValue:fileName forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNPublishFileMessageAPICallBuilder * (^)(NSString *channel))channel {
    return ^PNPublishFileMessageAPICallBuilder * (NSString *channel) {
        if ([channel isKindOfClass:[NSString class]]) {
            [self setValue:channel forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNPublishFileMessageAPICallBuilder * (^)(id message))message {
    return ^PNPublishFileMessageAPICallBuilder * (id message) {
        [self setValue:message forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNPublishFileMessageAPICallBuilder * (^)(NSString *customMessageType))customMessageType {
    return ^PNPublishFileMessageAPICallBuilder * (NSString *customMessageType) {
        if ([customMessageType isKindOfClass:[NSString class]]) {
            [self setValue:customMessageType forParameter:NSStringFromSelector(_cmd)];
        }

        return self;
    };
}

- (PNPublishFileMessageAPICallBuilder * (^)(NSDictionary *metadata))metadata {
    return ^PNPublishFileMessageAPICallBuilder * (NSDictionary *metadata) {
        if ([metadata isKindOfClass:[NSDictionary class]]) {
            [self setValue:metadata forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNPublishFileMessageAPICallBuilder * (^)(BOOL shouldStore))shouldStore {
    return ^PNPublishFileMessageAPICallBuilder * (BOOL shouldStore) {
        [self setValue:@(shouldStore) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNPublishFileMessageAPICallBuilder * (^)(NSUInteger ttl))ttl {
    return ^PNPublishFileMessageAPICallBuilder * (NSUInteger ttl) {
        [self setValue:@(ttl) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNPublishFileMessageAPICallBuilder * (^)(BOOL))replicate {
    return ^PNPublishFileMessageAPICallBuilder * (BOOL replicate) {
        [self setValue:@(replicate) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNPublishCompletionBlock block))performWithCompletion {
    return ^(PNPublishCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
