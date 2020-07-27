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
 * @brief Whether initialization vector for data encryption has been sent to read buffer or not.
 */
@property (nonatomic, assign) BOOL initializationVectorSent;

/**
 * @brief Underlying input stream whose data should be encrypted on-demand.
 */
@property (nonatomic, strong) NSInputStream *inputStream;

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
@property (nonatomic, assign) NSRange dataRange;

/**
 * @brief Size of data which will be provided by \c inputStream.
 */
@property (nonatomic, assign) NSUInteger streamDataSize;

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
 * @brief Encrypt content of input stream.
 *
 * @param maxLength Maximum length of data from input stream to be encrypted.
 *
 * @return \c YES in case if read and encryption was successful.
 */
- (BOOL)encryptInputStreamBuffer:(NSUInteger)maxLength;

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
        _dataRange = NSMakeRange(NSNotFound, 0);
        _inputStream = inputStream;
        _streamDataSize = size;
        _size = [self.encryptor targetBufferSize:size] + self.encryptor.cipherBlockSize;
        
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
        [self.dataBuffer getBytes:buffer range:self.dataRange];
        self.initializationVectorSent = YES;
        bytesRead += self.dataRange.length;
        bytesToRead -= self.dataRange.length;
    }

    if ([self encryptInputStreamBuffer:bytesToRead]) {
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
        
        [self.dataBuffer getBytes:buffer length:self.dataRange.length];
        *length = self.dataRange.length;
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
    
    length = MIN(length, self.dataRange.length);
    NSRange bufferReadRange = NSMakeRange(self.dataRange.location, length);
    
    if (self.dataRange.location == NSNotFound || self.dataRange.length == 0) {
        return 0;
    }
    
    [self.dataBuffer getBytes:&buffer[offset] range:bufferReadRange];
    
    if (self.dataRange.length > length) {
        self.dataRange = NSMakeRange(self.dataRange.location + length, self.dataRange.length - length);
    } else {
        self.dataRange = NSMakeRange(NSNotFound, 0);
    }
    
    return (NSInteger)length;
}

- (BOOL)encryptInputStreamBuffer:(NSUInteger)maxLength {
    NSUInteger bytesToRead = [self.encryptor targetBufferSize:maxLength];
    self.dataRange = NSMakeRange(NSNotFound, 0);
    NSInteger encryptedLength = 0;
    
    if (self.streamStatus == NSStreamStatusError || self.streamStatus == NSStreamStatusClosed) {
        return NO;
    }
    
    self.dataBuffer = [NSMutableData dataWithLength:bytesToRead];
    NSMutableData *readBuffer = [NSMutableData dataWithLength:bytesToRead];
    NSInteger bytesRead = [self.inputStream read:readBuffer.mutableBytes maxLength:maxLength];
    
    if (bytesRead > 0) {
        encryptedLength = [self.encryptor updateProcessedData:self.dataBuffer
                                                 usingRawData:readBuffer.mutableBytes
                                                   withLength:(NSUInteger)bytesRead];
    }

    if (!self.encryptor.processingError && (bytesRead == 0 || bytesRead < bytesToRead)) {
        NSMutableData *finalyzedData = self.dataBuffer;
        BOOL appendingData = encryptedLength > 0;
        
        if (appendingData) {
            finalyzedData = [NSMutableData dataWithLength:bytesToRead];
            self.dataBuffer.length = encryptedLength;
        }
        
        encryptedLength += [self.encryptor finalizeProcessedData:finalyzedData
                                                      withLength:(NSUInteger)maxLength];
        
        if (appendingData) {
            [self.dataBuffer appendData:finalyzedData];
            self.dataBuffer.length = encryptedLength;
        }
        
        self.dataBuffer.length = encryptedLength;
    } else if (bytesRead < 0) {
        [self setStreamProcessingError:self.inputStream.streamError];
        return NO;
    }

    [self setStreamProcessingError:self.encryptor.processingError];
    
    if (!self.encryptor.processingError) {
        self.dataRange = NSMakeRange(0, (NSUInteger)encryptedLength);
    }
    
    return self.streamStatus != NSStreamStatusError;
}

- (BOOL)hasEncryptedBytesAvailable {
    return self.dataRange.length > 0;
}

- (void)prependInitializationVector {
    if (self.streamStatus != NSStreamStatusError) {
        NSData *initializationVector = self.encryptor.initializationVector;
        self.dataBuffer = [NSMutableData dataWithCapacity:initializationVector.length];
        [self.dataBuffer appendData:initializationVector];
        self.dataRange = NSMakeRange(0, self.dataBuffer.length);
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
