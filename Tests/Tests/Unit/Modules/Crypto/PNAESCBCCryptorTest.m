#import <XCTest/XCTest.h>
#import <PubNub/PNAESCBCCryptor.h>
#import <PubNub/PNEncryptedData.h>
#import <PubNub/PNCryptor.h>
#import <PubNub/PNError.h>
#import "PNAESCBCCryptor+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// `PNAESCBCCryptor` unit tests.
///
/// Tests covering AES-256-CBC cryptor encrypt/decrypt operations, data sizes, randomness, and error paths.
@interface PNAESCBCCryptorTest : XCTestCase

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNAESCBCCryptorTest


#pragma mark - Tests :: Initialization

- (void)testItShouldHaveACRHIdentifier {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"testKey"];
    NSData *expectedIdentifier = [@"ACRH" dataUsingEncoding:NSUTF8StringEncoding];

    XCTAssertEqualObjects([cryptor identifier], expectedIdentifier,
                          @"AES-CBC cryptor identifier should be 'ACRH'.");
}


#pragma mark - Tests :: Encrypt and decrypt round-trip

- (void)testItShouldEncryptAndDecryptDataRoundTrip {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"enigma"];
    NSData *originalData = [@"Hello, AES-CBC!" dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Encryption should succeed.");
    XCTAssertNotNil(encryptResult.data, @"Encrypted data object should not be nil.");
    XCTAssertNotNil(encryptResult.data.data, @"Encrypted data payload should not be nil.");
    XCTAssertNotNil(encryptResult.data.metadata, @"Metadata (IV) should not be nil for random IV mode.");
    XCTAssertEqual(encryptResult.data.metadata.length, 16u, @"IV should be 16 bytes (AES block size).");

    PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Decryption should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData, @"Decrypted data should match original.");
}


#pragma mark - Tests :: Different data sizes

- (void)testItShouldEncryptAndDecryptSingleByte {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"singleByteKey"];
    uint8_t byte = 0x42;
    NSData *originalData = [NSData dataWithBytes:&byte length:1];

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Single byte encryption should succeed.");

    PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Single byte decryption should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData, @"Single byte round-trip should preserve data.");
}

- (void)testItShouldEncryptAndDecryptExactBlockSize {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"blockSizeKey"];
    // AES block size is 16 bytes.
    NSMutableData *originalData = [NSMutableData dataWithLength:16];
    memset(originalData.mutableBytes, 0xAB, 16);

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Block-aligned data encryption should succeed.");

    PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Block-aligned data decryption should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData,
                          @"Block-aligned data round-trip should preserve data.");
}

- (void)testItShouldEncryptAndDecryptMultipleBlockSize {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"multiBlockKey"];
    // Multiple of block size: 3 * 16 = 48 bytes.
    NSMutableData *originalData = [NSMutableData dataWithLength:48];
    memset(originalData.mutableBytes, 0xCD, 48);

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Multi-block data encryption should succeed.");

    PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Multi-block data decryption should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData,
                          @"Multi-block data round-trip should preserve data.");
}

- (void)testItShouldEncryptAndDecryptLargeData {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"largeDataKey"];
    NSMutableData *originalData = [NSMutableData dataWithLength:65536];
    SecRandomCopyBytes(kSecRandomDefault, originalData.length, originalData.mutableBytes);

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Large data encryption should succeed.");

    PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptResult.data];
    XCTAssertFalse(decryptResult.isError, @"Large data decryption should succeed.");
    XCTAssertEqualObjects(decryptResult.data, originalData,
                          @"Large data round-trip should preserve data.");
}


#pragma mark - Tests :: Random IV verification

