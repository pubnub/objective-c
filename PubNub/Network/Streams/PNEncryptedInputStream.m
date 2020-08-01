/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNEncryptedInputStream.h"
#import "PNAES+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNEncryptedInputStream ()


#pragma mark - Information

/**
 * @brief Buffer which is used to temporary store encrypted stream data.
 *
 * @discussion Temporary store required for cases, when encrypted data is larger than it has been
 * requested to read from input stream.
 */
@property (nonatomic, nullable, strong) NSMutableData *dataBuffer;

/**
 * @brief Buffer which is used to temporary store raw bytes from input stream.
 *
 * @discussion This used to store read, but not encrypted data between encrypted stream read method calls.
 *
 * @since 4.15.2
 */
 @property (nonatomic, nullable, strong) NSMutableData *readBuffer;

 /**
  * @brief Range of not processed data with \c readBuffer.
  *
  * @since 4.15.2
  */
 @property (nonatomic, assign) NSRange notProcessedDataRange;

/**
 * @brief Whether initialization vector for data encryption has been sent to read buffer or not.
 */
@property (nonatomic, assign) BOOL initializationVectorSent;

/**
 * @brief Underlying input stream whose data should be encrypted on-demand.
 */
@property (nonatomic, strong) NSInputStream *inputStream;

/**
 * @brief How much data has been read from input stream into \c readBuffer.
 *
 * @since 4.15.2
 */
@property (nonatomic, assign) NSUInteger readStreamSize;

/**
 * @brief Encrypted input stream processing error.
 */
@property (atomic, nullable, copy) NSError *streamError;

/**
 * @brief Encrypted input stream status.
 */
@property (atomic, assign) NSStreamStatus streamStatus;

/**
 * @brief Range of encrypted data inside of temporary buffer.
 */
@property (nonatomic, assign) NSRange unsentEncryptedDataRange;

/**
 * @brief Size of data which will be provided by \c inputStream.
 */
@property (nonatomic, assign) NSUInteger streamDataSize;

/**
 * @brief How much data has been sent already.
 *
 * @since 4.15.2
 */
@property (nonatomic, assign) NSUInteger streamedSize;

/**
 * @brief Input data encryptor.
 */
@property (nonatomic, strong) PNAES *encryptor;

/**
 * @brief Overall stream size (which include random initialization vector).
 */
@property (nonatomic, assign) NSUInteger size;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure encrypted input stream from.
 *
 * @param inputStream Input stream with raw data, which should be encrypted during read.
 * @param size Size of data which will be provided by \c inputStream.
 * @param cipherKey Key which should be used to encrypt stream content.
 *
 * @return Configured and ready to use encrypted input stream.
 */
- (instancetype)initWithInputStream:(NSInputStream *)inputStream
                               size:(NSUInteger)size
                          cipherKey:(NSString *)cipherKey;


#pragma mark - Misc

/**
 * @brief Read out previously encrypted data to provided \c buffer.
 *
 * @param buffer A data buffer to which encrypted data should be copied for further sending.
 * @param offset Offset within \c buffer to when wrote bytes which didn't fit in previous buffer.
 * @param length Maximum number of encrypted bytes should be copied to \c buffer.
 */
- (NSInteger)readEncryptedToBuffer:(uint8_t *)buffer
                        withOffset:(NSUInteger)offset
                            length:(NSUInteger)length;

/**
 * @brief Read data which will be encrypted later.
 *
 * @param maxLength Maximum length of data from input stream to read.
 *
 * @return \c YES in case if read was successful.
 *
 * @since 4.15.2
 */
- (BOOL)readInputStreamBuffer:(NSUInteger)maxLength;

/**
 * @brief Check encrypted data buffer for content available.
 *
 * @return \c YES when there is more encrypted data in buffer for sending.
 */
- (BOOL)hasEncryptedBytesAvailable;

/**
 * @brief Prepend initialization vector information to data which should be sent.
 */
- (void)prependInitializationVector;

/**
 * @brief Update stream status and error if required.
 *
 * @param error \a NSError instance with information about what exactly went wrong during stream
 * processing.
 */
- (void)setStreamProcessingError:(nullable NSError *)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNEncryptedInputStream


#pragma mark - Information

@synthesize streamStatus, streamError, delegate;


#pragma mark - Initialization & Configuration

+ (instancetype)inputStreamWithInputStream:(NSInputStream *)inputStream
                                      size:(NSUInteger)size
                                 cipherKey:(NSString *)cipherKey {
    
    return [[self alloc] initWithInputStream:inputStream size:size cipherKey:cipherKey];
}

