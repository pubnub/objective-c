#import <XCTest/XCTest.h>
#import <PubNub/PNLegacyCryptor.h>
#import <PubNub/PNAESCBCCryptor.h>
#import <PubNub/PNEncryptedData.h>
#import <PubNub/PNCryptor.h>
#import <PubNub/PNError.h>
#import "PNAESCBCCryptor+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `PNLegacyCryptor` unit tests.
///
/// Tests covering the legacy AES-256-CBC cryptor: encrypt/decrypt round-trips, compatibility, and error paths.
@interface PNLegacyCryptorTest : XCTestCase

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNLegacyCryptorTest


#pragma mark - Tests :: Initialization

- (void)testItShouldHaveLegacyIdentifier {
    PNLegacyCryptor *cryptor = [PNLegacyCryptor cryptorWithCipherKey:@"testKey"
                                          randomInitializationVector:YES];
    NSData *expectedIdentifier = [[NSMutableData dataWithLength:4] copy];

    XCTAssertEqualObjects([cryptor identifier], expectedIdentifier,
                          @"Legacy cryptor identifier should be 4 zero bytes.");
}

- (void)testItShouldHaveDifferentIdentifierThanAESCBC {
    PNLegacyCryptor *legacyCryptor = [PNLegacyCryptor cryptorWithCipherKey:@"testKey"
                                                randomInitializationVector:YES];
    PNAESCBCCryptor *aesCryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"testKey"];

    XCTAssertFalse([[legacyCryptor identifier] isEqualToData:[aesCryptor identifier]],
                   @"Legacy and AES-CBC cryptors should have different identifiers.");
}


#pragma mark - Tests :: Encrypt and decrypt round-trip with random IV

- (void)testItShouldEncryptAndDecryptWithRandomIV {
    PNLegacyCryptor *cryptor = [PNLegacyCryptor cryptorWithCipherKey:@"enigma"
                                          randomInitializationVector:YES];
    NSData *originalData = [@"Hello, Legacy Cryptor!" dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Encryption with random IV should succeed.");
    XCTAssertNotNil(encryptResult.data, @"Encrypted data should not be nil.");
    XCTAssertNotNil(encryptResult.data.metadata, @"Metadata (IV) should be present for random IV mode.");

    PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Decryption with random IV should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData,
                          @"Decrypted data should match original.");
}


#pragma mark - Tests :: Encrypt and decrypt round-trip with constant IV

- (void)testItShouldEncryptAndDecryptWithConstantIV {
    PNLegacyCryptor *cryptor = [PNLegacyCryptor cryptorWithCipherKey:@"enigma"
                                          randomInitializationVector:NO];
    NSData *originalData = [@"Hello, Constant IV!" dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Encryption with constant IV should succeed.");
    XCTAssertNotNil(encryptResult.data, @"Encrypted data should not be nil.");

    PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Decryption with constant IV should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData,
                          @"Decrypted data should match original.");
}

