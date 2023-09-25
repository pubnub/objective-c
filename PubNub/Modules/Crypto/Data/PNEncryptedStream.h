#import <Foundation/Foundation.h>
#import <PubNub/PNCryptorInputStream.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// The cryptor's result representation for stream data.
///
/// And object used to pass cryptor outcomes (stream with encrypted data and cryptor-redefined metadata) between cryptor
/// module components.
///
/// - Since: 5.1.4
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNEncryptedStream : NSObject


#pragma mark - Information

/// Stream with encrypted data.
@property(nonatomic, readonly, strong) PNCryptorInputStream *stream;

/// Cryptor-defined metadata.
///
/// Cryptor may provide here any information which will be useful when data should be decrypted.
///
/// For example `metadata` may contain:
/// * initialization vector
/// * cipher key identifier
/// * encrypted `data` length.
@property(nonatomic, readonly, nullable, strong) NSData *metadata;

/// Length of encrypted data in stream.
@property(nonatomic, readonly, assign) NSUInteger dataLength;


#pragma mark - Initialization and configuration

/// Create encrypted stream object.
///
/// An object used to keep track of the results of stream data encryption and the additional data the `cryptor` needs to
/// handle it later.
///
/// - Parameters:
///   - stream: Cryptor input stream with configured by cryptor processing block.
///   - dataLength: Length of encrypted data in the stream.
///   - metadata: Additional information is provided by `cryptor` so that encrypted data can be handled later.
/// - Returns: A data object with encrypted data and metadata.
+ (instancetype)encryptedStreamWithStream:(PNCryptorInputStream *)stream
                               dataLength:(NSUInteger)dataLength
                                 metadata:(nullable NSData *)metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
