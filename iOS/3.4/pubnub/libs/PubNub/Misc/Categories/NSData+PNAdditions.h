//
//  NSData(PNAdditions).h
// 
//
//  Created by moonlight on 1/18/13.
//
//


#import <Foundation/Foundation.h>


@interface NSData (PNAdditions)


#pragma mark Instance methods

/**
 * Allow to extract ull integer from HEX which
 * is represented by string inside NSData
 */
- (unsigned long long int)unsignedLongLongFromHEXData;

/**
 * Allow to encode bytes into base64 string
 */
- (NSString *)base64Encoding;

/**
 * Allow to extract HEX string from bytes stored
 * inside object
 */
- (NSString *)HEXString;

/**
 * Retrieve uncompressed GZIP data
 */
- (NSData *)GZIPInflate;

#pragma mark -


@end