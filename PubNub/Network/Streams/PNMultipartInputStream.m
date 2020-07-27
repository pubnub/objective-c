#import "PNMultipartInputStream.h"
#import "PNEncryptedInputStream.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface PNMultipartInputStream ()


#pragma mark - Information

/**
 * @brief List of input streams from which data will be read.
 *
 * @discussion Input streams will be read one after another (in same order as they appear in
 * array) seamlessly to make it looks like work with single input stream.
 */
@property (nonatomic, strong) NSArray<NSInputStream *> *streams;

/**
 * @brief Multi part input stream processing error.
 */
@property (readwrite, nullable, copy) NSError *streamError;

/**
 * @brief Encrypted input stream status.
 */
@property (nonatomic, assign) NSStreamStatus streamStatus;

/**
 * @brief Index of stream which currently used to provide requested bytes.
 */
@property (nonatomic, assign) NSUInteger currentStreamIdx;

/**
 * @brief Overall stream size.
 */
@property (nonatomic, assign) NSUInteger size;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize multipart form data body input stream.
 *
 * @param streams List of input stream which should be appended to request body.
 * @param sizes List with information about size of data which can be provided by each stream.
 * @param cipherKey Key which should be used to encrypt stream content.
 *
 * @return Initialized and ready multipart form data body input stream.
 */
- (instancetype)initWithInputStreams:(NSArray<NSInputStream *> *)streams
                               sizes:(NSArray<NSNumber *> *)sizes
                           cipherKey:(NSString *)cipherKey;


#pragma mark - Misc

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

@implementation PNMultipartInputStream


#pragma mark - Information

@synthesize streamStatus, streamError, delegate;


#pragma mark - Initialization & Configuration

+ (instancetype)streamWithInputStreams:(NSArray<NSInputStream *> *)streams
                                 sizes:(NSArray<NSNumber *> *)sizes
                             cipherKey:(NSString *)cipherKey {
    
    if (streams.count == 0) {
        NSString *reason = @"Empty list of streams passed for multipart form/data has been passed.";
        NSException *exception = [NSException exceptionWithName:@"Multipart form/data"
                                                         reason:reason
                                                       userInfo:nil];
        
        @throw exception;
    }
    
    return [[self alloc] initWithInputStreams:streams sizes:sizes cipherKey:cipherKey];
}

- (instancetype)initWithInputStreams:(NSArray<NSInputStream *> *)streams
                               sizes:(NSArray<NSNumber *> *)sizes
                           cipherKey:(NSString *)cipherKey {
    
    if ((self = [super init])) {
        NSUInteger streamsSize = ((NSNumber *)[sizes valueForKeyPath: @"@sum.self"]).unsignedIntegerValue;
        
        if (cipherKey.length) {
            NSMutableArray *mutableStreams = [NSMutableArray arrayWithArray:streams];
            // Hardcoded stream idx (because each request send only one file).
            NSUInteger streamIdx = 2;
            NSUInteger fileSize = sizes[streamIdx].unsignedIntegerValue;
            streamsSize -= fileSize;

            NSInputStream *stream = streams[streamIdx];
            mutableStreams[streamIdx] = [PNEncryptedInputStream inputStreamWithInputStream:stream
                                                                                      size:fileSize
                                                                                 cipherKey:cipherKey];
            streamsSize += ((PNEncryptedInputStream *)mutableStreams[streamIdx]).size;
            _streams = [NSArray arrayWithArray:mutableStreams];
        } else {
            _streams = [NSArray arrayWithArray:streams];
        }
        
        _size = streamsSize;
    }
    
    return self;
}


#pragma mark - NSStream

- (id)propertyForKey:(NSStreamPropertyKey)__unused key {
    return nil;
}

- (BOOL)setProperty:(id)__unused property forKey:(NSStreamPropertyKey)__unused key {
    return NO;
}

- (void)open {
    if (self.streamStatus == NSStreamStatusNotOpen) {
        self.streamStatus = NSStreamStatusOpen;
    }
}

- (void)close {
    if (self.streamStatus != NSStreamStatusError && self.streamStatus != NSStreamStatusClosed) {
        self.streamStatus = NSStreamStatusClosed;
    }
}

- (void)scheduleInRunLoop:(NSRunLoop *)__unused aRunLoop forMode:(NSRunLoopMode)__unused mode {
}

- (void)removeFromRunLoop:(NSRunLoop *)__unused aRunLoop forMode:(NSRunLoopMode)__unused mode {
}


#pragma mark - NSInputStream subclass methods

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)maxLength {
    NSUInteger totalBytesRead = 0;

    if (self.streamStatus == NSStreamStatusClosed || self.streamStatus == NSStreamStatusError) {
        return self.streamStatus == NSStreamStatusClosed ? 0 : -1;
    }

    while (totalBytesRead < maxLength) {
        if (self.currentStreamIdx == self.streams.count) {
            [self close];
            break;
        }

        NSInputStream *stream = self.streams[self.currentStreamIdx];
        NSUInteger bytesToRead = maxLength - totalBytesRead;
        NSInteger bytesRead = 0;
        
        if (stream.streamStatus == NSStreamStatusNotOpen) {
            [stream open];
        }

        bytesRead = [stream read:&buffer[totalBytesRead] maxLength:bytesToRead];
        
        if (bytesRead == 0 || bytesRead < bytesToRead) {
            [stream close];
            self.currentStreamIdx++;
        } else if (bytesRead < 0) {
            [self setStreamProcessingError:stream.streamError];
            [stream close];
            [self close];
            return -1;
        }
        
        totalBytesRead += bytesRead;
    }
    
    return totalBytesRead;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)length {
    BOOL bufferAvailable = [self hasBytesAvailable];

    if (bufferAvailable) {
        NSInputStream *stream = self.streams[self.currentStreamIdx];
        bufferAvailable = [stream getBuffer:buffer length:length];
    }

    return bufferAvailable;
}

- (BOOL)hasBytesAvailable {
    return YES;
}


#pragma mark - Misc

- (void)setStreamProcessingError:(NSError *)error {
    if (error) {
        self.streamError = error;
        self.streamStatus = NSStreamStatusError;
    }
}

#pragma mark -


@end
