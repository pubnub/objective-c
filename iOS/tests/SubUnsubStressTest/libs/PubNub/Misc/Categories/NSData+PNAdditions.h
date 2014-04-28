//
//  NSData(PNAdditions).h
// 
//
//  Created by moonlight on 1/18/13.
//
//

#import <Foundation/Foundation.h>


@interface NSData (PNAdditions)


#pragma mark Class methods

/**
 * Allow to decode base64 string into data
 */
+ (NSData *)dataFromBase64String:(NSString *)encodedSting;


#pragma mark - Instance methods

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


#pragma mark - Compression / Decompression methods

/**
 Retrieve GZIP compressed data using deflate algorithm.
 
 @return \b NSData instance with deflated data compressed with default compression ratio.
 */
- (NSData *)GZIPDeflate;

/**
 * Retrieve uncompressed GZIP data
 */
- (NSData *)GZIPInflate;

/**
 * Retrieve uncompressed deflated data
 */
- (NSData *)inflate;


#pragma mark - APNS

/**
 * Extract HEX string which can be used by server
 * for communication with APNS servers
 */
- (NSString *)HEXPushToken;

#pragma mark -


@end
