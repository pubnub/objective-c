#import "PNCryptoModule.h"
#import "PNCryptorInputStream+Private.h"
#import "NSInputStream+PNCrypto.h"
#import "PNSequenceInputStream.h"
#import "PNAESCBCCryptor.h"
#import "PNLegacyCryptor.h"
#import "PNCryptorHeader.h"
#import "PNErrorCodes.h"
#import "PNResult.h"


#pragma mark Extern

/// Null cryptor identifier for legacy cryptors.
NSData *kPNCryptorLegacyIdentifier;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

/// Crypto module private extension.
@interface PNCryptoModule ()


#pragma mark - Information

/// List of known cryptors.
///
/// List of cryptors which is used to decrypt data encrypted by previously used cryptors.
@property(nonatomic, readonly, nullable, strong) NSArray<id<PNCryptor>> *cryptors;

/// Default cryptor.
///
/// Default cryptor used for data encryption and decryption.
@property(nonatomic, readonly, strong) id<PNCryptor> defaultCryptor;


#pragma mark - Initialization and configuration

/// Initialize crypto module.
///
/// Module let register list of cryptors and use them for data encryption in decryption.
///
/// - Parameters:
///   - cryptor: Default cryptor used for data encryption and decryption.
///   - cryptors: List of cryptors which is used to decrypt data encrypted by previously used cryptors.
/// - Returns: Initialized crypto module.
- (instancetype)initWithDefaultCryptor:(id<PNCryptor>)cryptor
                              cryptors:(nullable NSArray<id<PNCryptor>> *)cryptors;


#pragma mark - Helpers

/// Find cryptor with a specified identifier.
///
/// Data decryption can only be done with registered cryptors. An identifier in the cryptor data header is used to
/// identify a suitable cryptor.
///
/// - Parameter identifier: A unicode cryptor identifier.
/// - Returns: Target cryptor or `nil` in case there is none with the specified identifier.
- (nullable id<PNCryptor>)cryptorWithIdentifier:(nullable NSData *)identifier;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNCryptoModule


#pragma mark - Initialization and configuration

+ (void)initialize {
    if (self == [PNCryptoModule class]) {
        kPNCryptorLegacyIdentifier = [[NSMutableData dataWithLength:4] copy];
    }
}

+ (instancetype)moduleWithDefaultCryptor:(id<PNCryptor>)cryptor {
    return [self moduleWithDefaultCryptor:cryptor cryptors:nil];
}

+ (instancetype)moduleWithDefaultCryptor:(id<PNCryptor>)cryptor
                                cryptors:(NSArray<id<PNCryptor>> *)cryptors {
    return [[self alloc] initWithDefaultCryptor:cryptor cryptors:cryptors];
}


+ (instancetype)AESCBCCryptoModuleWithCipherKey:(NSString *)cipherKey
                     randomInitializationVector:(BOOL)useRandomInitializationVector {
    id<PNCryptor> legacyCryptor = [PNLegacyCryptor cryptorWithCipherKey:cipherKey
                                             randomInitializationVector:useRandomInitializationVector];
    id<PNCryptor> aesCBCCryptor = [PNAESCBCCryptor cryptorWithCipherKey:cipherKey];

    return [self moduleWithDefaultCryptor:aesCBCCryptor cryptors:@[legacyCryptor]];
}

+ (instancetype)legacyCryptoModuleWithCipherKey:(NSString *)cipherKey
                     randomInitializationVector:(BOOL)useRandomInitializationVector {
    id<PNCryptor> aesCBCCryptor = [PNAESCBCCryptor cryptorWithCipherKey:cipherKey];
    id<PNCryptor> legacyCryptor = [PNLegacyCryptor cryptorWithCipherKey:cipherKey
                                             randomInitializationVector:useRandomInitializationVector];

    return [self moduleWithDefaultCryptor:legacyCryptor cryptors:@[aesCBCCryptor]];
}

