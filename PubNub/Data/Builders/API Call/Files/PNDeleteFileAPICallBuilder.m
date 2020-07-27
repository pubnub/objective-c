/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNDeleteFileAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNDeleteFileAPICallBuilder


#pragma mark - Information

@dynamic queryParam;


#pragma mark - Execution

- (void(^)(PNDeleteFileCompletionBlock block))performWithCompletion {
    return ^(PNDeleteFileCompletionBlock block) {
        [super performWithBlock:block];
    };
}

#pragma mark -


@end
