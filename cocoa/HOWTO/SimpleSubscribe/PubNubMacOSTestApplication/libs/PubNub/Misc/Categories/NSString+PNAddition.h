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


#pragma mark - Cryptography methods

- (NSData *)sha256Data;
- (NSString *)sha256HEXString;
- (NSString *)base64DecodedString;

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
- (NSData *)md5Data;
#endif

#pragma mark -


@end
