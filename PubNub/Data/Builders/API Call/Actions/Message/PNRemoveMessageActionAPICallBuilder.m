/**
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNRemoveMessageActionAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNRemoveMessageActionAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNRemoveMessageActionAPICallBuilder * (^)(NSNumber *messageTimetoken))messageTimetoken {
    return ^PNRemoveMessageActionAPICallBuilder * (NSNumber *messageTimetoken) {
        if ([messageTimetoken isKindOfClass:[NSNumber class]] &&
            messageTimetoken.unsignedIntegerValue) {
            
            [self setValue:messageTimetoken forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNRemoveMessageActionAPICallBuilder * (^)(NSNumber *actionTimetoken))actionTimetoken {
    return ^PNRemoveMessageActionAPICallBuilder * (NSNumber *actionTimetoken) {
        if ([actionTimetoken isKindOfClass:[NSNumber class]] &&
            actionTimetoken.unsignedIntegerValue) {
            
            [self setValue:actionTimetoken forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNRemoveMessageActionAPICallBuilder * (^)(NSString *channel))channel {
    return ^PNRemoveMessageActionAPICallBuilder * (NSString *channel) {
        if ([channel isKindOfClass:[NSString class]] && channel.length) {
            [self setValue:channel forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNRemoveMessageActionCompletionBlock block))performWithCompletion {
    return ^(PNRemoveMessageActionCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
