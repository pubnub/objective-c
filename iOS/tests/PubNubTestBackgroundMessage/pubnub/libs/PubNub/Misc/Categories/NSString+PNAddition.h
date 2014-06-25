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
#endif


@interface NSString (PNAddition)


#pragma mark Instance methods

/**
 Check receiver instance on whether it is empty or not (check is there any non-space or non-newline chars).
 
 @return \c YES if string doesn't contain any characters except newlines and spaces.
 */
- (BOOL)isEmpty;

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
 Specify what kind of truncation logic should be used: NSLineBreakModeClip, NSLineBreakModeHeadTruncation, NSLineBreakModeTailTruncation or NSLineBreakModeMiddleTruncation.
 */
- (NSString *)truncatedString:(NSUInteger)length lineBreakMode:(NSLineBreakMode)lineBreakMode;


#pragma mark - Cryptography methods

- (NSData *)sha256Data;
- (NSString *)sha256HEXString;
- (NSString *)base64DecodedString;

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
- (NSData *)md5Data;
#endif

#pragma mark -


@end
