#import "PNSequenceInputStream.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

///Sequence input stream private extension.
@interface PNSequenceInputStream ()


#pragma mark - Information

/// Sequenced input stream processing error.
@property (readwrite, nullable, copy) NSError *streamError;

/// Sequenced input stream status.
@property (nonatomic, assign) NSStreamStatus streamStatus;

/// Index of stream which currently used to provide requested bytes.
@property (nonatomic, assign) NSUInteger currentStreamIdx;

// Overall stream length.
@property(nonatomic, assign) NSUInteger length;


#pragma mark - Initialization and configuration

/// Init a sequenced input stream.
///
/// - Parameters:
///   - streams: List of input streams that will be represented as one.
///   - lengths: Length of the corresponding input stream in `streams` array.
/// - Returns: Initialized sequence input stream.
- (instancetype)initWithInputStreams:(NSArray<NSInputStream *> *)streams lengths:(NSArray<NSNumber *> *)lengths;


#pragma mark - Helpers

/// Update stream status and error if required.
///
/// - Parameter error: `NSError` instance with information about what exactly went wrong during stream processing.
- (void)setStreamProcessingError:(nullable NSError *)error;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNSequenceInputStream


#pragma mark - Information

@synthesize streamStatus, streamError, delegate;


#pragma mark - Initialization and configuration

+ (instancetype)inputStreamWithInputStreams:(NSArray<NSInputStream *> *)streams lengths:(NSArray<NSNumber *> *)lengths {
    if (streams.count == 0) {
        NSString *reason = @"No input streams passed for sequenced input stream.";
        NSException *exception = [NSException exceptionWithName:@"Sequenced input stream"
                                                         reason:reason
                                                       userInfo:nil];

        @throw exception;
    } else if (streams.count != lengths.count) {
        NSString *reason = @"Number of streams should match to the number of passed stream lengths.";
        NSException *exception = [NSException exceptionWithName:@"Sequenced input stream"
                                                         reason:reason
                                                       userInfo:nil];

        @throw exception;
    }

    return [[self alloc] initWithInputStreams:streams lengths:lengths];
}

- (instancetype)initWithInputStreams:(NSArray<NSInputStream *> *)streams lengths:(NSArray<NSNumber *> *)lengths {
    if ((self = [super init])) {
        _length = ((NSNumber *)[lengths valueForKeyPath: @"@sum.self"]).unsignedIntegerValue;
        _streams = [streams copy];
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
    if (self.streamStatus == NSStreamStatusNotOpen) self.streamStatus = NSStreamStatusOpen;
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


#pragma mark - NSInputStream

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)length {
    NSUInteger totalBytesRead = 0;

    if (self.streamStatus == NSStreamStatusClosed || self.streamStatus == NSStreamStatusError) {
        return self.streamStatus == NSStreamStatusClosed ? 0 : -1;
    }

    while (totalBytesRead < length) {
        if (self.currentStreamIdx == self.streams.count) {
            [self close];
            break;
        }

        NSInputStream *stream = self.streams[self.currentStreamIdx];
        NSUInteger bytesToRead = length - totalBytesRead;
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

- (BOOL)getBuffer:(uint8_t * _Nullable *)buffer length:(NSUInteger *)length {
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


#pragma mark - Helpers

- (void)setStreamProcessingError:(NSError *)error {
    if (!error) return;
    self.streamError = error;
    self.streamStatus = NSStreamStatusError;
}

#pragma mark -


@end
