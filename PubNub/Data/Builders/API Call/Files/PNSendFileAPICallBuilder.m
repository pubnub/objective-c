/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNSendFileAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNSendFileAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNSendFileAPICallBuilder * (^)(NSInputStream *stream, NSUInteger size))stream {
    return ^PNSendFileAPICallBuilder * (NSInputStream *stream, NSUInteger size) {
        if ([stream isKindOfClass:[NSInputStream class]]) {
            [self setValue:stream forParameter:@"stream"];
            [self setValue:@(size) forParameter:@"size"];
        }
        
        return self;
    };
}

- (PNSendFileAPICallBuilder * (^)(NSDictionary *metadata))fileMessageMetadata {
    return ^PNSendFileAPICallBuilder * (NSDictionary *metadata) {
        if ([metadata isKindOfClass:[NSDictionary class]]) {
            [self setValue:metadata forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSendFileAPICallBuilder * (^)(NSUInteger ttl))fileMessageTTL {
    return ^PNSendFileAPICallBuilder * (NSUInteger ttl) {
        [self setValue:@(ttl) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNSendFileAPICallBuilder * (^)(BOOL store))fileMessageStore {
    return ^PNSendFileAPICallBuilder * (BOOL store) {
        [self setValue:@(store) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNSendFileAPICallBuilder * (^)(NSString *key))cipherKey {
    return ^PNSendFileAPICallBuilder * (NSString *key) {
        if ([key isKindOfClass:[NSString class]]) {
            [self setValue:key forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSendFileAPICallBuilder * (^)(id message))message {
    return ^PNSendFileAPICallBuilder * (id message) {
        [self setValue:message forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNSendFileAPICallBuilder * (^)(NSData *data))data {
    return ^PNSendFileAPICallBuilder * (NSData *data) {
        if ([data isKindOfClass:[NSData class]]) {
            [self setValue:data forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSendFileAPICallBuilder * (^)(NSURL *url))url {
    return ^PNSendFileAPICallBuilder * (NSURL *url) {
        if ([url isKindOfClass:[NSURL class]]) {
            [self setValue:url forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

#pragma mark - Execution

- (void(^)(PNSendFileCompletionBlock block))performWithCompletion {
    return ^(PNSendFileCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