- (instancetype)initWithInputStream:(NSInputStream *)inputStream
                               size:(NSUInteger)size
                          cipherKey:(NSString *)cipherKey {
    if ((self = [super init])) {
        _encryptor = [PNAES encryptorWithCipherKey:cipherKey];
        _unsentEncryptedDataRange = NSMakeRange(NSNotFound, 0);
        _notProcessedDataRange = NSMakeRange(NSNotFound, 0);
        _inputStream = inputStream;
        _streamDataSize = size;
        _size = [self.encryptor finalTargetBufferSize:size] + self.encryptor.cipherBlockSize;
        
        [self setStreamProcessingError:_encryptor.processingError];
        [self prependInitializationVector];
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
    if (self.streamStatus == NSStreamStatusNotOpen) {
        self.streamStatus = NSStreamStatusOpen;
    }
    
    if (self.inputStream.streamStatus == NSStreamStatusNotOpen) {
        [self.inputStream open];
    }
}

- (void)close {
    if (self.streamStatus != NSStreamStatusError && self.streamStatus != NSStreamStatusClosed) {
        self.streamStatus = NSStreamStatusClosed;
    }
    
    if (self.inputStream.streamStatus != NSStreamStatusError &&
        self.inputStream.streamStatus != NSStreamStatusClosed) {
        
        [self.inputStream close];
    }
    
    
    self.dataBuffer = nil;
}

- (void)scheduleInRunLoop:(NSRunLoop *)__unused aRunLoop forMode:(NSRunLoopMode)__unused mode {
}

- (void)removeFromRunLoop:(NSRunLoop *)__unused aRunLoop forMode:(NSRunLoopMode)__unused mode {
}


#pragma mark - NSInputStream

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)maxLength {
    if (self.streamStatus == NSStreamStatusClosed || self.streamStatus == NSStreamStatusError) {
        return self.streamStatus == NSStreamStatusClosed ? 0 : -1;
    }
    
    NSUInteger bytesToRead = maxLength;
    NSInteger bytesRead = 0;
    
    if (!self.initializationVectorSent) {
        NSRange ivDataRange = NSMakeRange(0, self.encryptor.cipherBlockSize);
        [self.dataBuffer getBytes:buffer range:ivDataRange];
        self.initializationVectorSent = YES;
        bytesRead += ivDataRange.length;
        bytesToRead -= ivDataRange.length;
    }

    if ([self readInputStreamBuffer:(bytesToRead + self.encryptor.cipherBlockSize)] &&
        [self encryptReadBuffer]) {
        
        NSInteger encryptedBytesRead = [self readEncryptedToBuffer:buffer
                                                        withOffset:(NSUInteger)bytesRead
                                                            length:bytesToRead];

        if (encryptedBytesRead >= 0) {
            bytesRead += encryptedBytesRead;
        } else {
            bytesRead = -1;
        }
    } else {
        bytesRead = self.streamStatus == NSStreamStatusError ? -1 : 0;
    }

    return bytesRead;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)length {
    BOOL bufferAvailable = [self.inputStream getBuffer:buffer length:length];
    
    if (!bufferAvailable && (!self.initializationVectorSent || [self hasEncryptedBytesAvailable])) {
        bufferAvailable = YES;
        
        [self.dataBuffer getBytes:buffer length:self.unsentEncryptedDataRange.length];
        *length = self.unsentEncryptedDataRange.length;
    }
    
    if (!bufferAvailable && self.notProcessedDataRange.length) {
        bufferAvailable = YES;
        
        [self.readBuffer getBytes:buffer length:self.notProcessedDataRange.length];
        *length = self.notProcessedDataRange.length;
    }
    
    return bufferAvailable;
}

- (BOOL)hasBytesAvailable {
    return self.inputStream.hasBytesAvailable || [self hasEncryptedBytesAvailable];
}


#pragma mark - Misc

- (NSInteger)readEncryptedToBuffer:(uint8_t *)buffer
                         withOffset:(NSUInteger)offset
                             length:(NSUInteger)length {
    
    length = MIN(length, self.unsentEncryptedDataRange.length);
    NSRange bufferReadRange = NSMakeRange(self.unsentEncryptedDataRange.location, length);
    
    if (self.unsentEncryptedDataRange.location == NSNotFound || self.unsentEncryptedDataRange.length == 0) {
        return 0;
    }
    
    [self.dataBuffer getBytes:&buffer[offset] range:bufferReadRange];
    if (self.unsentEncryptedDataRange.length > length) {
        self.unsentEncryptedDataRange = NSMakeRange(self.unsentEncryptedDataRange.location + length, self.unsentEncryptedDataRange.length - length);
    } else {
        self.unsentEncryptedDataRange = NSMakeRange(NSNotFound, 0);
    }
    
    return (NSInteger)length;
}

