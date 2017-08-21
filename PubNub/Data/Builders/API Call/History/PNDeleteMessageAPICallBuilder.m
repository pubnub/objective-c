/**
 @author Sergey Mamontov
 @since 4.7.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNDeleteMessageAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNDeleteMessageAPICallBuilder


#pragma mark - Configuration

- (PNDeleteMessageAPICallBuilder *(^)(NSString *channel))channel {
    
    return ^PNDeleteMessageAPICallBuilder* (NSString *channel) {
        
        [self setValue:channel forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNDeleteMessageAPICallBuilder *(^)(NSNumber *start))start {
    
    return ^PNDeleteMessageAPICallBuilder* (NSNumber *start) {
        
        [self setValue:start forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNDeleteMessageAPICallBuilder *(^)(NSNumber *end))end {
    
    return ^PNDeleteMessageAPICallBuilder* (NSNumber *end) {
        
        [self setValue:end forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNMessageDeleteCompletionBlock block))performWithCompletion {
    
    return ^(PNMessageDeleteCompletionBlock block) { [super performWithBlock:block]; };
}

#pragma mark -


@end
