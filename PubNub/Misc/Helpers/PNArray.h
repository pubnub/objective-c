#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Useful NSArray additions collection.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNArray : NSObject


///------------------------------------------------
/// @name Data mapping
///------------------------------------------------

/**
 @brief  Map object from array to new array using output from \c mappingBlock.
 
 @param objects      Reference on original array with object which should be mapped to new array.
 @param mappingBlock Reference on block which pass only one argument - object from array and return
                     value with which object should be replaced in new array.
 
 @return New array with mapped objects.
 
 @since 4.0
 */
+ (NSArray *)mapObjects:(NSArray *)objects usingBlock:(id(^)(id object))mappingBlock;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
