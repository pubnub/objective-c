#import "PNCCCryptorWrapper.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "PNErrorCodes.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// Wrapper around common cryptor private extension.
@interface PNCCCryptorWrapper ()


#pragma mark - Information

/// Wrapper data processing error
@property (nonatomic, nullable, strong) NSError *error;

/// Type of operation for which wrapper configured cryptor (_encryption_ or _decryption_).
@property (nonatomic, assign) CCOperation operation;

/// `CCCryptor` which should be used for data processing.
@property (nonatomic, assign) CCCryptorRef cryptor;


#pragma mark - Initialization and configuration

/// Finalyze AES-256 cryptor in CBC mode initialization.
///
/// - Parameters:
///   - cipherKey: Key which should be used to process data.
///   - initializationVector: Block cipher initialization vector.
///   - operation: Operation for which cryptor should be configured: `kCCEncrypt` or `kCCDecrypt`.
/// - Returns: Result of cryptor initialization completion process.
- (PNResult<PNCCCryptorWrapper *> *)AESCBCWithCipherKey:(NSData *)cipherKey
                                   initializationVector:(NSData *)initializationVector
                                           forOperation:(CCOperation)operation;


#pragma mark - Helpers

/// Create `NSError` from `CCCryptor` processing status.
///
/// - Parameters:
///   - status: Data processing resulting status (one of `CCCryptorStatus` fields).
///   - operation: Operation during which error occurred.
/// - Returns: `NSError` instance with `CCCryptor` error status information.
+ (NSError *)errorFromCryptorStatus:(CCCryptorStatus)status andOperation:(CCOperation)operation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNCCCryptorWrapper


#pragma mark - Initialization and configuration

+ (PNResult<PNCCCryptorWrapper *> *)AESCBCEncryptorWithCipherKey:(NSData *)cipherKey
                                            initializationVector:(NSData *)initializationVector {
    return [[self new] AESCBCWithCipherKey:cipherKey
                      initializationVector:initializationVector
                              forOperation:kCCEncrypt];
}

+ (PNResult<PNCCCryptorWrapper *> *)AESCBCDecryptorWithCipherKey:(NSData *)cipherKey
                                            initializationVector:(NSData *)initializationVector {
    return [[self new] AESCBCWithCipherKey:cipherKey
                      initializationVector:initializationVector
                              forOperation:kCCDecrypt];
}

- (PNResult<PNCCCryptorWrapper *> *)AESCBCWithCipherKey:(NSData *)cipherKey
                                   initializationVector:(NSData *)initializationVector
                                           forOperation:(CCOperation)operation {
    CCCryptorStatus status = kCCKeySizeError;
    PNCCCryptorWrapper *wrapper = self;
    NSError *error = nil;
    
    if (cipherKey.length) {
        status = CCCryptorCreate(operation,
                                 kCCAlgorithmAES128,
                                 kCCOptionPKCS7Padding,
                                 cipherKey.bytes,
                                 cipherKey.length,
                                 initializationVector.bytes,
                                 &_cryptor);
    }
    
    if (status != kCCSuccess) {
        error = [[self class] errorFromCryptorStatus:status andOperation:self.operation];
        
        if (_cryptor != NULL) {
            CCCryptorRelease(_cryptor);
            _cryptor = NULL;
        }
    }
    
    return [PNResult resultWithData:wrapper error:error];
}


#pragma mark - Data processing

- (PNResult<NSData *> *)processedDataFrom:(NSData *)sourceData {
    NSUInteger sourceDataLength = sourceData.length;
    size_t estimatedResultLength = CCCryptorGetOutputLength(self.cryptor, sourceDataLength, true);
    NSMutableData *processedData = [NSMutableData dataWithLength:estimatedResultLength];
    size_t processedDataLength = 0;
    NSError *error = nil;
    
    CCCryptorStatus status = CCCryptorUpdate(self.cryptor,
                                             sourceData.bytes,
                                             sourceDataLength,
                                             processedData.mutableBytes,
                                             estimatedResultLength,
                                             &processedDataLength);
    
    if (status == kCCSuccess) {
        size_t finalisedDataLength = 0;
        status = CCCryptorFinal(self.cryptor,
                                processedData.mutableBytes + processedDataLength,
                                estimatedResultLength - processedDataLength,
                                &finalisedDataLength);
        processedData.length = processedDataLength + finalisedDataLength;
    } else {
        error = [[self class] errorFromCryptorStatus:status andOperation:self.operation];
    }
    
    return [PNResult resultWithData:processedData error:error];
}

- (PNResult<NSData *> *)processDataFromDataChunk:(uint8_t *)dataChunk
                                      withLength:(NSUInteger)length
                                    andFinalised:(BOOL)finalised {
    if (self.error) return [PNResult resultWithData:nil error:self.error];
    NSUInteger bufferSize = CCCryptorGetOutputLength(self.cryptor, length, finalised);
    NSMutableData *processedData = [NSMutableData dataWithLength:bufferSize];
    CCCryptorStatus status = kCCParamError;
    size_t processedLength = 0;

    if (length == 0) status = kCCSuccess;
    else {
        status = CCCryptorUpdate(self.cryptor,
                                 dataChunk,
                                 length,
                                 processedData.mutableBytes,
                                 bufferSize,
                                 &processedLength);
    }

    if (status == kCCSuccess && finalised) {
        size_t finalLength = 0;
        status = CCCryptorFinal(self.cryptor,
                                processedData.mutableBytes + processedLength,
                                bufferSize - processedLength,
                                &finalLength);
        processedLength += finalLength;
    }

    if (status != kCCSuccess) {
        self.error = [[self class] errorFromCryptorStatus:status andOperation:self.operation];
    }
    processedData.length = processedLength;

    return [PNResult resultWithData:processedData error:self.error];
}


#pragma mark - Helpers

- (NSUInteger)processedDataLength:(NSUInteger)length {
    return CCCryptorGetOutputLength(self.cryptor, length, true);
}

+ (NSError *)errorFromCryptorStatus:(CCCryptorStatus)status andOperation:(CCOperation)operation {
    NSInteger errorCode = kPNUnknownErrorCode;
    NSString *description = @"Unknown error";
    
    switch (status) {
        case kCCParamError:
        case kCCAlignmentError:
            description = @"Illegal parameter value has been used with AES configuration.";
            errorCode = kPNCryptorConfigurationError;
            break;
        case kCCBufferTooSmall:
        case kCCMemoryFailure:
            description = @"Unable to allocate required amount of memory to process data.";
            errorCode = kPNCryptorInsufficientMemoryError;
            break;
        case kCCKeySizeError:
        case kCCInvalidKey:
            description = @"Unacceptable cipher key has been provided.";
            errorCode = kPNCryptorConfigurationError;
            break;
        case kCCDecodeError:
        case kCCOverflow:
        case kCCRNGFailure:
            description = @"Provided data can't be processed.";
            errorCode = operation == kCCEncrypt ? kPNCryptorEncryptionError : kPNCryptorDecryptionError;
            break;
        default:
            break;
    }
    
    return [NSError errorWithDomain:kPNCryptorErrorDomain
                               code:errorCode
                           userInfo:@{ NSLocalizedDescriptionKey: description }];
}


#pragma mark - Misc

- (void)dealloc {
    if (_cryptor) CCCryptorRelease(_cryptor);
    _cryptor = NULL;
}

#pragma mark -


@end
