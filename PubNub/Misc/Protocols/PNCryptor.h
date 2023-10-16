#import <Foundation/Foundation.h>
#import <PubNub/PNEncryptedStream.h>
#import <PubNub/PNEncryptedData.h>
#import <PubNub/PNResult.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Protocol for custom cryptor.
///
/// A protocol that includes an interface that should be implemented by classes that can be utilized as cryptors in data
/// encryption and decryption.
@protocol PNCryptor <NSObject>


#pragma mark - Information

/// Unique cryptor identifier.
///
/// Identifier will be encoded into crypto data header and passed along with encrypted data.
///
/// > Important: The identifier **must** be 4 bytes long.
///
/// - Returns: Cryptor identifier.
- (NSData *)identifier;


#pragma mark - Data processing

/// Encrypt provided data.
///
/// - Parameter data: Source data for encryption.
/// - Returns: Encryption result object.
- (PNResult<PNEncryptedData *> *)encryptData:(NSData *)data;

/// Decrypt provided data.
///
/// - Parameter data: Previously encrypted data for decryption.
/// - Returns: Decryption result object.
- (PNResult<NSData *> *)decryptData:(PNEncryptedData *)data;


#pragma mark - Stream processing

/// Encrypt data in provided stream.
///
/// - Parameters:
///   - stream: Source stream with data for _encryption_.
///   - length: Length of data in provided stream.
/// - Returns: Encryption result object.
- (PNResult<PNEncryptedStream *> *)encryptStream:(NSInputStream *)stream dataLength:(NSUInteger)length;

/// Decrypt data in provided stream.
///
/// - Parameters:
///   - stream: Source stream with data for _decryption_.
///   - length: Length of data in provided stream.
/// - Returns: Encryption result object.
- (PNResult<NSInputStream *> *)decryptStream:(PNEncryptedStream *)stream dataLength:(NSUInteger)length;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