- (void)testItShouldProduceDifferentCiphertextForSameInput {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"randomIVKey"];
    NSData *originalData = [@"Deterministic input" dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<PNEncryptedData *> *encryptResult1 = [cryptor encryptData:originalData];
    PNResult<PNEncryptedData *> *encryptResult2 = [cryptor encryptData:originalData];

    XCTAssertFalse(encryptResult1.isError, @"First encryption should succeed.");
    XCTAssertFalse(encryptResult2.isError, @"Second encryption should succeed.");

    // With random IV, both the metadata (IV) and the ciphertext should differ.
    XCTAssertFalse([encryptResult1.data.metadata isEqualToData:encryptResult2.data.metadata],
                   @"IVs should differ between two encryptions of the same data.");
    XCTAssertFalse([encryptResult1.data.data isEqualToData:encryptResult2.data.data],
                   @"Ciphertext should differ between two encryptions due to random IV.");
}

- (void)testItShouldDecryptBothEncryptionsCorrectly {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"multiEncKey"];
    NSData *originalData = [@"Same data, multiple encryptions" dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<PNEncryptedData *> *encryptResult1 = [cryptor encryptData:originalData];
    PNResult<PNEncryptedData *> *encryptResult2 = [cryptor encryptData:originalData];

    PNResult<NSData *> *decryptResult1 = [cryptor decryptData:encryptResult1.data];
    PNResult<NSData *> *decryptResult2 = [cryptor decryptData:encryptResult2.data];

    XCTAssertFalse(decryptResult1.isError, @"First decryption should succeed.");
    XCTAssertFalse(decryptResult2.isError, @"Second decryption should succeed.");
    XCTAssertEqualObjects(decryptResult1.data, originalData, @"First decryption should match original.");
    XCTAssertEqualObjects(decryptResult2.data, originalData, @"Second decryption should match original.");
}


#pragma mark - Tests :: Encrypted data structure

- (void)testItShouldProduceEncryptedDataWithMetadata {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"structureKey"];
    NSData *originalData = [@"Structure test" dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Encryption should succeed.");
    XCTAssertNotNil(encryptResult.data.data, @"Encrypted payload should be present.");
    XCTAssertNotNil(encryptResult.data.metadata, @"Metadata should be present (contains IV).");
    XCTAssertGreaterThan(encryptResult.data.data.length, 0u,
                         @"Encrypted payload should have non-zero length.");
}

- (void)testEncryptedDataLengthShouldBeBlockAligned {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"alignKey"];
    NSData *originalData = [@"Test alignment" dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Encryption should succeed.");
    // AES-CBC with PKCS7 padding always produces output that is a multiple of block size.
    XCTAssertEqual(encryptResult.data.data.length % 16, 0u,
                   @"Encrypted data should be block-aligned (multiple of 16).");
}


#pragma mark - Tests :: Error paths

- (void)testItShouldReturnErrorWhenEncryptingEmptyData {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"emptyKey"];
    NSData *emptyData = [NSData data];

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:emptyData];
    XCTAssertTrue(encryptResult.isError, @"Encrypting empty data should return an error.");
    XCTAssertEqual(encryptResult.error.code, PNCryptorErrorEncryption,
                   @"Error code should indicate encryption failure.");
}

- (void)testItShouldNotDecryptOriginalDataWithWrongKey {
    PNAESCBCCryptor *encryptCryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"correctKey"];
    NSString *originalString = @"Secret data";
    NSData *originalData = [originalString dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<PNEncryptedData *> *encryptResult = [encryptCryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Encryption should succeed.");

    PNAESCBCCryptor *decryptCryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"wrongKey"];
    PNResult<NSData *> *decryptResult = [decryptCryptor decryptData:encryptResult.data];

    if (!decryptResult.isError) {
        // In rare cases (~0.4%) random garbage may have valid PKCS7 padding; verify content mismatch.
        NSString *decryptedString = [[NSString alloc] initWithData:decryptResult.data
                                                          encoding:NSUTF8StringEncoding];
        XCTAssertFalse([originalString isEqualToString:decryptedString],
                       @"Decrypted data with wrong key should not match the original.");
    }
}

