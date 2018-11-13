#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Useful NSString additions collection.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNString : NSObject


///------------------------------------------------
/// @name Encoding
///------------------------------------------------

/**
 @brief  Convert provided string into percent-escaped string.
 
 @param string Reference on string which should be converted.
 
 @return Percent-escaped string.
 
 @since 4.0
 */
+ (NSString *)percentEscapedString:(NSString *)string;


///------------------------------------------------
/// @name Convertion
///------------------------------------------------

/**
 @brief      Convert provided \c string to \a NSData using UTF-8 encoding.
 @dicsuccion This is shortcut to [... dataUsingEncoding:NSUTF8StringEncoding] method.
 
 @param string Reference on string which should be converted.
 
 @return Data object built from UTF-8 encoded string.
 
 @since 4.0
 */
+ (nullable NSData *)UTF8DataFrom:(NSString *)string;

/**
 @brief      Convert provided base64-encoded \c string to \a NSData.
 @dicsuccion This is shortcut to [[NSData alloc] initWithBase64EncodedString:object
                                  ptions:NSDataBase64DecodingIgnoreUnknownCharacters]
             method.
 
 @param string Reference on base64-encoded string which should be converted.
 
 @return Data object built from base64-encoded string.
 
 @since 4.0
 */
+ (NSData *)base64DataFrom:(NSString *)string;


///------------------------------------------------
/// @name Hashing
///------------------------------------------------

/**
 @brief  Calculate SHA-256 hash data from provided string.
 
 @param string Reference on string which should be hash'ed.
 
 @return SHA-256 hash data.
 
 @since 4.0
 */
+ (NSData *)SHA256DataFrom:(NSString *)string;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
