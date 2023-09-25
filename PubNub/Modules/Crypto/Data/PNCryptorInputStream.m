#import "PNCryptorInputStream+Private.h"
#import "PNCryptorHeader+Private.h"
#import "PNErrorCodes.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Crypto module data input stream private extension.
@interface PNCryptorInputStream ()


#pragma mark - Properties

/// Block for input stream data chunks processing.
@property(nonatomic, readonly, copy) PNCryptorInputStreamChunkProcessingBlock processingBlock;

/// Whether cryptor input stream in the mode for data processing with cryptor or not.
@property(nonatomic, assign, getter=isProcessingWithCryptor) BOOL processingWithCryptor;

/// Input stream read data buffer.
///
/// Used to store source data until will read large enough chunk or reach end of stream.
@property(nonatomic, nullable, strong) NSData *notProcessedDataBuffer;

/// Processed data buffer.
///
/// Used to store processed data until next `read` method call with _fresh_ buffer.
@property(nonatomic, nullable, strong) NSData *processedDataBuffer;

/// Input stream with data for processing (_encryption_ or _decryption_).
@property(nonatomic, readonly, strong) NSInputStream *inputStream;

/// Length of data in provided stream.
@property(nonatomic, readonly, assign) NSUInteger inputDataLength;

/// Minimum length of chunk which should be passed to processing block.
@property(nonatomic, readonly, assign) NSUInteger chunkLength;

/// Range of processed data inside of temporary buffer.
@property (nonatomic, assign) NSRange processedDataRange;

/// Cryptor input stream processing error.
@property (atomic, nullable, copy) NSError *streamError;

/// Cryptor input stream status.
@property (atomic, assign) NSStreamStatus streamStatus;

/// Overall length of read source stream data.
@property(nonatomic, assign) NSUInteger readLength;


#pragma mark - Initialization and configuration

/// Init cryptor input stream.
///
/// Extension, which allows pre-parsing portions of stream data to identify the `cryptor` data header.
///
/// - Parameters:
///   - stream: Input stream with data for pre-parsing.
///   - length: Length of data in provided stream.
/// - Returns: Initialized cryptor input stream.
- (instancetype)initWithInputStream:(NSInputStream *)stream dataLength:(NSUInteger)length;

/// Init cryptor input stream.
///
/// - Parameters:
///   - stream: Input stream with data for processing (_encryption_ or _decryption_).
///   - length: Length of data in provided stream.
///   - chunkLength: Minimum length of chunk which should be passed to processing block (at final reads it _can_ be
///   smaller).   
///   - block: Block for input stream data chunks processing.
/// - Returns: Initialized cryptor input stream.
- (instancetype)initWithInputStream:(NSInputStream *)stream
                         dataLength:(NSUInteger)length
                        chunkLength:(NSUInteger)chunkLength
                    processingBlock:(PNCryptorInputStreamChunkProcessingBlock)block;


#pragma mark - Helpers

/// Read specified number of bytes from `inputStream`.
///
/// Read and fill read buffer with not processed data into buffer for processing.
///
/// - Parameter length: Number of bytes which should be read from `inputStream`.
- (void)readInputStreamData:(NSUInteger)length;

/// Check whether it is still possible to read data from `inputStream`.
///
/// In the following cases it is impossible to make further reads:
/// * crypto input stream is closed
/// * `inputStream` is closed
/// * `inputStream` is in error state
/// * `inputStream` reached the end (basing on provided stream data length and read data length).
- (BOOL)canReadDataFromInputStream;

/// Call data chunk processing block on read buffer.
- (void)processInputStreamBuffer;

/// Write previously encrypted data.
///
/// Write temporarily buffered encrypted data into the provided read buffer.
///
/// - Parameters:
///   - buffer: Read buffer into which data from the encrypted data buffer should be written.
///   - maxLength: Maximum number of bytes that can be written into the buffer.
/// - Returns: The actual number of bytes that have been written into the buffer.
- (NSUInteger)writeEncryptedDataToBuffer:(uint8_t *)buffer maxLength:(NSUInteger)maxLength;