- (void)testItShouldProduceSameCiphertextWithConstantIV {
    PNLegacyCryptor *cryptor = [PNLegacyCryptor cryptorWithCipherKey:@"constantKey"
                                          randomInitializationVector:NO];
    NSData *originalData = [@"Deterministic" dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<PNEncryptedData *> *encryptResult1 = [cryptor encryptData:originalData];
    PNResult<PNEncryptedData *> *encryptResult2 = [cryptor encryptData:originalData];

    XCTAssertFalse(encryptResult1.isError, @"First encryption should succeed.");
    XCTAssertFalse(encryptResult2.isError, @"Second encryption should succeed.");
    XCTAssertEqualObjects(encryptResult1.data.data, encryptResult2.data.data,
                          @"Constant IV should produce identical ciphertext for same input.");
}

- (void)testItShouldProduceDifferentCiphertextWithRandomIV {
    PNLegacyCryptor *cryptor = [PNLegacyCryptor cryptorWithCipherKey:@"randomKey"
                                          randomInitializationVector:YES];
    NSData *originalData = [@"Non-deterministic" dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<PNEncryptedData *> *encryptResult1 = [cryptor encryptData:originalData];
    PNResult<PNEncryptedData *> *encryptResult2 = [cryptor encryptData:originalData];

    XCTAssertFalse(encryptResult1.isError, @"First encryption should succeed.");
    XCTAssertFalse(encryptResult2.isError, @"Second encryption should succeed.");
    XCTAssertFalse([encryptResult1.data.data isEqualToData:encryptResult2.data.data],
                   @"Random IV should produce different ciphertext for same input.");
}


#pragma mark - Tests :: Different data sizes

- (void)testItShouldHandleSingleByteData {
    PNLegacyCryptor *cryptor = [PNLegacyCryptor cryptorWithCipherKey:@"singleByte"
                                          randomInitializationVector:YES];
    uint8_t byte = 0xFF;
    NSData *originalData = [NSData dataWithBytes:&byte length:1];

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Single byte encryption should succeed.");

    PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Single byte decryption should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData,
                          @"Single byte round-trip should preserve data.");
}

- (void)testItShouldHandleBlockAlignedData {
    PNLegacyCryptor *cryptor = [PNLegacyCryptor cryptorWithCipherKey:@"blockAligned"
                                          randomInitializationVector:YES];
    NSMutableData *originalData = [NSMutableData dataWithLength:32];
    memset(originalData.mutableBytes, 0xBB, 32);

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Block-aligned data encryption should succeed.");

    PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Block-aligned data decryption should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData,
                          @"Block-aligned data round-trip should preserve data.");
}

- (void)testItShouldHandleLargeData {
    PNLegacyCryptor *cryptor = [PNLegacyCryptor cryptorWithCipherKey:@"largeData"
                                          randomInitializationVector:YES];
    NSMutableData *originalData = [NSMutableData dataWithLength:50000];
    SecRandomCopyBytes(kSecRandomDefault, originalData.length, originalData.mutableBytes);

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Large data encryption should succeed.");

    PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Large data decryption should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData,
                          @"Large data round-trip should preserve data.");
}


#pragma mark - Tests :: Legacy key digest

- (void)testItShouldUseLegacyKeyDigest {
    PNLegacyCryptor *legacyCryptor = [PNLegacyCryptor cryptorWithCipherKey:@"testKey"
                                                randomInitializationVector:YES];
    PNAESCBCCryptor *aesCryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"testKey"];

    NSData *legacyDigest = [legacyCryptor digestForKey:@"testKey"];
    NSData *aesDigest = [aesCryptor digestForKey:@"testKey"];

    // Legacy uses hex string of first 16 bytes of SHA-256, while AES-CBC uses raw SHA-256.
    XCTAssertFalse([legacyDigest isEqualToData:aesDigest],
                   @"Legacy key digest should differ from standard AES-CBC key digest.");
    // Legacy digest is hex encoded half of SHA-256 = 16 hex chars * 2 = 32 bytes as string.
    XCTAssertEqual(legacyDigest.length, 32u,
                   @"Legacy key digest should be 32 bytes (hex encoded half of SHA-256).");
}


#pragma mark - Tests :: Error paths

- (void)testItShouldReturnErrorWhenEncryptingEmptyData {
    PNLegacyCryptor *cryptor = [PNLegacyCryptor cryptorWithCipherKey:@"emptyKey"
                                          randomInitializationVector:YES];
    NSData *emptyData = [NSData data];

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:emptyData];
    XCTAssertTrue(encryptResult.isError, @"Encrypting empty data should return an error.");
    XCTAssertEqual(encryptResult.error.code, PNCryptorErrorEncryption,
                   @"Error code should indicate encryption failure.");
}

