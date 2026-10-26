/**
 * @author Serhii Mamontov
 * @copyright © 2010-2026 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <PubNub/PNCryptorInputStream+Private.h>
#import <PubNub/PNAESGCMCryptor.h>
#import <PubNub/PNEncryptedData.h>
#import <PubNub/PNCryptoModule.h>
#import <PubNub/PNJSONDecoder.h>
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNResult.h>
#import <PubNub/PNError.h>
#import "PNSubscribeData.h"
#import "PNSubscribeMessageEventData+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNAESGCMCryptorTests : XCTestCase


#pragma mark - Helpers

/// Convert HEX to binary.
///
/// - Parameter hex: HEX-encoded data.
/// - Returns: Original binary data.
///
- (NSData *)dataFromHex:(NSString *)hex;

/// Hand-crafted list of vectors for decryption test.
///
/// - Returns List of encrypted vectors.
- (NSArray<NSDictionary<NSString *, NSString *> *> *)encryptedTestVectors;

/// Read all data from the stream until it reports end of stream or an error.
///
/// - Parameter stream: Stream to read from. It will be opened and closed by this method.
/// - Returns: Data read from the stream.
- (NSData *)dataFromStream:(NSInputStream *)stream;

/// Create crypto modules which use AES-GCM vectors for decryption.
///
/// - Parameter cipherKey: Key used to create modules.
/// - Returns: Modules created with `AESCBCCryptoModuleWithCipherKey:` and `legacyCryptoModuleWithCipherKey:`.
- (NSArray<PNCryptoModule *> *)cryptoModulesWithCipherKey:(NSString *)cipherKey;

/// Assert that the result is a decryption failure reported through the `PNCryptorErrorDomain`.
///
/// - Parameter result: Result of a decryption attempt.
- (void)assertDecryptionFailure:(PNResult *)result;

/// Decode subscribe event containing a single message through the same decoder used by the network layer.
///
/// - Parameters:
///   - message: Base64-encoded (AES-GCM) message payload.
///   - cryptoModule: Crypto module used to decrypt the message.
/// - Returns: Decoded subscribe response data.
- (PNSubscribeData *)decodedSubscribeDataWithMessage:(NSString *)message cryptoModule:(PNCryptoModule *)cryptoModule;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNAESGCMCryptorTests

#pragma mark - Tests :: Cryptor

- (void)testBinaryDataVectorsDecrypt {
    NSArray<NSDictionary<NSString *, NSString *> *> *vectors = [self encryptedTestVectors];

    for (NSDictionary<NSString *, NSString *> *vector in vectors) {
        NSString *name = vector[@"name"];
        NSData *nonce = [self dataFromHex:vector[@"nonce"]];
        NSData *tag = [self dataFromHex:vector[@"tag"]];
        NSData *ciphertext = [self dataFromHex:vector[@"ciphertext"]];
        NSData *metadata = [self dataFromHex:vector[@"metadata"]];
        NSData *payload = [self dataFromHex:vector[@"payload"]];
        NSMutableData *expectedMetadata = [nonce mutableCopy];
        [expectedMetadata appendData:tag];
        XCTAssertEqualObjects(metadata, expectedMetadata, @"%@ metadata", name);
        NSMutableData *expectedPayload = [[self dataFromHex:@"504e4544014143474d1c"] mutableCopy];
        [expectedPayload appendData:metadata];
        [expectedPayload appendData:ciphertext];
        XCTAssertEqualObjects(payload, expectedPayload, @"%@ envelope", name);
        PNAESGCMCryptor *cryptor = [PNAESGCMCryptor cryptorWithCipherKey:vector[@"key"]];
        PNResult<NSData *> *result = [cryptor decryptData:[PNEncryptedData encryptedDataWithData:ciphertext metadata:metadata]];
        XCTAssertFalse(result.isError, @"%@: %@", name, result.error);
        XCTAssertEqualObjects(result.data, [self dataFromHex:vector[@"plaintext"]], @"%@ plaintext", name);
    }
}

- (void)testStreamDataVectorsDecrypt {
    NSArray<NSDictionary<NSString *, NSString *> *> *vectors = [self encryptedTestVectors];

    for (NSDictionary<NSString *, NSString *> *vector in vectors) {
        PNAESGCMCryptor *cryptor = [PNAESGCMCryptor cryptorWithCipherKey:vector[@"key"]];
        NSData *payload = [self dataFromHex:vector[@"payload"]];
        NSString *name = vector[@"name"];

        NSInputStream *stream = [NSInputStream inputStreamWithData:payload];
        PNCryptorInputStream *cryptorStream = [PNCryptorInputStream inputStreamWithInputStream:stream
                                                                                    dataLength:payload.length];
        PNResult<PNCryptorHeader *> *headerResult = [cryptorStream parseHeader];
        XCTAssertFalse(headerResult.isError, @"%@: %@", name, headerResult.error);

        PNCryptorHeader *header = headerResult.data;
        XCTAssertNotNil(header);
        PNResult<NSData *> *metadataResult = [cryptorStream readCryptorMetadataWithLength:header.metadataLength];
        XCTAssertFalse(metadataResult.isError, @"%@: %@", name, metadataResult.error);
        XCTAssertEqualObjects(header.identifier, cryptor.identifier);

        PNEncryptedStream *encryptedStream = [PNEncryptedStream encryptedStreamWithStream:cryptorStream
                                                                               dataLength:cryptorStream.inputDataLength
                                                                                 metadata:metadataResult.data];
        PNResult<NSInputStream *> *decryptResult = [cryptor decryptStream:encryptedStream
                                                               dataLength:cryptorStream.inputDataLength];
        XCTAssertFalse(decryptResult.isError, @"%@: %@", name, decryptResult.error);

        NSData *decryptedData = [self dataFromStream:decryptResult.data];
        XCTAssertEqualObjects(decryptedData, [self dataFromHex:vector[@"plaintext"]], @"%@ plaintext", name);
    }
}

- (void)testRejectsMetadataWithoutTag {
    PNAESGCMCryptor *cryptor = [PNAESGCMCryptor cryptorWithCipherKey:@"secret"];
    PNResult<NSData *> *result = [cryptor decryptData:[PNEncryptedData encryptedDataWithData:[NSMutableData dataWithLength:15]
                                                                                    metadata:[NSMutableData dataWithLength:12]]];

    [self assertDecryptionFailure:result];
}

- (void)testRejectsMetadataWithShortNonce {
    PNAESGCMCryptor *cryptor = [PNAESGCMCryptor cryptorWithCipherKey:@"secret"];
    PNResult<NSData *> *result = [cryptor decryptData:[PNEncryptedData encryptedDataWithData:[NSMutableData dataWithLength:16]
                                                                                    metadata:[NSMutableData dataWithLength:11]]];

    [self assertDecryptionFailure:result];
}

- (void)testRejectsTamperedAuthenticationTag {
    PNAESGCMCryptor *cryptor = [PNAESGCMCryptor cryptorWithCipherKey:@"enigma"];
    NSMutableData *metadata = [[self dataFromHex:@"0102030405060708090a0b0cdabd1d02d7219c77218ad262c4a9aecc"] mutableCopy];
    ((uint8_t *)metadata.mutableBytes)[12] ^= 1;
    PNResult<NSData *> *result = [cryptor decryptData:[PNEncryptedData encryptedDataWithData:[self dataFromHex:@"ea1b5780788b593294f898"] metadata:metadata]];

    [self assertDecryptionFailure:result];
}

- (void)testRejectsWrongNonce {
    PNAESGCMCryptor *cryptor = [PNAESGCMCryptor cryptorWithCipherKey:@"enigma"];
    NSMutableData *metadata = [[self dataFromHex:@"0102030405060708090a0b0cdabd1d02d7219c77218ad262c4a9aecc"] mutableCopy];
    ((uint8_t *)metadata.mutableBytes)[0] ^= 1;
    PNResult<NSData *> *result = [cryptor decryptData:[PNEncryptedData encryptedDataWithData:[self dataFromHex:@"ea1b5780788b593294f898"] metadata:metadata]];

    [self assertDecryptionFailure:result];
}

- (void)testRejectsTamperedCiphertext {
    PNAESGCMCryptor *cryptor = [PNAESGCMCryptor cryptorWithCipherKey:@"enigma"];
    NSMutableData *ciphertext = [[self dataFromHex:@"ea1b5780788b593294f898"] mutableCopy];
    ((uint8_t *)ciphertext.mutableBytes)[0] ^= 1;
    PNResult<NSData *> *result = [cryptor decryptData:[PNEncryptedData encryptedDataWithData:ciphertext
                                                                                    metadata:[self dataFromHex:@"0102030405060708090a0b0cdabd1d02d7219c77218ad262c4a9aecc"]]];

    [self assertDecryptionFailure:result];
}

- (void)testRejectsTruncatedCiphertext {
    PNAESGCMCryptor *cryptor = [PNAESGCMCryptor cryptorWithCipherKey:@"enigma"];
    NSData *ciphertext = [self dataFromHex:@"ea1b5780788b593294f898"];
    NSData *truncated = [ciphertext subdataWithRange:NSMakeRange(0, ciphertext.length - 1)];
    PNResult<NSData *> *result = [cryptor decryptData:[PNEncryptedData encryptedDataWithData:truncated
                                                                                    metadata:[self dataFromHex:@"0102030405060708090a0b0cdabd1d02d7219c77218ad262c4a9aecc"]]];

    [self assertDecryptionFailure:result];
}

- (void)testRejectsWrongCipherKey {
    PNAESGCMCryptor *cryptor = [PNAESGCMCryptor cryptorWithCipherKey:@"wrong-key"];
    PNResult<NSData *> *result = [cryptor decryptData:[PNEncryptedData encryptedDataWithData:[self dataFromHex:@"ea1b5780788b593294f898"]
                                                                                    metadata:[self dataFromHex:@"0102030405060708090a0b0cdabd1d02d7219c77218ad262c4a9aecc"]]];

    [self assertDecryptionFailure:result];
}

- (void)testEncryptDataReturnsFeatureNotEnabledError {
    PNAESGCMCryptor *cryptor = [PNAESGCMCryptor cryptorWithCipherKey:@"enigma"];
    PNResult<PNEncryptedData *> *result = [cryptor encryptData:[@"Hello world" dataUsingEncoding:NSUTF8StringEncoding]];

    XCTAssertTrue(result.isError);
    XCTAssertNil(result.data);
    XCTAssertEqualObjects(result.error.domain, PNCryptorErrorDomain);
    XCTAssertEqual(result.error.code, PNAPIErrorFeatureNotEnabled);
}

- (void)testEncryptStreamReturnsFeatureNotEnabledError {
    PNAESGCMCryptor *cryptor = [PNAESGCMCryptor cryptorWithCipherKey:@"enigma"];
    NSData *data = [@"Hello world" dataUsingEncoding:NSUTF8StringEncoding];
    PNResult<PNEncryptedStream *> *result = [cryptor encryptStream:[NSInputStream inputStreamWithData:data]
                                                        dataLength:data.length];

    XCTAssertTrue(result.isError);
    XCTAssertNil(result.data);
    XCTAssertEqualObjects(result.error.domain, PNCryptorErrorDomain);
    XCTAssertEqual(result.error.code, PNAPIErrorFeatureNotEnabled);
}


#pragma mark - Tests :: Crypto module

- (void)testCryptoModuleDecryptsVectorsFromDataPayload {
    NSArray<NSDictionary<NSString *, NSString *> *> *vectors = [self encryptedTestVectors];

    for (NSDictionary<NSString *, NSString *> *vector in vectors) {
        NSData *payload = [self dataFromHex:vector[@"payload"]];

        for (PNCryptoModule *module in [self cryptoModulesWithCipherKey:vector[@"key"]]) {
            PNResult<NSData *> *result = [module decryptData:payload];

            XCTAssertFalse(result.isError, @"%@: %@", vector[@"name"], result.error);
            XCTAssertEqualObjects(result.data, [self dataFromHex:vector[@"plaintext"]], @"%@ plaintext", vector[@"name"]);
        }
    }
}

- (void)testCryptoModuleDecryptsVectorsFromStreamPayload {
    NSArray<NSDictionary<NSString *, NSString *> *> *vectors = [self encryptedTestVectors];

    for (NSDictionary<NSString *, NSString *> *vector in vectors) {
        NSData *payload = [self dataFromHex:vector[@"payload"]];

        for (PNCryptoModule *module in [self cryptoModulesWithCipherKey:vector[@"key"]]) {
            PNResult<NSInputStream *> *result = [module decryptStream:[NSInputStream inputStreamWithData:payload]
                                                           dataLength:payload.length];

            XCTAssertFalse(result.isError, @"%@: %@", vector[@"name"], result.error);
            NSData *plaintext = [self dataFromStream:result.data];
            XCTAssertEqualObjects(plaintext, [self dataFromHex:vector[@"plaintext"]], @"%@ plaintext", vector[@"name"]);
        }
    }
}

- (void)testCryptoModuleRejectsTamperedPayload {
    NSDictionary<NSString *, NSString *> *vector = [self encryptedTestVectors].firstObject;
    NSMutableData *payload = [[self dataFromHex:vector[@"payload"]] mutableCopy];
    ((uint8_t *)payload.mutableBytes)[payload.length - 1] ^= 1;

    for (PNCryptoModule *module in [self cryptoModulesWithCipherKey:vector[@"key"]]) {
        PNResult<NSData *> *result = [module decryptData:payload];

        [self assertDecryptionFailure:result];
    }
}

- (void)testCryptoModuleRejectsWrongCipherKey {
    NSDictionary<NSString *, NSString *> *vector = [self encryptedTestVectors].firstObject;
    NSData *payload = [self dataFromHex:vector[@"payload"]];

    for (PNCryptoModule *module in [self cryptoModulesWithCipherKey:@"wrong-key"]) {
        PNResult<NSData *> *result = [module decryptData:payload];

        [self assertDecryptionFailure:result];
    }
}

- (void)testCryptoModuleRejectsTruncatedStream {
    NSDictionary<NSString *, NSString *> *vector = [self encryptedTestVectors].firstObject;
    NSData *payload = [self dataFromHex:vector[@"payload"]];
    NSData *truncated = [payload subdataWithRange:NSMakeRange(0, payload.length - 1)];

    for (PNCryptoModule *module in [self cryptoModulesWithCipherKey:vector[@"key"]]) {
        // Declared length is the full payload, but the stream ends one byte early.
        PNResult<NSInputStream *> *result = [module decryptStream:[NSInputStream inputStreamWithData:truncated]
                                                       dataLength:payload.length];

        XCTAssertTrue(result.isError);
        XCTAssertNil(result.data);
        XCTAssertEqualObjects(result.error.domain, PNCryptorErrorDomain);
        XCTAssertEqual(result.error.code, PNCryptorErrorDecryption);
    }
}

- (void)testCryptoModuleDecryptsMessageAutomatically {
    NSDictionary<NSString *, NSString *> *vector = [self encryptedTestVectors][3];
    NSString *message = [[self dataFromHex:vector[@"payload"]] base64EncodedStringWithOptions:0];

    for (PNCryptoModule *module in [self cryptoModulesWithCipherKey:vector[@"key"]]) {
        PNSubscribeData *data = [self decodedSubscribeDataWithMessage:message cryptoModule:module];

        XCTAssertEqual(data.updates.count, 1);
        PNSubscribeMessageEventData *event = (PNSubscribeMessageEventData *)data.updates.firstObject;
        XCTAssertTrue([event isKindOfClass:[PNSubscribeMessageEventData class]]);
        XCTAssertNil(event.decryptionError);
        XCTAssertEqualObjects(event.message, @{ @"text": @"hello" });
    }
}

- (void)testCryptoModuleReportsDecryptionErrorForTamperedMessage {
    NSDictionary<NSString *, NSString *> *vector = [self encryptedTestVectors][3];
    NSMutableData *payload = [[self dataFromHex:vector[@"payload"]] mutableCopy];
    ((uint8_t *)payload.mutableBytes)[payload.length - 1] ^= 1;
    NSString *message = [payload base64EncodedStringWithOptions:0];

    for (PNCryptoModule *module in [self cryptoModulesWithCipherKey:vector[@"key"]]) {
        PNSubscribeData *data = [self decodedSubscribeDataWithMessage:message cryptoModule:module];

        XCTAssertEqual(data.updates.count, 1);
        PNSubscribeMessageEventData *event = (PNSubscribeMessageEventData *)data.updates.firstObject;
        XCTAssertEqualObjects(event.decryptionError.domain, PNCryptorErrorDomain);
        XCTAssertEqual(event.decryptionError.code, PNCryptorErrorDecryption);
    }
}


#pragma mark - Helpers

- (NSData *)dataFromHex:(NSString *)hex {
    XCTAssertEqual(hex.length % 2, 0u);
    NSMutableData *data = [NSMutableData dataWithCapacity:hex.length / 2];

    for (NSUInteger index = 0; index + 1 < hex.length; index += 2) {
        unsigned int byte = 0;
        NSString *pair = [hex substringWithRange:NSMakeRange(index, 2)];
        NSScanner *scanner = [NSScanner scannerWithString:pair];
        XCTAssertTrue([scanner scanHexInt:&byte]);
        uint8_t value = (uint8_t)byte;
        [data appendBytes:&value length:1];
    }

    return data;
}

- (NSArray<NSDictionary<NSString *, NSString *> *> *)encryptedTestVectors {
    return @[
        @{
            @"name": @"hello",
            @"key": @"enigma",
            @"keySha256": @"67a4f45f0d1d9bc606486fc42dc4941668e71d34ee500735fe9b7ea4625c687c",
            @"plaintext": @"48656c6c6f20776f726c64",
            @"nonce": @"0102030405060708090a0b0c",
            @"tag": @"dabd1d02d7219c77218ad262c4a9aecc",
            @"ciphertext": @"ea1b5780788b593294f898",
            @"metadata": @"0102030405060708090a0b0cdabd1d02d7219c77218ad262c4a9aecc",
            @"payload": @"504e4544014143474d1c0102030405060708090a0b0cdabd1d02d7219c77218ad262c4a9aeccea1b5780788b593294f898"
        },
        @{ @"name": @"unicode",
           @"key": @"enigma",
           @"keySha256": @"67a4f45f0d1d9bc606486fc42dc4941668e71d34ee500735fe9b7ea4625c687c",
           @"plaintext": @"68c3a96c6c6f20e4bda0e5a5bd",
           @"nonce": @"111111111111111111111111",
           @"tag": @"a5dd072360f4433e2979f440fc7827b3",
           @"ciphertext": @"d138fbfc4bd0c337e29d9f2c98",
           @"metadata": @"111111111111111111111111a5dd072360f4433e2979f440fc7827b3",
           @"payload": @"504e4544014143474d1c111111111111111111111111a5dd072360f4433e2979f440fc7827b3d138fbfc4bd0c337e29d9f2c98"
        },
        @{ @"name": @"binary",
           @"key": @"myCipherKey",
           @"keySha256": @"8c33871ac40eea7eb80fdd88465c48f0ee10054de5dfe77af9ed8c0ef626663e",
           @"plaintext": @"00ff7f80",
           @"nonce": @"000102030405060708090a0b",
           @"tag": @"8fefca7becf7235b4d09b970d4d56d19",
           @"ciphertext": @"c411f0f1",
           @"metadata": @"000102030405060708090a0b8fefca7becf7235b4d09b970d4d56d19",
           @"payload": @"504e4544014143474d1c000102030405060708090a0b8fefca7becf7235b4d09b970d4d56d19c411f0f1"
        },
        @{ @"name": @"json",
           @"key": @"enigma",
           @"keySha256": @"67a4f45f0d1d9bc606486fc42dc4941668e71d34ee500735fe9b7ea4625c687c",
           @"plaintext": @"7b2274657874223a2268656c6c6f227d",
           @"nonce": @"2a2a2a2a2a2a2a2a2a2a2a2a",
           @"tag": @"5ec45c5bf84510f3081ef929e1847a47",
           @"ciphertext": @"9146b82b625b4e94b6201d6cf76ed8da",
           @"metadata": @"2a2a2a2a2a2a2a2a2a2a2a2a5ec45c5bf84510f3081ef929e1847a47",
           @"payload": @"504e4544014143474d1c2a2a2a2a2a2a2a2a2a2a2a2a5ec45c5bf84510f3081ef929e1847a479146b82b625b4e94b6201d6cf76ed8da"
        },
        @{ @"name": @"empty",
           @"key": @"enigma",
           @"keySha256": @"67a4f45f0d1d9bc606486fc42dc4941668e71d34ee500735fe9b7ea4625c687c",
           @"plaintext": @"",
           @"nonce": @"0c0d0e0f1011121314151617",
           @"tag": @"ce987c5b7fef3f6d3b1706547f27fece",
           @"ciphertext": @"",
           @"metadata": @"0c0d0e0f1011121314151617ce987c5b7fef3f6d3b1706547f27fece",
           @"payload": @"504e4544014143474d1c0c0d0e0f1011121314151617ce987c5b7fef3f6d3b1706547f27fece"
        }
    ];
}

- (NSData *)dataFromStream:(NSInputStream *)stream {
    NSMutableData *data = [NSMutableData data];
    uint8_t buffer[64];
    NSInteger count = 0;

    [stream open];
    while ((count = [stream read:buffer maxLength:sizeof(buffer)]) > 0) {
        [data appendBytes:buffer length:(NSUInteger)count];
    }
    [stream close];

    return data;
}

- (NSArray<PNCryptoModule *> *)cryptoModulesWithCipherKey:(NSString *)cipherKey {
    return @[
        [PNCryptoModule AESCBCCryptoModuleWithCipherKey:cipherKey randomInitializationVector:NO],
        [PNCryptoModule legacyCryptoModuleWithCipherKey:cipherKey randomInitializationVector:NO]
    ];
}

- (void)assertDecryptionFailure:(PNResult *)result {
    XCTAssertTrue(result.isError);
    XCTAssertNil(result.data);
    XCTAssertEqualObjects(result.error.domain, PNCryptorErrorDomain);
    XCTAssertEqual(result.error.code, PNCryptorErrorDecryption);
}

- (PNSubscribeData *)decodedSubscribeDataWithMessage:(NSString *)message cryptoModule:(PNCryptoModule *)cryptoModule {
    NSDictionary *event = @{
        @"a": @"5",
        @"f": @0,
        @"p": @{ @"t": @"17000000000000000", @"r": @2 },
        @"c": @"ch-a",
        @"e": @0,
        @"d": message
    };
    NSDictionary *payload = @{ @"t": @{ @"t": @"17000000000000000", @"r": @2 }, @"m": @[event] };
    NSError *error;
    PNSubscribeData *data = [PNJSONDecoder decodedObjectOfClass:[PNSubscribeData class]
                                                 fromDictionary:payload
                                             withAdditionalData:@{ @"cryptoModule": cryptoModule }
                                                          error:&error];
    XCTAssertNil(error);

    return data;
}

#pragma mark -


@end
