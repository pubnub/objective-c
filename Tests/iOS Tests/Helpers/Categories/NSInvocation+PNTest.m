#import "NSInvocation+PNTest.h"

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
