#import <Foundation/Foundation.h>
#import <PubNub/PNCryptoProvider.h>
#import <PubNub/PNCryptor.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Crypto module for data processing.
///
/// The **PubNub** client uses a module to encrypt and decrypt sent data in a way that's compatible with previous
/// versions (if additional cryptors have been registered).
///
/// - Since: 5.1.4
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNCryptoModule : NSObject<PNCryptoProvider>


#pragma mark - Initialization and configuration

/// Create crypto module instance.
///
/// - Parameters:
///   - cryptor: Default cryptor used for data encryption and decryption.
/// - Returns: Initialized crypto module.
+ (instancetype)moduleWithDefaultCryptor:(id<PNCryptor>)cryptor;

/// Create crypto module instance.
///
/// Module let register list of cryptors and use them for data encryption in decryption.
///
/// - Parameters:
///   - cryptor: Default cryptor used for data encryption and decryption.
///   - cryptors: List of cryptors which is used to decrypt data encrypted by previously used cryptors.
/// - Returns: Initialized crypto module.
+ (instancetype)moduleWithDefaultCryptor:(id<PNCryptor>)cryptor
                                cryptors:(nullable NSArray<id<PNCryptor>> *)cryptors;


/// AES-CBC cryptor based module.
///
/// Data _encryption_ and _decryption_ will be done by default using the `PNAESCBCCryptor`. In addition to the
/// `PNAESCBCCryptor` for data _decryption_, the `PNLegacyCryptor` will be registered for backward-compatibility.
///
/// - Parameters:
///   - cipherKey: Key for data _encryption_ and _decryption_.
///   - useRandomInitializationVector: Whether random IV should be used for data _decryption_.
/// - Returns: Initialized crypto module.
/// - Throws: An exception if passed `cipher_key` is empty.
+ (instancetype)AESCBCCryptoModuleWithCipherKey:(NSString *)cipherKey
                     randomInitializationVector:(BOOL)useRandomInitializationVector;

/// Legacy AES-CBC cryptor based module.
///
/// Data _encryption_ and _decryption_ will be done by default using the `PNLegacyCryptor`. In addition to the
/// `PNLegacyCryptor` for data _decryption_, the `PNAESCBCCryptor` will be registered for future-compatibility (which
/// will help with gradual application updates).
///
/// - Parameters:
///   - cipherKey: Key for data _encryption_ and _decryption_.
///   - useRandomInitializationVector: Whether random IV should be used for data _decryption_.
/// - Returns: Initialized crypto module.
/// - Throws: An exception if passed `cipher_key` is empty.
+ (instancetype)legacyCryptoModuleWithCipherKey:(NSString *)cipherKey
                     randomInitializationVector:(BOOL)useRandomInitializationVector;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
