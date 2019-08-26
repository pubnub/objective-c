#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Useful \a NSDictionary additions collection.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNDictionary : NSObject


#pragma mark - Validation

/**
 * @brief Check whether \c dictionary contain values only of specified class.
 *
 * @param dictionary Dictionary which should be validated.
 * @param classes List of the only value object classes expected to be in \c dictionary.
 *
 * @return Whether only values with specified \c classes stored in \c dictionary or not.
 */
+ (BOOL)isDictionary:(NSDictionary *)dictionary containValueOfClasses:(NSArray<Class> *)classes;


#pragma mark - URL helper

/**
 * @brief Encode provided \c dictionary to string which can be used with reuests.
 *
 * @param dictionary Dictionary which should be encoded.
 *
 * @return Joined string with percent-escaped kevy values.
 */
+ (NSString *)queryStringFrom:(NSDictionary *)dictionary;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
