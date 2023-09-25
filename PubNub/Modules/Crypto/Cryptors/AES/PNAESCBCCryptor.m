#import "PNAESCBCCryptor+Private.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "PNCryptorInputStream+Private.h"
#import "PNCCCryptorWrapper.h"
#import "PNEncryptedStream.h"
#import "PNErrorCodes.h"


#pragma mark Contants

/// C identifier for legacy cryptors.
static NSData *kPNAESCBCCryptorIdentifier;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

/// AES-256-CBС cryptor private extension.
@interface PNAESCBCCryptor ()


#pragma mark - Information

/// Initialization vector which should be used for data _encryption_.
@property(nonatomic, strong) NSData *initializationVector;

/// Whether random initialization vector should be used for data _encryption_ or not.
@property(nonatomic, readonly) BOOL useRandomIV;

/// Key for data _encryption_ and _decryption_.
@property(nonatomic, strong) NSData *cipherKey;


#pragma mark - Initialization and configuration

/// Initialize cryptor instance.
///
/// - Parameters:
///   - cipherKey: Key for data _encryption_ and _decryption_. 
///   - useRandomInitializationVector: Whether random IV should be used.
/// - Returns: Initialized AES-256-CBC cryptor instance.
- (instancetype)initWithCipherKey:(NSString *)cipherKey
       randomInitializationVector:(BOOL)useRandomInitializationVector;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNAESCBCCryptor


#pragma mark - Information

- (NSData *)identifier {
    return kPNAESCBCCryptorIdentifier;
}

- (NSData *)initializationVector {
    if (!self.useRandomIV) return _initializationVector;
    else {
        uint8_t vectorBytes[kCCBlockSizeAES128];
        
        if (SecRandomCopyBytes(kSecRandomDefault, kCCBlockSizeAES128, vectorBytes) != kCCSuccess) {
            NSData *randomBytes = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
            [randomBytes getBytes:vectorBytes length:kCCBlockSizeAES128];
        }
        
        return [NSData dataWithBytes:vectorBytes length:kCCBlockSizeAES128];
    }
}


#pragma mark - Initialization and configuration

+ (void)initialize {
    if (self == [PNAESCBCCryptor class]) {
        kPNAESCBCCryptorIdentifier = [@"ACRH" dataUsingEncoding:NSUTF8StringEncoding];
    }
}

+ (instancetype)cryptorWithCipherKey:(NSString *)cipherKey {
    return [[self alloc] initWithCipherKey:cipherKey randomInitializationVector:YES];
}

- (instancetype)initWithCipherKey:(NSString *)cipherKey randomInitializationVector:(BOOL)useRandomInitializationVector {
    if ((self = [super init])) {
        if (!useRandomInitializationVector) _initializationVector = [NSData dataWithBytes:"0123456789012345" length:16];
        _useRandomIV = useRandomInitializationVector;
        _cipherKey = [self digestForKey:cipherKey];
    }
    
    return self;
}


#pragma mark - Data processing

- (PNResult<PNEncryptedData *> *)encryptData:(NSData *)data {
    NSData *initializationVector = self.initializationVector;
    PNResult<PNCCCryptorWrapper *> *wrapper = [PNCCCryptorWrapper AESCBCEncryptorWithCipherKey:self.cipherKey
                                                                          initializationVector:initializationVector];
    if (wrapper.isError) return (PNResult<PNEncryptedData *> *)wrapper;

    PNResult<NSData *> *processResult = [wrapper.data processedDataFrom:data];
    if (processResult.isError) return (PNResult<PNEncryptedData *> *)processResult;

    NSData *metadata = self.useRandomIV ? initializationVector : nil;

    return [PNResult resultWithData:[PNEncryptedData encryptedDataWithData:processResult.data metadata:metadata]
                              error:nil];
}

