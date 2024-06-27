#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface implementation

/// Useful methods collection to work with data compression/uncompression.
@interface PNGZIP : NSObject


#pragma mark - Compression

/// Allow to compress passed `data`.
///
/// - Parameter data: Data which should be compressed with GZIP deflate algorithm.
/// - Returns: Compressed `NSData` instance or `nil` in case if compression error occurred.
+ (nullable NSData *)GZIPDeflatedData:(NSData *)data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
