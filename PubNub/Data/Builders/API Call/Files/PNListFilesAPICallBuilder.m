/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNListFilesAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNListFilesAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNListFilesAPICallBuilder * (^)(NSUInteger limit))limit {
    return ^PNListFilesAPICallBuilder * (NSUInteger limit) {
        [self setValue:@(limit) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (PNListFilesAPICallBuilder * (^)(NSString *next))next {
    return ^PNListFilesAPICallBuilder * (NSString *next) {
        if ([next isKindOfClass:[NSString class]]) {
            [self setValue:next forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

#pragma mark - Execution

- (void(^)(PNListFilesCompletionBlock block))performWithCompletion {
    return ^(PNListFilesCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