- (PNResult<NSData *> *)decryptData:(PNEncryptedData *)data {
    NSData *initializationVector = data.metadata.length ? data.metadata
                                                        : (!self.useRandomIV ? self.initializationVector : nil);
    NSData *encryptedData = data.data;

    if (!initializationVector && self.useRandomIV) {
        if (encryptedData.length > kCCBlockSizeAES128) {
            NSUInteger encryptedDataLength = encryptedData.length - kCCBlockSizeAES128;
            initializationVector = [encryptedData subdataWithRange:NSMakeRange(0, kCCBlockSizeAES128)];
            encryptedData = [encryptedData subdataWithRange:NSMakeRange(kCCBlockSizeAES128, encryptedDataLength)];
        } else {
            NSError *error = [NSError errorWithDomain:kPNCryptorErrorDomain
                                                 code:kPNCryptorDecryptionError
                                             userInfo:@{
                NSLocalizedDescriptionKey: @"Insufficient amount of data to read cryptor-defined metadata."
            }];

            return [PNResult resultWithData:nil error:error];
        }
    }

    PNResult<PNCCCryptorWrapper *> *wrapper = [PNCCCryptorWrapper AESCBCDecryptorWithCipherKey:self.cipherKey
                                                                          initializationVector:initializationVector];
    if (wrapper.isError) return (PNResult<NSData *> *)wrapper;

    return [wrapper.data processedDataFrom:encryptedData];
}


#pragma mark - Stream processing

- (PNResult<PNEncryptedStream *> *)encryptStream:(NSInputStream *)stream dataLength:(NSUInteger)length {
    NSData *initializationVector = self.initializationVector;
    PNResult<PNCCCryptorWrapper *> *wrapper = [PNCCCryptorWrapper AESCBCEncryptorWithCipherKey:self.cipherKey
                                                                          initializationVector:initializationVector];
    if (wrapper.isError) return (PNResult<PNEncryptedStream *> *)wrapper;

    PNCryptorInputStream *cryptorStream = nil;
    cryptorStream = [PNCryptorInputStream inputStreamWithInputStream:stream
                                                          dataLength:length
                                                         chunkLength:kCCBlockSizeAES128
                                                     processingBlock:[self processingBlockForWrapper:wrapper.data]];

    NSData *metadata = self.useRandomIV ? initializationVector : nil;
    NSUInteger encryptedDataLength = [wrapper.data processedDataLength:length];
    PNEncryptedStream *encryptedStream = [PNEncryptedStream encryptedStreamWithStream:cryptorStream
                                                                           dataLength:encryptedDataLength
                                                                             metadata:metadata];

    return [PNResult resultWithData:encryptedStream error:nil];
}

- (PNResult<NSInputStream *> *)decryptStream:(PNEncryptedStream *)stream dataLength:(NSUInteger)length {
    NSData *initializationVector = stream.metadata.length ? stream.metadata
                                                          : (!self.useRandomIV ? self.initializationVector : nil);

    if (!initializationVector && self.useRandomIV) {
        if (length > kCCBlockSizeAES128) {
            initializationVector = [stream.stream readCryptorMetadataWithLength:kCCBlockSizeAES128].data;
        } else {
            NSError *error = [NSError errorWithDomain:kPNCryptorErrorDomain
                                                 code:kPNCryptorDecryptionError
                                             userInfo:@{
                NSLocalizedDescriptionKey: @"Insufficient amount of data to read cryptor-defined metadata."
            }];

            return [PNResult resultWithData:nil error:error];
        }
    }


    PNResult<PNCCCryptorWrapper *> *wrapper = [PNCCCryptorWrapper AESCBCDecryptorWithCipherKey:self.cipherKey
                                                                          initializationVector:initializationVector];
    if (wrapper.isError) return (PNResult<NSInputStream *> *)wrapper;

    PNCryptorInputStream *cryptorStream = nil;
    cryptorStream = [PNCryptorInputStream inputStreamWithInputStream:stream.stream
                                                          dataLength:stream.stream.inputDataLength
                                                         chunkLength:kCCBlockSizeAES128
                                                     processingBlock:[self processingBlockForWrapper:wrapper.data]];

    return [PNResult resultWithData:cryptorStream error:nil];
}


- (PNCryptorInputStreamChunkProcessingBlock)processingBlockForWrapper:(PNCCCryptorWrapper *)wrapper {
    return ^PNResult<NSData *> *(uint8_t *buffer, NSUInteger bufferLength, BOOL finalyze) {
        return [wrapper processDataFromDataChunk:buffer withLength:bufferLength andFinalised:finalyze];
    };
}


#pragma mark - Helpers

- (NSData *)digestForKey:(NSString *)key {
    NSMutableData *digestData = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    NSData *data = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    CC_SHA256(data.bytes, (CC_LONG)data.length, digestData.mutableBytes);
    
    return digestData;
}

#pragma mark -


@end
