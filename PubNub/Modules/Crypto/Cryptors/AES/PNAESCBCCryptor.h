#import <Foundation/Foundation.h>
#import <PubNub/PNCryptor.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// AES-256-CBC cryptor.
///
/// The cryptor provides _encryption_ and _decryption_ using `AES-256` in `CBC` mode with a cipher key and random
/// initialization vector.
/// When it is registered as a secondary with other cryptors, it will provide backward compatibility with previously
/// encrypted data.
@interface PNAESCBCCryptor : NSObject <PNCryptor>


#pragma mark - Initialization and configuration

/// Create AES-256-CBC cryptor instance.
///
/// Cryptor will use provided cipher key and random initialization vector to _encrypt_ and _decrypt_ provided data.
///
/// - Parameters:
///   - cipherKey: Key for data _encryption_ and _decryption_.
/// - Returns: Initialized AES-256-CBC cryptor instance.
+ (instancetype)cryptorWithCipherKey:(NSString *)cipherKey;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