- (void)testItShouldNotDecryptOriginalDataFromTruncatedCiphertext {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"truncKey"];
    NSString *originalString = @"Data for truncation test";
    NSData *originalData = [originalString dataUsingEncoding:NSUTF8StringEncoding];

    PNResult<PNEncryptedData *> *encryptResult = [cryptor encryptData:originalData];
    XCTAssertFalse(encryptResult.isError, @"Encryption should succeed.");

    // Truncate the encrypted data to half its length.
    NSData *truncatedData = [encryptResult.data.data subdataWithRange:NSMakeRange(0, encryptResult.data.data.length / 2)];
    PNEncryptedData *truncatedEncrypted = [PNEncryptedData encryptedDataWithData:truncatedData
                                                                        metadata:encryptResult.data.metadata];

    PNResult<NSData *> *decryptResult = [cryptor decryptData:truncatedEncrypted];

    if (!decryptResult.isError) {
        NSString *decryptedString = [[NSString alloc] initWithData:decryptResult.data
                                                          encoding:NSUTF8StringEncoding];
        XCTAssertFalse([originalString isEqualToString:decryptedString],
                       @"Decrypted truncated ciphertext should not match the original.");
    }
}

- (void)testItShouldReturnErrorWhenDecryptingDataShorterThanIVSize {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"shortDataKey"];

    // Create encrypted data with very short payload and no metadata (simulating missing IV).
    NSData *shortData = [NSData dataWithBytes:"AB" length:2];
    PNEncryptedData *encryptedData = [PNEncryptedData encryptedDataWithData:shortData metadata:nil];

    PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptedData];
    // With random IV mode and no metadata, cryptor tries to extract IV from data.
    // Data shorter than block size should produce an error.
    XCTAssertTrue(decryptResult.isError,
                  @"Decrypting data shorter than IV size without metadata should return an error.");
    XCTAssertEqual(decryptResult.error.code, PNCryptorErrorDecryption,
                   @"Error code should indicate decryption failure.");
}

- (void)testItShouldReturnErrorWhenDecryptingEmptyEncryptedData {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"emptyDecKey"];

    // Create encrypted data with empty payload but valid metadata.
    NSMutableData *iv = [NSMutableData dataWithLength:16];
    SecRandomCopyBytes(kSecRandomDefault, iv.length, iv.mutableBytes);
    PNEncryptedData *encryptedData = [PNEncryptedData encryptedDataWithData:[NSData data] metadata:iv];

    PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptedData];
    XCTAssertTrue(decryptResult.isError, @"Decrypting empty encrypted data should return an error.");
    XCTAssertEqual(decryptResult.error.code, PNCryptorErrorDecryption,
                   @"Error code should indicate decryption failure.");
}


#pragma mark - Tests :: Key digest

- (void)testItShouldProduceSHA256DigestForCipherKey {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"testKey"];
    NSData *digest = [cryptor digestForKey:@"testKey"];

    XCTAssertNotNil(digest, @"Digest should not be nil.");
    XCTAssertEqual(digest.length, 32u, @"SHA-256 digest should be 32 bytes long.");
}

- (void)testItShouldProduceDifferentDigestsForDifferentKeys {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"key1"];
    NSData *digest1 = [cryptor digestForKey:@"key1"];
    NSData *digest2 = [cryptor digestForKey:@"key2"];

    XCTAssertFalse([digest1 isEqualToData:digest2],
                   @"Different keys should produce different SHA-256 digests.");
}

- (void)testItShouldProduceConsistentDigestForSameKey {
    PNAESCBCCryptor *cryptor = [PNAESCBCCryptor cryptorWithCipherKey:@"consistentKey"];
    NSData *digest1 = [cryptor digestForKey:@"consistentKey"];
    NSData *digest2 = [cryptor digestForKey:@"consistentKey"];

    XCTAssertEqualObjects(digest1, digest2,
                          @"Same key should always produce the same SHA-256 digest.");
}


#pragma mark -

@end
