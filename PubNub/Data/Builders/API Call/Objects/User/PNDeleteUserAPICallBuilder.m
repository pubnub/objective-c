/**
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "PNDeleteUserAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNDeleteUserAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Configuration

- (PNDeleteUserAPICallBuilder * (^)(NSString *userId))userId {
    return ^PNDeleteUserAPICallBuilder * (NSString *userId) {
        if ([userId isKindOfClass:[NSString class]] && userId.length) {
            [self setValue:userId forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Execution

- (void(^)(PNDeleteUserCompletionBlock block))performWithCompletion {
    return ^(PNDeleteUserCompletionBlock block) {
        [super performWithBlock:block];
    };
}


#pragma mark -


@end
