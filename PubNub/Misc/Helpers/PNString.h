#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Useful NSString additions collection.
 *
 * @author Sergey Mamontov
 * @version 4.17.0
 * @since 4.0.0
 * @copyright © 2010-2021 PubNub, Inc.
 */
@interface PNString : NSObject


#pragma mark - Encoding

/**
 * @brief Convert provided string into percent-escaped string.
 *
 * @param string Reference on string which should be converted.
 *
 * @return Percent-escaped string.
 */
+ (NSString *)percentEscapedString:(NSString *)string;


#pragma mark - Conversion

/**
 * @brief Convert provided \c string to \a NSData using UTF-8 encoding.
 *
 * @discussion This is shortcut to [... dataUsingEncoding:NSUTF8StringEncoding] method.
 *
 * @param string Reference on string which should be converted.
 *
 * @return Data object built from UTF-8 encoded string.
 */
+ (nullable NSData *)UTF8DataFrom:(NSString *)string;

/**
 * @brief Convert provided base64-encoded \c string to \a NSData.
 *
 * @discussion This is shortcut to [[NSData alloc] initWithBase64EncodedString:object
 *                                  ptions:NSDataBase64DecodingIgnoreUnknownCharacters]
 *             method.
 *
 * @param string Reference on base64-encoded string which should be converted.
 *
 * @return Data object built from base64-encoded string.
 */
+ (NSData *)base64DataFrom:(NSString *)string;


#pragma mark - Hashing

/**
 * @brief Calculate SHA-256 hash data from provided string.
 *
 * @param string Reference on string which should be hash'ed.
 *
 * @return SHA-256 hash data.
 */
+ (NSData *)SHA256DataFrom:(NSString *)string;


#pragma mark - Misc

/**
 * @brief Normalize URL-friendly Base64 string.
 *
 * @param base64 URL-friendly Base64 string, which should be normalized.
 *
 * @return Normalized Base64 string.
 */
+ (NSString *)base64StringFromURLFriendlyBase64String:(NSString *)base64;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
