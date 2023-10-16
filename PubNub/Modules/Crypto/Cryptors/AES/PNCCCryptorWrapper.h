#import <Foundation/Foundation.h>
#import "PNResult.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Wrapper around common cryptor.
///
/// The wrapper provides an interface to the `CCCryptor`, which is used for data _encryption_ and _decryption_.
@interface PNCCCryptorWrapper : NSObject


#pragma mark - Information

/// Wrapper data processing error
@property (nonatomic, nullable, readonly, strong) NSError *error;


#pragma mark - Initialization and configuration

/// Create AES-256 cryptor in CBC mode for encryption.
///
/// - Parameters:
///   - cipherKey: Key which should be used to encrypt data.
///   - initializationVector: Block cipher initialization vector.
/// - Returns: Result of encryption cryptor initialization.
+ (PNResult<PNCCCryptorWrapper *> *)AESCBCEncryptorWithCipherKey:(NSData *)cipherKey
                                            initializationVector:(NSData *)initializationVector;

/// Create AES-256 cryptor in CBC mode for decryption.
///
/// - Parameters:
///   - cipherKey: Key which should be used to decrypt data.
///   - initializationVector: Block cipher initialization vector.
/// - Returns: Result of decryption cryptor initialization.
+ (PNResult<PNCCCryptorWrapper *> *)AESCBCDecryptorWithCipherKey:(NSData *)cipherKey
                                            initializationVector:(NSData *)initializationVector;


#pragma mark - Data processing

/// Process provided data using configured cryptor.
///
/// Depending from used constructor provided data can be _encrypted_ or _decrypted_.
///
/// - Parameter sourceData: Source binary data which should be processed by cryptor.
/// - Returns: Cryptor data processing outcome.
- (PNResult<NSData *> *)processedDataFrom:(NSData *)sourceData;


- (PNResult<NSData *> *)processDataFromDataChunk:(uint8_t *)dataChunk
                                      withLength:(NSUInteger)length
                                    andFinalised:(BOOL)finalised;


#pragma mark - Helpers

/// Calculate final processed data length.
///
/// - Parameter length: Source data length.
/// - Returns: Fully processed data length.
- (NSUInteger)processedDataLength:(NSUInteger)length;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
