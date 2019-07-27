/**
 * @author Serhii Mamontov
 * @version 4.9.0
 * @since 4.9.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNSignalAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNSignalAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNSignalAPICallBuilder * (^)(NSString *channel))channel {
    
    return ^PNSignalAPICallBuilder * (NSString *channel) {
        if ([channel isKindOfClass:[NSString class]]) {
            [self setValue:channel forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (PNSignalAPICallBuilder * (^)(id message))message {
    
    return ^PNSignalAPICallBuilder * (id message) {
        [self setValue:message forParameter:NSStringFromSelector(_cmd)];
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNSignalCompletionBlock block))performWithCompletion {
    
    return ^(PNSignalCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
