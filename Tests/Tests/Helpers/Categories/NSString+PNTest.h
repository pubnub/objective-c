#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Category interface declaration

/**
 * @brief Interface extension to provide easier ways to manage strings in tests.
 *
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface NSString (PNTest)


#pragma mark - Initialization & Configuration

/**
 * @brief String by extending receiver length to specified \c length and fill or new space with
 * receiver's value.
 *
 * @param length Resulting string length.
 *
 * @return String filled with \c string to required \c length.
 */
- (NSString *)pnt_stringWithLength:(NSUInteger)length;

/**
 * @brief Create binary data object from previously HEX encoded data string.
 *
 * @return Binary data from receiver's HEX string.
 */
- (NSData *)pnt_dataFromHex;


#pragma mark - Check helpers

/**
 * @brief Whether receiver include specified \c string as substring or not.
 *
 * @param string Substring which should be searched in receiver.
 *
 * @return \c YES in case if substring has been found.
 */
- (BOOL)pnt_includesString:(NSString *)string;

/**
 * @brief Whether receiver include any string from specified \c string as substring or not.
 *
 * @param strings Substrings which should be searched in receiver.
 *
 * @return \c YES in case if any entry from \c strings has been found as substring.
 */
- (BOOL)pnt_includesAnyString:(NSArray<NSString *> *)strings;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