- (instancetype)initWithDefaultCryptor:(id<PNCryptor>)cryptor
                              cryptors:(NSArray<id<PNCryptor>> *)cryptors {
    if ((self = [super init])) {
        _defaultCryptor = cryptor;
        _cryptors = cryptors;
    }
    
    return self;
}


#pragma mark - Data processing

- (PNResult<NSData *> *)encryptData:(NSData *)data {
    PNResult *encryptResult = [self.defaultCryptor encryptData:data];
    if (encryptResult.isError) return (PNResult<NSData *> *)encryptResult;

    PNEncryptedData *encryptedData = encryptResult.data;
    PNCryptorHeader *header = [PNCryptorHeader headerWithCryptorIdentifier:[self.defaultCryptor identifier]
                                                                  metadata:encryptedData.metadata];
    NSData *headerData = [header toData];

    NSUInteger payloadLength = headerData.length + encryptedData.metadata.length + encryptedData.data.length;
    NSMutableData *payload = [NSMutableData dataWithCapacity:payloadLength];

    if (headerData.length > 0) [payload appendData:headerData];
    if (encryptedData.metadata.length > 0) [payload appendData:encryptedData.metadata];
    [payload appendData:encryptedData.data];

    return [PNResult resultWithData:payload error:nil];
}

- (PNResult<NSData *> *)decryptData:(NSData *)data {
    if (data.length == 0) {
        NSError *error = [NSError errorWithDomain:kPNCryptorErrorDomain
                                             code:kPNCryptorDecryptionError
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Unable to encrypt empty data." }];
        return [PNResult resultWithData:nil error:error];
    }

    PNResult<PNCryptorHeader *> *headerResult = [PNCryptorHeader headerFromData:data];
    if (headerResult.isError) return (PNResult<NSData *> *)headerResult;

    PNCryptorHeader *header = headerResult.data;
    id<PNCryptor> cryptor = [self cryptorWithIdentifier:header.identifier];
    NSData *decryptedData = nil;
    NSError *error = nil;

    if (cryptor) {
        NSInteger metadataLength = header.metadataLength;
        NSData *metadata = nil;
        if (metadataLength) {
            metadata = [data subdataWithRange:NSMakeRange(header.length - metadataLength, metadataLength)];
        }

        // Trim cryptor header.
        data = [data subdataWithRange:NSMakeRange(header.length, data.length - header.length)];

        PNEncryptedData *encryptedData = [PNEncryptedData encryptedDataWithData:data metadata:metadata];
        PNResult<NSData *> *decryptResult = [cryptor decryptData:encryptedData];
        if (!decryptResult.isError) decryptedData = decryptResult.data;
        else error = decryptResult.error;
    } else {
        NSString *identifier = [[NSString alloc] initWithData:headerResult.data.identifier
                                                     encoding:NSUTF8StringEncoding];
        NSString *errorMessage = [NSString stringWithFormat:@"Decrypting data created by unknown cryptor. Please make "\
                                  "sure to register '%@' or update the SDK.", identifier];
        error = [NSError errorWithDomain:kPNCryptorErrorDomain
                                    code:kPNCryptorUnknownCryptorError
                                userInfo:@{ NSLocalizedDescriptionKey: errorMessage }];
    }

    return [PNResult resultWithData:decryptedData error:error];
}


#pragma mark - Stream processing

- (PNResult<NSInputStream *> *)encryptStream:(NSInputStream *)stream dataLength:(NSUInteger)length {
    PNResult<PNEncryptedStream *> *encryptResult = [self.defaultCryptor encryptStream:stream dataLength:length];
    if (encryptResult.isError) return (PNResult<NSInputStream *> *)encryptResult;

    PNEncryptedStream *encryptedStream = (PNEncryptedStream *)encryptResult.data;
    PNCryptorHeader *header = [PNCryptorHeader headerWithCryptorIdentifier:[self.defaultCryptor identifier]
                                                                  metadata:encryptedStream.metadata];
    NSData *headerData = [header toData];

    NSUInteger cryptorDataLength = headerData.length + encryptedStream.metadata.length;
    NSMutableData *cryptorData = [NSMutableData dataWithCapacity:cryptorDataLength];

    if (headerData.length > 0) [cryptorData appendData:headerData];
    if (encryptedStream.metadata.length > 0) [cryptorData appendData:encryptedStream.metadata];

    NSInputStream *processedStream = nil;
    if (cryptorData.length) {
        NSInputStream *cryptorStream = [NSInputStream inputStreamWithData:cryptorData];
        NSArray *lengths = @[@(cryptorData.length), @(encryptedStream.dataLength)];
        processedStream = [PNSequenceInputStream inputStreamWithInputStreams:@[cryptorStream, encryptedStream.stream]
                                                                     lengths:lengths];
    } else {
        processedStream = encryptedStream.stream;
    }

    processedStream.pn_dataLength = cryptorData.length + encryptedStream.dataLength;

    return [PNResult resultWithData:processedStream error:nil];
}

- (PNResult<NSInputStream *> *)decryptStream:(NSInputStream *)stream dataLength:(NSUInteger)length {
    if (length == 0) {
        NSError *error = [NSError errorWithDomain:kPNCryptorErrorDomain
                                             code:kPNCryptorDecryptionError
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Unable to encrypt empty data." }];
        return [PNResult resultWithData:nil error:error];
    }

    PNCryptorInputStream *cryptorStream = [PNCryptorInputStream inputStreamWithInputStream:stream dataLength:length];
    PNResult<PNCryptorHeader *> *headerResult = [cryptorStream parseHeader];
    if (headerResult.isError) return (PNResult<NSInputStream *> *)headerResult;

    PNCryptorHeader *header = headerResult.data;
    id<PNCryptor> cryptor = [self cryptorWithIdentifier:header.identifier];
    NSInputStream *decryptedStream = nil;
    NSError *error = nil;

    if (cryptor) {
        PNResult<NSData *> *metadataResult = [cryptorStream readCryptorMetadataWithLength:header.metadataLength];
        if (metadataResult.isError) return (PNResult<NSInputStream *> *)metadataResult;

        PNEncryptedStream *encryptedStream = [PNEncryptedStream encryptedStreamWithStream:cryptorStream
                                                                               dataLength:cryptorStream.inputDataLength
                                                                                 metadata:metadataResult.data];
        PNResult<NSInputStream *> *decryptResult = [cryptor decryptStream:encryptedStream
                                                               dataLength:cryptorStream.inputDataLength];
        if (!decryptResult.isError) decryptedStream = decryptResult.data;
        else error = decryptResult.error;
    } else {
        NSString *identifier = [[NSString alloc] initWithData:headerResult.data.identifier
                                                     encoding:NSUTF8StringEncoding];
        NSString *errorMessage = [NSString stringWithFormat:@"Decrypting data created by unknown cryptor. Please make "\
                                  "sure to register '%@' or update the SDK.", identifier];
        error = [NSError errorWithDomain:kPNCryptorErrorDomain
                                    code:kPNCryptorUnknownCryptorError
                                userInfo:@{ NSLocalizedDescriptionKey: errorMessage }];
    }

    return [PNResult resultWithData:decryptedStream error:error];
}


#pragma mark - Helpers

- (id<PNCryptor>)cryptorWithIdentifier:(NSData *)identifier {
    identifier = identifier ?: kPNCryptorLegacyIdentifier;

    if (!self.cryptors || [[self.defaultCryptor identifier] isEqualToData:identifier]) return self.defaultCryptor;

    for (id<PNCryptor> cryptor in self.cryptors) {
        if ([cryptor.identifier isEqualToData:identifier]) return cryptor;
    }
    
    return nil;
}

#pragma mark -


@end
