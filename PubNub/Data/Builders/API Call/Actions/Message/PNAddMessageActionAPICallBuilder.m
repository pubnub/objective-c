/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNAddMessageActionAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNAddMessageActionAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNAddMessageActionAPICallBuilder * (^)(NSNumber *messageTimetoken))messageTimetoken {
    return ^PNAddMessageActionAPICallBuilder * (NSNumber *messageTimetoken) {
        if ([messageTimetoken isKindOfClass:[NSNumber class]] &&
            messageTimetoken.unsignedIntegerValue) {
            
            [self setValue:messageTimetoken forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNAddMessageActionAPICallBuilder * (^)(NSString *type))type {
    return ^PNAddMessageActionAPICallBuilder * (NSString *type) {
        if ([type isKindOfClass:[NSString class]] && type.length) {
            [self setValue:type forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNAddMessageActionAPICallBuilder * (^)(NSString *channel))channel {
    return ^PNAddMessageActionAPICallBuilder * (NSString *channel) {
        if ([channel isKindOfClass:[NSString class]] && channel.length) {
            [self setValue:channel forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNAddMessageActionAPICallBuilder * _Nonnull (^)(NSString *value))value {
    return ^PNAddMessageActionAPICallBuilder * (NSString *value) {
        if ([value isKindOfClass:[NSString class]] && value.length) {
            [self setValue:value forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNAddMessageActionCompletionBlock block))performWithCompletion {
    return ^(PNAddMessageActionCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
