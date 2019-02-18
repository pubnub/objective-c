#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface NSInvocation (PNTest)


#pragma mark - Arguments

- (BOOL)booleanForArgumentAtIndex:(NSUInteger)index;
- (id)objectForArgumentAtIndex:(NSUInteger)index;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
