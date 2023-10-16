#import <PubNub/PNAESCBCCryptor.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Legacy cryptor.
///
/// The cryptor provides _encryption_ and _decryption_ using `AES-256` in `CBC` mode with a cipher key and configurable
/// initialization vector randomness.
/// When it is registered as a secondary with other cryptors, it will provide backward compatibility with previously
/// encrypted data.
///
/// > Important: It has been reported that the digest from cipherKey has low entropy, and it is suggested to use
/// `PNAESCBCCryptor` instead.
@interface PNLegacyCryptor : PNAESCBCCryptor <PNCryptor>


#pragma mark - Initialization and configuration

/// Create legacy cryptor instance.
///
/// - Parameters:
///   - cipherKey: Key for data _encryption_ and _decryption_. 
///   - useRandomInitializationVector: Whether random IV should be used.
/// - Returns: Initialized AES-256-CBC cryptor instance.
+ (instancetype)cryptorWithCipherKey:(NSString *)cipherKey
            randomInitializationVector:(BOOL)useRandomInitializationVector;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
