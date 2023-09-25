#import <Foundation/Foundation.h>
#import <PubNub/PNResult.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Crypto module protocol.
///
/// A protocol with an interface that should be implemented by a class that will be passed as the Crypto module during
/// PubNub client module configuration.
@protocol PNCryptoProvider <NSObject>


#pragma mark - Data processing

/// Encrypt provided data.
///
/// - Parameter data: Source data for encryption.
/// - Returns: Data encryption result with encrypted data or encryption error.
- (PNResult<NSData *> *)encryptData:(NSData *)data;

/// Decrypt provided data.
///
/// - Parameter data: Encrypted data for decryption.
/// - Returns: Data decryption result with decrypted data or decryption error.
- (PNResult<NSData *> *)decryptData:(NSData *)data;


#pragma mark - Stream processing

/// Encrypt data in provided stream.
///
/// - Parameters:
///   - stream: Source stream with data for _encryption_.
///   - length: Length of data in provided stream.
/// - Returns: Encryption result object.
- (PNResult<NSInputStream *> *)encryptStream:(NSInputStream *)stream dataLength:(NSUInteger)length;

/// Decrypt data in provided stream.
///
/// - Parameters:
///   - stream: Source stream with data for _decryption_.
///   - length: Length of data in provided stream.
/// - Returns: Encryption result object.
- (PNResult<NSInputStream *> *)decryptStream:(NSInputStream *)stream dataLength:(NSUInteger)length;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
