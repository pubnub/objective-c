/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNFetchMessagesActionsAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNFetchMessagesActionsAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNFetchMessagesActionsAPICallBuilder * (^)(NSString *channel))channel {
    return ^PNFetchMessagesActionsAPICallBuilder * (NSString *channel) {
        if ([channel isKindOfClass:[NSString class]] && channel.length) {
            [self setValue:channel forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchMessagesActionsAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNFetchMessagesActionsAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}

- (PNFetchMessagesActionsAPICallBuilder * (^)(NSNumber *start))start {
    return ^PNFetchMessagesActionsAPICallBuilder * (NSNumber *start) {
        if ([start isKindOfClass:[NSNumber class]] && start.unsignedIntegerValue) {
            [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNFetchMessagesActionsAPICallBuilder * (^)(NSNumber *end))end {
    return ^PNFetchMessagesActionsAPICallBuilder * (NSNumber *end) {
        if ([end isKindOfClass:[NSNumber class]] && end.unsignedIntegerValue) {
            [self setValue:end forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNFetchMessageActionsCompletionBlock block))performWithCompletion {
    return ^(PNFetchMessageActionsCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
