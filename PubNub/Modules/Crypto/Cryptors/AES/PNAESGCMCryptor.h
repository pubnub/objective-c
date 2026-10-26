#import <Foundation/Foundation.h>
#import <PubNub/PNCryptor.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// AES-256-GCM cryptor.
///
/// The cryptor provides _decryption_ only, using `AES-256` in `GCM` mode with a cipher key. The nonce and the
/// authentication tag are read from the cryptor metadata stored in the payload header, so no random nonce is generated.
/// When it is registered as a secondary with other cryptors, it will provide backward compatibility with previously
/// encrypted data.
///
/// > Note: Stream _decryption_ buffers the whole encrypted payload in memory, because the authentication tag must be
/// verified before any plaintext is released. Memory use is therefore proportional to the payload size, which matters
/// when decrypting large files.
@interface PNAESGCMCryptor : NSObject <PNCryptor>


#pragma mark - Initialization and configuration

/// Create AES-256-GCM cryptor instance.
///
/// Cryptor will use provided cipher key to _decrypt_ provided data.
///
/// - Parameters:
///   - cipherKey: Key for data _decryption_.
/// - Returns: Initialized AES-256-GCM cryptor instance.
+ (instancetype)cryptorWithCipherKey:(NSString *)cipherKey;

#pragma mark -

@end

NS_ASSUME_NONNULL_END
