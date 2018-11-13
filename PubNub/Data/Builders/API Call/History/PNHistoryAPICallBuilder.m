/**
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "PNHistoryAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNHistoryAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNHistoryAPICallBuilder * (^)(NSString *channel))channel {
    
    return ^PNHistoryAPICallBuilder * (NSString *channel) {
        [self setValue:channel forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNHistoryAPICallBuilder * (^)(NSArray<NSString *> *))channels {
    
    return ^PNHistoryAPICallBuilder * (NSArray<NSString *> *channels) {
        [self setValue:channels forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNHistoryAPICallBuilder * (^)(NSNumber *start))start {
    
    return ^PNHistoryAPICallBuilder * (NSNumber *start) {
        [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNHistoryAPICallBuilder * (^)(NSNumber *end))end {
    
    return ^PNHistoryAPICallBuilder * (NSNumber *end) {
        [self setValue:end forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNHistoryAPICallBuilder * (^)(NSUInteger limit))limit {
    
    return ^PNHistoryAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNHistoryAPICallBuilder * (^)(BOOL includeTimeToken))includeTimeToken {
    
    return ^PNHistoryAPICallBuilder * (BOOL includeTimeToken) {
        [self setValue:@(includeTimeToken) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNHistoryAPICallBuilder * (^)(BOOL reverse))reverse {
    
    return ^PNHistoryAPICallBuilder * (BOOL reverse) {
        [self setValue:@(reverse) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNHistoryCompletionBlock block))performWithCompletion {
    
    return ^(PNHistoryCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
