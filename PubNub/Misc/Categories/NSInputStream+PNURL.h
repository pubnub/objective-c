#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Category interface declaration

/// `NSInputStream` extension which provides functionality to work with file URL.
@interface NSInputStream (PNURL)


#pragma mark - Helpers

/// Write content of stream into file at specified `url`.
///
/// - Parameters:
///   - url: URL where stream data should be flushed.
///   - size: Size of chunk which is used to read from stream and write to file.
///   - error: Pointer into which stream error will be passed.
- (void)pn_writeToFileAtURL:(NSURL *)url withBufferSize:(NSUInteger)size error:(NSError **)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
