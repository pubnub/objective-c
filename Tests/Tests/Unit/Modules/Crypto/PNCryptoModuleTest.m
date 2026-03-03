#import <XCTest/XCTest.h>
#import <PubNub/PNCryptoModule.h>
#import <PubNub/PNAESCBCCryptor.h>
#import <PubNub/PNLegacyCryptor.h>
#import <PubNub/PNEncryptedData.h>
#import <PubNub/PNCryptor.h>
#import <PubNub/PNError.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `PNCryptoModule` unit tests.
///
/// Tests covering crypto module encrypt/decrypt round-trips, multi-cryptor fallback, and error paths.
@interface PNCryptoModuleTest : XCTestCase

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNCryptoModuleTest


#pragma mark - Tests :: NSData encrypt/decrypt round-trip

- (void)testItShouldEncryptAndDecryptNSDataWithAESCBC {
    PNCryptoModule *module = [PNCryptoModule AESCBCCryptoModuleWithCipherKey:@"enigma"
                                                 randomInitializationVector:YES];
    NSData *originalData = [@"Hello, PubNub!" dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<NSData *> *encryptResult = [module encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Encryption should succeed.");
    XCTAssertNotNil(encryptResult.data, @"Encrypted data should not be nil.");
    XCTAssertFalse([encryptResult.data isEqualToData:originalData], @"Encrypted data should differ from original.");

    PNResult<NSData *> *decryptResult = [module decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Decryption should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData, @"Decrypted data should match original.");
}

- (void)testItShouldEncryptAndDecryptNSDataWithLegacyCryptor {
    PNCryptoModule *module = [PNCryptoModule legacyCryptoModuleWithCipherKey:@"enigma"
                                                 randomInitializationVector:YES];
    NSData *originalData = [@"Hello, Legacy!" dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<NSData *> *encryptResult = [module encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Encryption should succeed.");
    XCTAssertNotNil(encryptResult.data, @"Encrypted data should not be nil.");

    PNResult<NSData *> *decryptResult = [module decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Decryption should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData, @"Decrypted data should match original.");
}

- (void)testItShouldEncryptAndDecryptLargeData {
    PNCryptoModule *module = [PNCryptoModule AESCBCCryptoModuleWithCipherKey:@"testKey123"
                                                 randomInitializationVector:YES];
    NSMutableData *originalData = [NSMutableData dataWithLength:100000];
    SecRandomCopyBytes(kSecRandomDefault, originalData.length, originalData.mutableBytes);

    PNResult<NSData *> *encryptResult = [module encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Large data encryption should succeed.");

    PNResult<NSData *> *decryptResult = [module decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Large data decryption should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData, @"Decrypted large data should match original.");
}


#pragma mark - Tests :: NSString encrypt/decrypt round-trip

- (void)testItShouldEncryptAndDecryptStringContentRoundTrip {
    PNCryptoModule *module = [PNCryptoModule AESCBCCryptoModuleWithCipherKey:@"myCipherKey"
                                                 randomInitializationVector:YES];
    NSString *originalString = @"The quick brown fox jumps over the lazy dog";
    NSData *originalData = [originalString dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<NSData *> *encryptResult = [module encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"String encryption should succeed.");

    PNResult<NSData *> *decryptResult = [module decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"String decryption should succeed.");

    NSString *decryptedString = [[NSString alloc] initWithData:decryptResult.data encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(decryptedString, originalString, @"Decrypted string should match original.");
}


#pragma mark - Tests :: Multi-cryptor fallback

- (void)testItShouldDecryptDataEncryptedByFallbackCryptor {
    NSString *cipherKey = @"sharedKey";

    // Encrypt with legacy cryptor as default.
    PNCryptoModule *legacyModule = [PNCryptoModule legacyCryptoModuleWithCipherKey:cipherKey
                                                       randomInitializationVector:YES];
    NSData *originalData = [@"Fallback test data" dataUsingEncoding:NSUTF8StringEncoding];
    PNResult<NSData *> *encryptResult = [legacyModule encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Encryption with legacy module should succeed.");

    // Decrypt with AES-CBC as default, legacy as fallback.
    PNCryptoModule *aesCBCModule = [PNCryptoModule AESCBCCryptoModuleWithCipherKey:cipherKey
                                                       randomInitializationVector:YES];
    PNResult<NSData *> *decryptResult = [aesCBCModule decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Decryption should succeed using fallback legacy cryptor.");
    XCTAssertEqualObjects(decryptResult.data, originalData,
                          @"Decrypted data should match original when using fallback cryptor.");
}

- (void)testItShouldDecryptAESCBCEncryptedDataUsingLegacyModuleWithFallback {
    NSString *cipherKey = @"sharedKey";

    // Encrypt with AES-CBC module.
    PNCryptoModule *aesCBCModule = [PNCryptoModule AESCBCCryptoModuleWithCipherKey:cipherKey
                                                       randomInitializationVector:YES];
    NSData *originalData = [@"AES-CBC encrypted data" dataUsingEncoding:NSUTF8StringEncoding];
    PNResult<NSData *> *encryptResult = [aesCBCModule encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"AES-CBC encryption should succeed.");

    // Decrypt with legacy module (which has AES-CBC as fallback).
    PNCryptoModule *legacyModule = [PNCryptoModule legacyCryptoModuleWithCipherKey:cipherKey
                                                       randomInitializationVector:YES];
    PNResult<NSData *> *decryptResult = [legacyModule decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Decryption should succeed using AES-CBC fallback from legacy module.");
    XCTAssertEqualObjects(decryptResult.data, originalData,
                          @"Decrypted data should match original.");
}


#pragma mark - Tests :: Encrypt produces different ciphertext each time (random IV)

- (void)testItShouldProduceDifferentCiphertextForSameDataDueToRandomIV {
    PNCryptoModule *module = [PNCryptoModule AESCBCCryptoModuleWithCipherKey:@"randomIVKey"
                                                 randomInitializationVector:YES];
    NSData *originalData = [@"Same data, different ciphertext" dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<NSData *> *encryptResult1 = [module encryptData:originalData];
    PNResult<NSData *> *encryptResult2 = [module encryptData:originalData];

    XCTAssertFalse(encryptResult1.isError, @"First encryption should succeed.");
    XCTAssertFalse(encryptResult2.isError, @"Second encryption should succeed.");
    XCTAssertFalse([encryptResult1.data isEqualToData:encryptResult2.data],
                   @"Two encryptions of the same data should produce different ciphertext due to random IV.");
}


#pragma mark - Tests :: Error paths

- (void)testItShouldNotDecryptOriginalDataWithWrongKey {
    PNCryptoModule *encryptModule = [PNCryptoModule AESCBCCryptoModuleWithCipherKey:@"correctKey"
                                                        randomInitializationVector:YES];
    NSString *originalString = @"Secret message";
    NSData *originalData = [originalString dataUsingEncoding:NSUTF8StringEncoding];
    PNResult<NSData *> *encryptResult = [encryptModule encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Encryption should succeed.");

    PNCryptoModule *decryptModule = [PNCryptoModule AESCBCCryptoModuleWithCipherKey:@"wrongKey"
                                                        randomInitializationVector:YES];
    PNResult<NSData *> *decryptResult = [decryptModule decryptData:encryptResult.data];

    if (decryptResult.isError) {
        // Wrong key typically causes PKCS7 padding validation to fail.
        XCTAssertEqualObjects(decryptResult.error.domain, PNCryptorErrorDomain,
                              @"Error domain should be PNCryptorErrorDomain.");
    } else {
        // In rare cases (~0.4%) random garbage may have valid PKCS7 padding; verify content mismatch.
        NSString *decryptedString = [[NSString alloc] initWithData:decryptResult.data
                                                          encoding:NSUTF8StringEncoding];
        XCTAssertFalse([originalString isEqualToString:decryptedString],
                       @"Decrypted data with wrong key should not match the original.");
    }
}

- (void)testItShouldNotDecryptMeaningfulDataFromCorruptPayload {
    PNCryptoModule *module = [PNCryptoModule AESCBCCryptoModuleWithCipherKey:@"testKey"
                                                 randomInitializationVector:YES];

    // Encrypt known data so we can verify corrupt payload doesn't produce it.
    NSString *originalString = @"Known plaintext for comparison";
    NSData *originalData = [originalString dataUsingEncoding:NSUTF8StringEncoding];
    PNResult<NSData *> *validEncryptResult = [module encryptData:originalData];
    XCTAssertFalse(validEncryptResult.isError, @"Encryption should succeed.");

    // Create data that starts with PNED sentinel but has corrupt payload.
    NSMutableData *corruptData = [NSMutableData dataWithData:[@"PNED" dataUsingEncoding:NSUTF8StringEncoding]];
    uint8_t version = 1;
    [corruptData appendBytes:&version length:1];
    [corruptData appendData:[@"ACRH" dataUsingEncoding:NSUTF8StringEncoding]];
    uint8_t metadataLen = 16;
    [corruptData appendBytes:&metadataLen length:1];
    // Append random bytes as "metadata" and "encrypted data".
    NSMutableData *randomBytes = [NSMutableData dataWithLength:48];
    SecRandomCopyBytes(kSecRandomDefault, randomBytes.length, randomBytes.mutableBytes);
    [corruptData appendData:randomBytes];

    PNResult<NSData *> *decryptResult = [module decryptData:corruptData];

    if (!decryptResult.isError) {
        // If padding happened to be valid, the result must still be garbage.
        NSString *decryptedString = [[NSString alloc] initWithData:decryptResult.data
                                                          encoding:NSUTF8StringEncoding];
        XCTAssertFalse([originalString isEqualToString:decryptedString],
                       @"Decrypted corrupt data should not match any known plaintext.");
    }
}

- (void)testItShouldReturnErrorWhenDecryptingEmptyData {
    PNCryptoModule *module = [PNCryptoModule AESCBCCryptoModuleWithCipherKey:@"testKey"
                                                 randomInitializationVector:YES];
    NSData *emptyData = [NSData data];

    PNResult<NSData *> *decryptResult = [module decryptData:emptyData];
    XCTAssertTrue(decryptResult.isError, @"Decrypting empty data should return an error.");
    XCTAssertEqual(decryptResult.error.code, PNCryptorErrorDecryption,
                   @"Error code should indicate decryption failure.");
}

- (void)testItShouldReturnErrorWhenEncryptingEmptyData {
    PNCryptoModule *module = [PNCryptoModule AESCBCCryptoModuleWithCipherKey:@"testKey"
                                                 randomInitializationVector:YES];
    NSData *emptyData = [NSData data];

    PNResult<NSData *> *encryptResult = [module encryptData:emptyData];
    // The underlying AES-CBC cryptor returns an error for empty data.
    XCTAssertTrue(encryptResult.isError, @"Encrypting empty data should return an error.");
    XCTAssertEqual(encryptResult.error.code, PNCryptorErrorEncryption,
                   @"Error code should indicate encryption failure.");
}

- (void)testItShouldReturnErrorWhenDecryptingDataWithUnknownCryptor {
    // Create a module with only legacy cryptor and an explicit empty fallback list.
    // Using @[] (not nil) ensures that `cryptorWithIdentifier:` checks the identifier instead of
    // short-circuiting to the default cryptor when `self.cryptors` is nil.
    id<PNCryptor> legacyCryptor = [PNLegacyCryptor cryptorWithCipherKey:@"testKey" randomInitializationVector:YES];
    PNCryptoModule *legacyOnlyModule = [PNCryptoModule moduleWithDefaultCryptor:legacyCryptor cryptors:@[]];

    // Encrypt using AES-CBC module (which produces PNED header with ACRH identifier).
    PNCryptoModule *aesModule = [PNCryptoModule AESCBCCryptoModuleWithCipherKey:@"testKey"
                                                    randomInitializationVector:YES];
    NSData *originalData = [@"Test data" dataUsingEncoding:NSUTF8StringEncoding];
    PNResult<NSData *> *encryptResult = [aesModule encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Encryption should succeed.");

    // Decrypt with legacy-only module -- should fail because ACRH identifier is unknown.
    PNResult<NSData *> *decryptResult = [legacyOnlyModule decryptData:encryptResult.data];
    XCTAssertTrue(decryptResult.isError, @"Decryption with unknown cryptor should return an error.");
    XCTAssertEqual(decryptResult.error.code, PNCryptorErrorUnknownCryptor,
                   @"Error code should indicate unknown cryptor.");
}


#pragma mark - Tests :: Cross-module compatibility

- (void)testItShouldDecryptDataFromLegacyModuleWithConstantIV {
    NSString *cipherKey = @"myCipherKey";

    // Encrypt with legacy module using constant IV.
    PNCryptoModule *legacyConstIV = [PNCryptoModule legacyCryptoModuleWithCipherKey:cipherKey
                                                        randomInitializationVector:NO];
    NSData *originalData = [@"Constant IV test" dataUsingEncoding:NSUTF8StringEncoding];
    PNResult<NSData *> *encryptResult = [legacyConstIV encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Legacy constant IV encryption should succeed.");

    // Decrypt with the same configuration.
    PNResult<NSData *> *decryptResult = [legacyConstIV decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Legacy constant IV decryption should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData,
                          @"Round-trip with legacy constant IV should preserve original data.");
}

- (void)testItShouldEncryptAndDecryptWithLegacyModuleUsingRandomIV {
    NSString *cipherKey = @"myCipherKey";

    PNCryptoModule *module = [PNCryptoModule legacyCryptoModuleWithCipherKey:cipherKey
                                                 randomInitializationVector:YES];
    NSData *originalData = [@"Random IV legacy test" dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<NSData *> *encryptResult = [module encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Legacy random IV encryption should succeed.");

    PNResult<NSData *> *decryptResult = [module decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Legacy random IV decryption should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData,
                          @"Round-trip with legacy random IV should preserve original data.");
}


#pragma mark -

@end