/// Check whether there is more data in encrypted buffer or not.
///
/// - Returns: `YES` if there is more data in `encryptedDataBuffer` which can be sent.
- (BOOL)hasNotSentData;

/// Update stream status and error if required.
///
/// - Parameter error: `NSError` instance with information about what exactly went wrong during stream processing.
- (void)setStreamProcessingError:(nullable NSError *)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNCryptorInputStream


#pragma mark - Information

@synthesize streamStatus, streamError, delegate;


#pragma mark - Initialization and configuration

+ (instancetype)inputStreamWithInputStream:(NSInputStream *)stream dataLength:(NSUInteger)length {
    if ([stream isKindOfClass:self]) return (PNCryptorInputStream *)stream;
    return [[self alloc] initWithInputStream:stream dataLength:length];
}

+ (instancetype)inputStreamWithInputStream:(NSInputStream *)stream
                                dataLength:(NSUInteger)length
                               chunkLength:(NSUInteger)chunkLength
                           processingBlock:(PNCryptorInputStreamChunkProcessingBlock)block {
    return [[self alloc] initWithInputStream:stream dataLength:length chunkLength:chunkLength processingBlock:block];
}


- (instancetype)initWithInputStream:(NSInputStream *)stream dataLength:(NSUInteger)length {
    if ((self = [super init])) {
        _inputDataLength = length;
        _inputStream = stream;
    }

    return self;
}

- (instancetype)initWithInputStream:(NSInputStream *)stream
                         dataLength:(NSUInteger)length
                        chunkLength:(NSUInteger)chunkLength
                    processingBlock:(PNCryptorInputStreamChunkProcessingBlock)block {
    if ((self = [self initWithInputStream:stream dataLength:length])) {
        _processedDataRange = NSMakeRange(NSNotFound, 0);
        _processingBlock = [block copy];
        _processingWithCryptor = YES;
        _chunkLength = chunkLength;
    }
    
    return self;
}


#pragma mark - NSStream

- (id)propertyForKey:(NSStreamPropertyKey)key {
    return [self.inputStream propertyForKey:key];
}

- (BOOL)setProperty:(id)property forKey:(NSStreamPropertyKey)key {
    return [self.inputStream setProperty:property forKey:key];
}

- (void)open {
    if (self.streamStatus == NSStreamStatusNotOpen) self.streamStatus = NSStreamStatusOpen;
    if (self.inputStream.streamStatus == NSStreamStatusNotOpen) [self.inputStream open];
}

- (void)close {
    if (self.streamStatus != NSStreamStatusError && self.streamStatus != NSStreamStatusClosed) {
        self.streamStatus = NSStreamStatusClosed;
    }
    
    if (self.inputStream.streamStatus != NSStreamStatusError && self.inputStream.streamStatus != NSStreamStatusClosed) {
        [self.inputStream close];
    }

    self.notProcessedDataBuffer = nil;
    self.processedDataBuffer = nil;
}

- (void)scheduleInRunLoop:(NSRunLoop *)__unused aRunLoop forMode:(NSRunLoopMode)__unused mode {
}

- (void)removeFromRunLoop:(NSRunLoop *)__unused aRunLoop forMode:(NSRunLoopMode)__unused mode {
}


