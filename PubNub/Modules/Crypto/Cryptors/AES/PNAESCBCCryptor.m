#import "PNAESCBCCryptor+Private.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "PNCryptorInputStream+Private.h"
#import "PNCCCryptorWrapper.h"
#import "PNEncryptedStream.h"
#import "PNError.h"


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

/// Key for data _encryption_ and _decryption_.
@property(nonatomic, strong) NSString *cipherKeyString;

/// Whether random initialization vector should be used for data _encryption_ or not.
@property(nonatomic, readonly) BOOL useRandomIV;

/// Prepared key for data _encryption_ and _decryption_.
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


#pragma mark - Helpers

/// Initialization vector which should be used for data _encryption_.
///
/// Streams / files processing is done **only** with random initialization vector.
///
/// - Parameter forStreamProcessing - Whether initialization vector required for stream _encryption_ or not.
/// - Returns: Suitable initialization vector.
- (NSData *)initializationVector:(BOOL)forStreamProcessing;

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
    return [self initializationVector:self.useRandomIV];
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
        _cipherKeyString = [cipherKey copy];
    }
    
    return self;
}


#pragma mark - Data processing

- (PNResult<PNEncryptedData *> *)encryptData:(NSData *)data {
    if (data.length == 0) {
        NSError *error = [NSError errorWithDomain:PNCryptorErrorDomain
                                             code:PNCryptorErrorEncryption
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Unable to encrypt empty data." }];
        return [PNResult resultWithData:nil error:error];
    }

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
            NSError *error = [NSError errorWithDomain:PNCryptorErrorDomain
                                                 code:PNCryptorErrorDecryption
                                             userInfo:@{
                NSLocalizedDescriptionKey: @"Insufficient amount of data to read cryptor-defined metadata."
            }];

            return [PNResult resultWithData:nil error:error];
        }
    }

    if (encryptedData.length == 0) {
        NSError *error = [NSError errorWithDomain:PNCryptorErrorDomain
                                             code:PNCryptorErrorDecryption
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Unable to decrypt empty data." }];
        return [PNResult resultWithData:nil error:error];
    }

    PNResult<PNCCCryptorWrapper *> *wrapper = [PNCCCryptorWrapper AESCBCDecryptorWithCipherKey:self.cipherKey
                                                                          initializationVector:initializationVector];
    if (wrapper.isError) return (PNResult<NSData *> *)wrapper;

    return [wrapper.data processedDataFrom:encryptedData];
}


#pragma mark - Stream processing

- (PNResult<PNEncryptedStream *> *)encryptStream:(NSInputStream *)stream dataLength:(NSUInteger)length {
    if (length == 0) {
        NSError *error = [NSError errorWithDomain:PNCryptorErrorDomain
                                             code:PNCryptorErrorEncryption
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Unable to encrypt empty stream." }];
        return [PNResult resultWithData:nil error:error];
    }

    NSData *initializationVector = [self initializationVector:YES];
    PNResult<PNCCCryptorWrapper *> *wrapper = [PNCCCryptorWrapper AESCBCEncryptorWithCipherKey:self.cipherKey
                                                                          initializationVector:initializationVector];
    if (wrapper.isError) return (PNResult<PNEncryptedStream *> *)wrapper;

    PNCryptorInputStream *cryptorStream = nil;
    cryptorStream = [PNCryptorInputStream inputStreamWithInputStream:stream
                                                          dataLength:length
                                                         chunkLength:kCCBlockSizeAES128
                                                     processingBlock:[self processingBlockForWrapper:wrapper.data]];

    NSData *metadata = initializationVector;
    NSUInteger encryptedDataLength = [wrapper.data processedDataLength:length];
    PNEncryptedStream *encryptedStream = [PNEncryptedStream encryptedStreamWithStream:cryptorStream
                                                                           dataLength:encryptedDataLength
                                                                             metadata:metadata];

    return [PNResult resultWithData:encryptedStream error:nil];
}

- (PNResult<NSInputStream *> *)decryptStream:(PNEncryptedStream *)stream dataLength:(NSUInteger)length {
    NSData *initializationVector = stream.metadata;

    if (initializationVector.length == 0 && !self.useRandomIV) initializationVector = self.initializationVector;
    else if (initializationVector.length == 0 && length > kCCBlockSizeAES128) {
        initializationVector = [stream.stream readCryptorMetadataWithLength:kCCBlockSizeAES128].data;
    } else if (length < kCCBlockSizeAES128) {
        NSError *error = [NSError errorWithDomain:PNCryptorErrorDomain
                                             code:PNCryptorErrorDecryption
                                         userInfo:@{
            NSLocalizedDescriptionKey: @"Insufficient amount of data to read cryptor-defined metadata."
        }];

        return [PNResult resultWithData:nil error:error];
    }

    PNResult<PNCCCryptorWrapper *> *wrapper = [PNCCCryptorWrapper AESCBCDecryptorWithCipherKey:self.cipherKey
                                                                          initializationVector:initializationVector];
    if (wrapper.isError) return (PNResult<NSInputStream *> *)wrapper;

    if (stream.stream.inputDataLength == 0) {
        NSError *error = [NSError errorWithDomain:PNCryptorErrorDomain
                                             code:PNCryptorErrorDecryption
                                         userInfo:@{ NSLocalizedDescriptionKey: @"Unable to decrypt empty stream." }];
        return [PNResult resultWithData:nil error:error];
    }

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

- (NSData *)initializationVector:(BOOL)forStreamProcessing {
    if (!forStreamProcessing && !self.useRandomIV) return _initializationVector;
    else {
        uint8_t vectorBytes[kCCBlockSizeAES128];

        if (SecRandomCopyBytes(kSecRandomDefault, kCCBlockSizeAES128, vectorBytes) != kCCSuccess) {
            NSData *randomBytes = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
            [randomBytes getBytes:vectorBytes length:kCCBlockSizeAES128];
        }

        return [NSData dataWithBytes:vectorBytes length:kCCBlockSizeAES128];
    }
}

- (NSData *)digestForKey:(NSString *)key {
    NSMutableData *digestData = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    NSData *data = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    CC_SHA256(data.bytes, (CC_LONG)data.length, digestData.mutableBytes);
    
    return digestData;
}


#pragma mark - Misc

- (NSDictionary *)dictionaryRepresentation {
    NSString *cipherKey = self.cipherKeyString;
    if (cipherKey) {
        if (cipherKey.length <= 5) cipherKey = @"*****";
        else {
            NSUInteger maskLength = cipherKey.length - 2;
            NSMutableString *maskedCipherKey = [[cipherKey substringToIndex:1] mutableCopy];
            for (NSUInteger i = 0; i < maskLength; i++) [maskedCipherKey appendString:@"*"];
            [maskedCipherKey appendString:[cipherKey substringFromIndex:cipherKey.length - 1]];
            cipherKey = maskedCipherKey;
        }
    } else cipherKey = @"missing";
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
        @"class": NSStringFromClass(self.class),
        @"userRandomIV": @(self.useRandomIV),
        @"cipherKey": cipherKey
    }];
    
    
    
    return dictionary;
}

#pragma mark -


@end
