//
//  NSString+PNAddition.h
//  pubnub
//
//  Created by Sergey Mamontov on 2/26/13.
//
//

#import <Foundation/Foundation.h>


@interface NSString (PNAddition)


#pragma mark Instance methods

- (NSString *)percentEscapedString;
#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
- (NSString *)nonStringPercentEscapedString;
#endif

/**
 * Generate string which is composed of ASCII char
 * codes
 */
- (NSString *)ASCIIString;

/**
 * Generate string which is composed of HEX values
 * of ASCII char codes
 */
- (NSString *)ASCIIHEXString;

/**
 Allow to truncate string to specified length and truncate by specified parameter.
 
 @param length
 Length to which string should be truncated.
 
 @param lineBreakMode
 Specify what kind of truncation logic should be used: UILineBreakModeClip, UILineBreakModeHeadTruncation, UILineBreakModeTailTruncation or UILineBreakModeMiddleTruncation.
 */
#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (NSString *)truncatedString:(NSUInteger)length lineBreakMode:(UILineBreakMode)lineBreakMode;
#else
- (NSString *)truncatedString:(NSUInteger)length lineBreakMode:(NSLineBreakMode)lineBreakMode;
#endif


#pragma mark - Cryptography methods

- (NSData *)sha256Data;
- (NSString *)sha256HEXString;
- (NSString *)base64DecodedString;

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
- (NSData *)md5Data;
#endif

#pragma mark -


@end
