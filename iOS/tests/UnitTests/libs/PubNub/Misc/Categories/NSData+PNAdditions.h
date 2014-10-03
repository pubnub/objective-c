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
+ (NSData *)pn_dataFromBase64String:(NSString *)encodedSting;


#pragma mark - Instance methods

/**
 * Allow to extract ull integer from HEX which
 * is represented by string inside NSData
 */
- (unsigned long long int)pn_unsignedLongLongFromHEXData;

/**
 * Allow to encode bytes into base64 string
 */
- (NSString *)pn_base64Encoding;

/**
 * Allow to extract HEX string from bytes stored
 * inside object
 */
- (NSString *)pn_HEXString;


#pragma mark - Compression / Decompression methods

/**
 Retrieve GZIP compressed data using deflate algorithm.
 
 @return \b NSData instance with deflated data compressed with default compression ratio.
 */
- (NSData *)pn_GZIPDeflate;

/**
 * Retrieve uncompressed GZIP data
 */
- (NSData *)pn_GZIPInflate;

/**
 * Retrieve uncompressed deflated data
 */
- (NSData *)pn_inflate;


#pragma mark - APNS

/**
 * Extract HEX string which can be used by server
 * for communication with APNS servers
 */
- (NSString *)pn_HEXPushToken;

#pragma mark -


@end