- (void)testItShouldNotDecryptOriginalDataWithWrongKey {
    PNLegacyCryptor *encryptCryptor = [PNLegacyCryptor cryptorWithCipherKey:@"rightKey"
                                                 randomInitializationVector:YES];
    NSString *originalString = @"Secret message";
    NSData *originalData = [originalString dataUsingEncoding:NSUTF8StringEncoding];
    PNResult<PNEncryptedData *> *encryptResult = [encryptCryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Encryption should succeed.");

    PNLegacyCryptor *decryptCryptor = [PNLegacyCryptor cryptorWithCipherKey:@"wrongKey"
                                                 randomInitializationVector:YES];
    PNResult<NSData *> *decryptResult = [decryptCryptor decryptData:encryptResult.data];

    if (!decryptResult.isError) {
        // In rare cases (~0.4%) random garbage may have valid PKCS7 padding; verify content mismatch.
        NSString *decryptedString = [[NSString alloc] initWithData:decryptResult.data
                                                          encoding:NSUTF8StringEncoding];
        XCTAssertFalse([originalString isEqualToString:decryptedString],
                       @"Decrypted data with wrong key should not match the original.");
    }
}

- (void)testItShouldNotDecryptOriginalDataFromInvalidData {
    PNLegacyCryptor *cryptor = [PNLegacyCryptor cryptorWithCipherKey:@"invalidKey"
                                          randomInitializationVector:YES];

    // Create encrypted data with random garbage.
    NSMutableData *garbageData = [NSMutableData dataWithLength:64];
    SecRandomCopyBytes(kSecRandomDefault, garbageData.length, garbageData.mutableBytes);
    NSMutableData *fakeIV = [NSMutableData dataWithLength:16];
    SecRandomCopyBytes(kSecRandomDefault, fakeIV.length, fakeIV.mutableBytes);
    PNEncryptedData *encryptedData = [PNEncryptedData encryptedDataWithData:garbageData metadata:fakeIV];

    PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptedData];

    if (!decryptResult.isError) {
        // If padding happened to be valid, the result must still be garbage (not meaningful data).
        XCTAssertFalse([decryptResult.data isEqualToData:garbageData],
                       @"Decrypted data should not match the original garbage input.");
    }
}

- (void)testItShouldReturnErrorWhenDecryptingDataShorterThanIVWithoutMetadata {
    PNLegacyCryptor *cryptor = [PNLegacyCryptor cryptorWithCipherKey:@"shortKey"
                                          randomInitializationVector:YES];

    // 10 bytes - shorter than AES block size with no metadata.
    NSData *shortData = [NSData dataWithBytes:"0123456789" length:10];
    PNEncryptedData *encryptedData = [PNEncryptedData encryptedDataWithData:shortData metadata:nil];

    PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptedData];
    XCTAssertTrue(decryptResult.isError,
                  @"Decrypting data shorter than IV size without metadata should return an error.");
}


#pragma mark - Tests :: Interop between random and constant IV configurations

- (void)testItShouldNotDecryptConstantIVDataWithRandomIVCryptor {
    NSString *cipherKey = @"interopKey";

    PNLegacyCryptor *constantCryptor = [PNLegacyCryptor cryptorWithCipherKey:cipherKey
                                                  randomInitializationVector:NO];
    PNLegacyCryptor *randomCryptor = [PNLegacyCryptor cryptorWithCipherKey:cipherKey
                                                randomInitializationVector:YES];

    NSData *originalData = [@"Interop test data" dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<PNEncryptedData *> *encryptResult = [constantCryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Constant IV encryption should succeed.");

    // The constant IV cryptor does not put IV in metadata (metadata is nil).
    // A random IV cryptor will try to extract IV from the data bytes, which will be misinterpreted.
    // The result may be an error or garbled data depending on padding.
    PNResult<NSData *> *decryptResult = [randomCryptor decryptData:encryptResult.data];
    // Either error or data mismatch is acceptable here.
    if (!decryptResult.isError) {
        XCTAssertFalse([decryptResult.data isEqualToData:originalData],
                       @"Constant IV data decrypted with random IV config should not match original.");
    }
}


#pragma mark -

@end
