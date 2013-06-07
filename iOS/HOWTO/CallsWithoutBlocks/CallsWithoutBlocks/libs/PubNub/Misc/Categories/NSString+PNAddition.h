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

#pragma mark -


@end