#pragma mark - NSInputStream

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)length {
    if (length == 0) return 0;
    if (self.streamStatus == NSStreamStatusClosed || self.streamStatus == NSStreamStatusError) {
        return self.streamStatus == NSStreamStatusClosed ? 0 : -1;
    }
    NSUInteger bytesToRead = length;

    // Handle header parse on decryption.
    if (!self.isProcessingWithCryptor) {
        if (self.notProcessedDataBuffer) {
            if (length > self.notProcessedDataBuffer.length) {
                [self.notProcessedDataBuffer getBytes:buffer length:self.notProcessedDataBuffer.length];
                bytesToRead -= self.notProcessedDataBuffer.length;
                self.notProcessedDataBuffer = nil;
            } else {
                NSRange dataRange = NSMakeRange(length, self.notProcessedDataBuffer.length - length);
                [self.notProcessedDataBuffer getBytes:buffer length:length];
                self.notProcessedDataBuffer = [self.notProcessedDataBuffer subdataWithRange:dataRange];
                bytesToRead -= length;
            }
        }

        if (bytesToRead > 0) {
            NSInteger bytesRead = [self.inputStream read:buffer + (length - bytesToRead) maxLength:bytesToRead];
            if (bytesRead == 0) return length - bytesToRead;
            else if (bytesRead > 0) bytesToRead -= bytesRead;
            else {
                [self setStreamProcessingError:self.inputStream.streamError];
                return -1;
            }
        }

        return length - bytesToRead;
    }
    
    while (bytesToRead > 0 && self.streamStatus != NSStreamStatusClosed && self.streamStatus != NSStreamStatusError) {
        // Read previously encrypted data if possible.
        if ([self hasNotSentData]) {
            bytesToRead -= [self writeEncryptedDataToBuffer:buffer maxLength:bytesToRead];
        } else if (self.inputDataLength != self.readLength) {
            [self readInputStreamData:MAX(length, self.chunkLength)];
            [self processInputStreamBuffer];
        } else {
            return length - bytesToRead;
        }
    }
    
    return length - bytesToRead;
}

- (BOOL)getBuffer:(uint8_t * _Nullable *)__unused buffer length:(NSUInteger *)__unused len {
    return NO;
}

- (BOOL)hasBytesAvailable {
    return [self hasNotSentData] || self.inputStream.hasBytesAvailable;
}


#pragma mark - Pre-processing

- (PNResult<PNCryptorHeader *> *)parseHeader {
    [self open];

    if (self.streamStatus == NSStreamStatusError) return [PNResult resultWithData:nil error:self.streamError];

    // Check whether data is too small to be in new format or not.
    if (self.inputDataLength < PNCryptorHeader.maximumHeaderLength) return nil;

    NSMutableData *headerBuffer = [NSMutableData dataWithLength:PNCryptorHeader.maximumHeaderLength];
    NSInteger bytesRead = [self read:headerBuffer.mutableBytes maxLength:PNCryptorHeader.maximumHeaderLength];
    PNResult<PNCryptorHeader *> *header = nil;

    if (bytesRead > 0) {
        headerBuffer.length = bytesRead;
        if (bytesRead == PNCryptorHeader.maximumHeaderLength) {
            header = [PNCryptorHeader headerFromData:headerBuffer];

            if (header && !header.isError) {
                NSUInteger headerInfoLength = header.data.length - header.data.metadataLength;
                _inputDataLength -= headerInfoLength;

                if (headerInfoLength < headerBuffer.length) {
                    NSRange restDataRange = NSMakeRange(headerInfoLength, headerBuffer.length - headerInfoLength);
                    [headerBuffer setData:[headerBuffer subdataWithRange:restDataRange]];
                } else {
                    headerBuffer = nil;
                }
            }
        }
        
        self.notProcessedDataBuffer = [headerBuffer copy];
    } else {
        header = [PNResult resultWithData:nil error:self.streamError];
    }

    return header;
}

- (PNResult<NSData *> *)readCryptorMetadataWithLength:(NSUInteger)length {
    if (length > self.inputDataLength || length == 0) return nil;

    NSMutableData *metadata = [NSMutableData dataWithLength:length];
    NSUInteger bytesToRead = length;
    NSError *error = nil;
    do {
        NSInteger bytesRead = [self read:metadata.mutableBytes + (length - bytesToRead) maxLength:bytesToRead];
        if (bytesRead >= 0) bytesToRead -= bytesRead;
    } while ([self canReadDataFromInputStream] && self.streamStatus != NSStreamStatusClosed && bytesToRead != 0);

    if (bytesToRead != 0) {
        error = [NSError errorWithDomain:kPNCryptorErrorDomain
                                    code:kPNCryptorDecryptionError
                                userInfo:@{
            NSLocalizedDescriptionKey: @"Insufficient amount of data to read cryptor-defined metadata."
        }];
    } else {
        metadata.length = length;
        if (length == 0) metadata = nil;
        _inputDataLength -= length;
    }

    return [PNResult resultWithData:metadata error:error];
}


