#import <Foundation/Foundation.h>
#import <PubNub/PNResult.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Types

/// The processing block for the input stream data chunks.
///
/// - Parameters:
///   - buffer: A buffer containing a chunk of data (_raw_ or _encrypted_) for processing (_encryption_ or _decryption_).
///   - chunkLength: The length of the buffer that has been provided with a chunk of data.
///   - finalyze: Whether this is a final call or not. For the final call, there can be no data in the buffer for
///   processing, but the rest of the data in cryptor should be flushed.
/// - Returns: The result of chunked data processing.
typedef PNResult<NSData*>* _Nonnull (^PNCryptorInputStreamChunkProcessingBlock)(uint8_t *buffer,
                                                                                NSUInteger bufferLength,
                                                                                BOOL finalyze);


#pragma mark - Interface declaration

/// Crypto module data input stream.
///
/// The input stream implementation for the crypto module lets you specify _encryption_ and _decryption_ processing
/// blocks to process data in a stream.
///
/// Crypto module will use provided blocks to provide chunks of data from the input stream that should be processed by
/// the cryptor implementation.
///
/// - Since: 5.1.4
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNCryptorInputStream : NSInputStream


#pragma mark - Initialization and configuration

/// Create cryptor input stream.
///
/// - Parameters:
///   - stream: Input stream with data for processing (_encryption_ or _decryption_).
///   - length: Length of data in provided stream.
///   - chunkLength: Must be minimum length of data for which cryptor can provide output with processing block (at final
///   reads it _can_ be smaller).
///   - block: Block for input stream data chunks processing.
/// - Returns: Initialized cryptor input stream.
+ (instancetype)inputStreamWithInputStream:(NSInputStream *)stream
                                dataLength:(NSUInteger)length
                               chunkLength:(NSUInteger)chunkLength
                           processingBlock:(PNCryptorInputStreamChunkProcessingBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
