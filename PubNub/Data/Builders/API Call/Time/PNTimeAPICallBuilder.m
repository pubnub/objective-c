/**
 @author Sergey Mamontov
 @since <#version#>
 @copyright © 2009-2016 PubNub, Inc.
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
