#import "PNEncryptedStream.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// The cryptor's result private extension.
@interface PNEncryptedStream ()


#pragma mark - Initialization and configuration

/// Initiate encrypted stream object.
///
/// An object used to keep track of the results of stream data encryption and the additional data the `cryptor` needs to
/// handle it later.
///
/// - Parameters:
///   - stream: Cryptor input stream with configured by cryptor processing block.
///   - dataLength: Length of encrypted data in stream.
///   - metadata: Additional information is provided by `cryptor` so that encrypted data can be handled later.
/// - Returns: A data object with encrypted data and metadata.
- (instancetype)initWithStream:(PNCryptorInputStream *)stream
                    dataLength:(NSUInteger)dataLength
                      metadata:(nullable NSData *)metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNEncryptedStream

+ (instancetype)encryptedStreamWithStream:(PNCryptorInputStream *)stream
                               dataLength:(NSUInteger)dataLength
                                 metadata:(NSData *)metadata {
    return [[self alloc] initWithStream:stream dataLength:dataLength metadata:metadata];
}

- (instancetype)initWithStream:(PNCryptorInputStream *)stream
                    dataLength:(NSUInteger)dataLength
                      metadata:(nullable NSData *)metadata {
    if ((self = [super init])) {
        _dataLength = dataLength;
        _metadata = metadata;
        _stream = stream;
    }
    
    return self;
}

#pragma mark -


@end