#pragma mark - Helpers

- (void)readInputStreamData:(NSUInteger)length {
    NSMutableData *buffer = [NSMutableData dataWithLength:length];
    NSUInteger bytesToRead = length;
    
    do {
        NSInteger bytesRead = [self.inputStream read:buffer.mutableBytes + (length - bytesToRead) maxLength:bytesToRead];
        if (bytesRead >= 0) bytesToRead -= bytesRead;
    } while ([self canReadDataFromInputStream] && self.streamStatus != NSStreamStatusClosed && bytesToRead != 0);

    if (bytesToRead != length && self.inputStream.streamError == nil) {
        NSUInteger bytesRead = length - bytesToRead;
        buffer.length = bytesRead;
        self.notProcessedDataBuffer = buffer;
        self.readLength += bytesRead;
    } else if (self.inputStream.streamError != nil) {
        [self setStreamProcessingError:self.inputStream.streamError];
    }
}

- (BOOL)canReadDataFromInputStream {
    return self.inputStream.streamStatus != NSStreamStatusClosed &&
        self.inputStream.streamError != nil &&
        self.inputDataLength != self.readLength;
}

- (void)processInputStreamBuffer {
    BOOL finalise = self.inputDataLength == self.readLength;
    if ((self.streamStatus == NSStreamStatusError || self.streamStatus == NSStreamStatusClosed) && !finalise) {
        return;
    }
    
    NSData *notSentData = nil;
    if (self.processedDataRange.length > 0) {
        notSentData = [self.processedDataBuffer subdataWithRange:self.processedDataRange];
    }
    
    PNResult<NSData *> *processResult = self.processingBlock((uint8_t *)self.notProcessedDataBuffer.bytes,
                                                             self.notProcessedDataBuffer.length,
                                                             finalise);
    
    if (processResult.isError) {
        [self setStreamProcessingError:processResult.error];
        return;
    }
    
    if (notSentData) {
        NSMutableData *processedData = [NSMutableData dataWithCapacity:(notSentData.length + processResult.data.length)];
        [processedData appendData:notSentData];
        [processedData appendData:processResult.data];
        self.processedDataBuffer = processedData;
    } else {
        self.processedDataBuffer = processResult.data;
    }

    self.processedDataRange = NSMakeRange(0, self.processedDataBuffer.length);
    self.notProcessedDataBuffer = nil;
}

- (NSUInteger)writeEncryptedDataToBuffer:(uint8_t *)buffer maxLength:(NSUInteger)maxLength {
    NSInteger bytesToWrite = MIN(maxLength, self.processedDataRange.length);
    [self.processedDataBuffer getBytes:buffer length:bytesToWrite];
    
    if (bytesToWrite == self.processedDataRange.length) {
        self.processedDataRange = NSMakeRange(NSNotFound, 0);
        self.processedDataBuffer = nil;
    } else {
        self.processedDataRange = NSMakeRange(self.processedDataRange.location,
                                              self.processedDataRange.length - bytesToWrite);
    }
    
    return bytesToWrite;
}

- (BOOL)hasNotSentData {
    return self.processedDataRange.length > 0;
}

- (void)setStreamProcessingError:(nullable NSError *)error {
    if (!error) return;
    self.streamError = error;
    self.streamStatus = NSStreamStatusError;
}

- (void)dealloc {
    _notProcessedDataBuffer = nil;
    _processedDataBuffer = nil;
}

#pragma mark -


@end