- (BOOL)readInputStreamBuffer:(NSUInteger)maxLength {
    if (self.streamStatus == NSStreamStatusError || self.streamStatus == NSStreamStatusClosed) {
        return NO;
    }
    
    NSMutableData *readBuffer = [NSMutableData dataWithLength:maxLength];
    NSData *previousBufferData = nil;
    
    // Check whether some data left in buffer and move it if required.
    if (self.notProcessedDataRange.length > 0) {
        previousBufferData = [self.readBuffer subdataWithRange:self.notProcessedDataRange];
    }
    
    self.notProcessedDataRange = NSMakeRange(NSNotFound, 0);
    NSInteger bytesRead = [self.inputStream read:readBuffer.mutableBytes maxLength:maxLength];
    
    if (bytesRead < 0) {
        [self setStreamProcessingError:self.inputStream.streamError];
        return NO;
    } else {
        self.notProcessedDataRange = NSMakeRange(0, previousBufferData.length + bytesRead);
        self.readStreamSize += bytesRead;
        
        if (previousBufferData) {
            self.readBuffer = [NSMutableData dataWithCapacity:self.notProcessedDataRange.length];
            [self.readBuffer appendData:previousBufferData];
            [self.readBuffer appendData:readBuffer];
        } else {
            self.readBuffer = readBuffer;
            self.readBuffer.length = bytesRead;
        }
    }
    
    return YES;
}

- (BOOL)encryptReadBuffer {
    BOOL shouldFinaliseEncryption = self.streamDataSize == self.readStreamSize;
    NSUInteger readBufferSize = self.notProcessedDataRange.length;
    NSUInteger encryptedBufferSize = 0;
    NSData *previousBufferData = nil;
    NSInteger encryptedLength = 0;
    NSUInteger bytesToRead = 0;
    
    if (!shouldFinaliseEncryption) {
        encryptedBufferSize = [self.encryptor targetBufferSize:readBufferSize];
        bytesToRead = MIN(readBufferSize, encryptedBufferSize);
    } else {
        encryptedBufferSize = [self.encryptor finalTargetBufferSize:readBufferSize];
        bytesToRead = readBufferSize;
    }
    
    
    if (self.streamStatus == NSStreamStatusError || self.streamStatus == NSStreamStatusClosed) {
        return NO;
    }
    
    // Check whether some data left in buffer and move it if required.
    if (self.unsentEncryptedDataRange.length > 0) {
        previousBufferData = [self.dataBuffer subdataWithRange:self.unsentEncryptedDataRange];
    }
    
    NSMutableData *writeBuffer = [NSMutableData dataWithLength:encryptedBufferSize];
    self.unsentEncryptedDataRange = NSMakeRange(NSNotFound, 0);
    
    encryptedLength = [self.encryptor updateProcessedData:writeBuffer
                                             usingRawData:self.readBuffer.mutableBytes
                                               withLength:bytesToRead];
    
    if (self.encryptor.processingError) {
        [self setStreamProcessingError:self.encryptor.processingError];
        return NO;
    }
    
    if (shouldFinaliseEncryption) {
        NSMutableData *finalData = writeBuffer;
        BOOL shouldAppendData = encryptedLength > 0;
        
        if (shouldAppendData) {
            finalData = [NSMutableData dataWithLength:encryptedBufferSize];
            writeBuffer.length = encryptedLength;
        }
        
        encryptedLength += [self.encryptor finalizeProcessedData:finalData
                                                      withLength:(encryptedBufferSize - encryptedLength)];
        
        if (shouldAppendData) {
            [writeBuffer appendData:finalData];
        }
    }

    [self setStreamProcessingError:self.encryptor.processingError];
    
    if (!self.encryptor.processingError) {
        if (previousBufferData.length) {
            encryptedLength += previousBufferData.length;
            self.dataBuffer = [NSMutableData dataWithCapacity:encryptedLength];
            [self.dataBuffer appendData:previousBufferData];
            [self.dataBuffer appendData:writeBuffer];
        } else {
            self.dataBuffer = writeBuffer;
        }
        
        self.unsentEncryptedDataRange = NSMakeRange(0, (NSUInteger)encryptedLength);
        
        if (self.notProcessedDataRange.length > bytesToRead) {
            self.notProcessedDataRange = NSMakeRange(self.notProcessedDataRange.location + bytesToRead,
                                                     self.notProcessedDataRange.length - bytesToRead);
        } else {
            self.notProcessedDataRange = NSMakeRange(NSNotFound, 0);
        }
    }
    
    return self.streamStatus != NSStreamStatusError;
}

- (BOOL)hasEncryptedBytesAvailable {
    return self.unsentEncryptedDataRange.length > 0;
}

- (void)prependInitializationVector {
    if (self.streamStatus != NSStreamStatusError) {
        NSData *initializationVector = self.encryptor.initializationVector;
        self.dataBuffer = [NSMutableData dataWithCapacity:initializationVector.length];
        [self.dataBuffer appendData:initializationVector];
    }
}

- (void)setStreamProcessingError:(NSError *)error {
    if (error) {
        self.streamError = error;
        self.streamStatus = NSStreamStatusError;
    }
}

#pragma mark -


@end
