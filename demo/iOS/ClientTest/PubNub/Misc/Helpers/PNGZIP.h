#import <Foundation/Foundation.h>


/**
 @brief  Useful methods collection to work with data compression/uncompression.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNGZIP : NSObject


///------------------------------------------------
/// @name Compression
///------------------------------------------------

/**
 @brief      Allow to compress passed \c data.

 @param data Data which should be compressed with GZIP deflate algorithm.

 @return Compressed \a NSData instance or \c nil in case if compression error occurred.

 @since 4.0
 */
+ (NSData *)GZIPDeflatedData:(NSData *)data;

#pragma mark -


@end
