/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "NSInvocation+PNTest.h"


#pragma mark Category interface implementation

@implementation NSInvocation (PNTest)


#pragma mark - Arguments

- (BOOL)booleanForArgumentAtIndex:(NSUInteger)index {
    BOOL value = NO;
    
    [self getArgument:&value atIndex:index];
    
    return value;
}

- (id)objectForArgumentAtIndex:(NSUInteger)index {
    __unsafe_unretained id object = nil;
    
    [self getArgument:&object atIndex:index];
    
    return object;
}

#pragma mark -


@end
