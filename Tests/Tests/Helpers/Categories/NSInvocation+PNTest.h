#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Category interface declaration

/**
 * @brief Interface extension to provide easier way to access values.
 *
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface NSInvocation (PNTest)


#pragma mark - Arguments

/**
 * @brief Retrieve boolean value passed as argument at specified index.
 *
 * @param index Index of argument for which boolean value should be returned.
 *
 * @return Boolean value passed to argument specified by it's index.
 */
- (BOOL)booleanForArgumentAtIndex:(NSUInteger)index;

/**
 * @brief Retrieve value passed as argument at specified index.
 *
 * @param index Index of argument for which value should be returned.
 *
 * @return Value passed to argument specified by it's index.
 */
- (id)objectForArgumentAtIndex:(NSUInteger)index;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
