#import "PNAESCBCCryptor.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// AES-256-CBС cryptor private extension.
@interface PNAESCBCCryptor (Private)


#pragma mark - Initialization and configuration

/// Initialize cryptor instance.
///
/// - Parameters:
///   - cipherKey: Key for data _encryption_ and _decryption_. 
///   - useRandomInitializationVector: Whether random IV should be used.
/// - Returns: Initialized AES-256-CBC cryptor instance.
- (instancetype)initWithCipherKey:(NSString *)cipherKey
       randomInitializationVector:(BOOL)useRandomInitializationVector;


#pragma mark - Helpers

/// Create digest for cipher key.
///
/// - Parameter key: Cipher key for which SHA-256 digest should be computed.
/// - Returns: There is a digest that will be used with cryptographic functions.
- (NSData *)digestForKey:(NSString *)key;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
