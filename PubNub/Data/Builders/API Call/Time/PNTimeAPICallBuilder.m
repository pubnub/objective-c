/**
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PNTimeAPICallBuilder.h"
#import "PNAPICallBuilder+Private.h"


#pragma mark Interface implementation

@implementation PNTimeAPICallBuilder


#pragma mark - Execution

- (void(^)(PNTimeCompletionBlock block))performWithCompletion {
    
    return ^(PNTimeCompletionBlock block){ [super performWithBlock:block]; };
}

#pragma mark -


@end
