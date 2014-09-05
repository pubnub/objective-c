//
//  NSString+PNAddition.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/26/13.
//
//

#import <Foundation/Foundation.h>
#if __IPHONE_OS_VERSION_MIN_REQUIRED
    #import <UIKit/UIKit.h>
#else
    #import <AppKit/AppKit.h>
#endif


@interface NSString (PNAddition)


#pragma mark - Class methods


/**
 Create string using specified format and list of arguments.
 @note This method accept for format only strings with "%@" tokens.
 
 @param format
 String which will be modified using arguments from array.
 
 @param arguments
 List of objects which should be applied to specified format.
 
 
 @return formatted string.
 */
+ (NSString *)pn_stringWithFormat:(NSString *)format argumentsArray:(NSArray *)arguments;


#pragma mark Instance methods

/**
 Check receiver instance on whether it is empty or not (check is there any non-space or non-newline chars).
 
 @return \c YES if string doesn't contain any characters except newlines and spaces.
 */
- (BOOL)pn_isEmpty;

- (NSString *)pn_percentEscapedString;
#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
- (NSString *)pn_nonStringPercentEscapedString;
#endif

/**
 * Generate string which is composed of ASCII char
 * codes
 */
- (NSString *)pn_ASCIIString;

/**
 * Generate string which is composed of HEX values
 * of ASCII char codes
 */
- (NSString *)pn_ASCIIHEXString;

/**
 Allow to truncate string to specified length and truncate by specified parameter.
 
 @param length
 Length to which string should be truncated.
 
 @param lineBreakMode
 Specify what kind of truncation logic should be used: NSLineBreakModeClip, NSLineBreakModeHeadTruncation, NSLineBreakModeTailTruncation or NSLineBreakModeMiddleTruncation.
 */
- (NSString *)pn_truncatedString:(NSUInteger)length lineBreakMode:(NSLineBreakMode)lineBreakMode;


#pragma mark - Cryptography methods

- (NSData *)pn_sha256Data;
- (NSString *)pn_sha256HEXString;
- (NSString *)pn_base64DecodedString;

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
- (NSData *)pn_md5Data;
#endif

#pragma mark -


@end
