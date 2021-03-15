/**
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNAES+Private.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "PubNub+CorePrivate.h"
#import "PNErrorCodes.h"
#import "PNConstants.h"
#import "PNLogMacro.h"
#import "PNLLogger.h"
#import "PNHelpers.h"


#pragma mark Static

/**
 * @brief Initialisation vector used to initialise (de)cryptor.
 */
static uint8_t kPNAESInitializationVector[kCCBlockSizeAES128] = "0123456789012345";


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface PNAES ()


#pragma mark - Information

/**
 * @brief Data \c encryption / \c decryption error.
 *
 * @since 4.15.0
 */
@property (nonatomic, nullable, strong) NSError *processingError;

/**
 * @brief Cryptor initialization vector which can be used to encrypt data using AES128 algorithm.
 *
 * @since 4.15.0
 */
@property (nonatomic, strong) NSData *initializationVector;

/**
 * @brief Encryption (\c kCCEncrypt) or decryption (\c kCCDecrypt) operation type.
 *
 * @since 4.15.0
 */
@property (nonatomic, assign) CCOperation operation;

/**
 * @brief Initialized cryptor which should be used for data \c encryption / \c decryption.
 *
 * @since 4.15.0
 */
@property (nonatomic, assign) CCCryptorRef cryptor;

/**
 * @brief Key which should be used during data \c encryption / \c decryption.
 *
 * @since 4.15.0
 */
@property (nonatomic, copy) NSString *cipherKey;


#pragma mark Initialization & Configuration

/**
 * @brief Configure data cryptor.
 *
 * @param cipherKey Key which should be used during data \c encryption / \c decryption.
 * @param operation Encryption (\c kCCEncrypt) or decryption (\c kCCDecrypt) operation type.
 *
 * @return Configured and ready to use cryptor instance.
 *
 * @since 4.15.0 
 */
- (instancetype)initWithCipherKey:(NSString *)cipherKey forOperation:(CCOperation)operation;


#pragma mark - Data processing

/**
 @brief  Translate provided cipher key into SHA256 hex string.
 
 @return HEX string from cipher key.
 */
+ (NSData *)SHA256HexFromKey:(NSString *)cipherKey;

/**
 * @brief Data processing method which basing on configuration able to encrypt or decrypt provided
 * \c data.
 *
 * @param data Reference on initial data which depending from \c operation will be encrypted or
 *   decrypted.
 * @param useRandomIV Whether random initialization vector should be used by \b PNAES.
 * @param cipherKey Reference on key which should be used during encryption/decryption process to
 *   get expected results.
 * @param operation Encryption (\c kCCEncrypt) or decryption (\c kCCDecrypt) operation type.
 * @param status Data processing resulting status (one of \c CCCryptorStatus fields).
 *
 * @return Output from processed \c data using provided \c cipherKey for concrete \c operation.
 *
 * @since 4.15.0
 */
+ (nullable NSData *)processedDataFrom:(NSData *)data
                          withRandomIV:(BOOL)useRandomIV
                             cipherKey:(NSString *)cipherKey
                          forOperation:(CCOperation)operation
                             andStatus:(CCCryptorStatus *)status;


#pragma mark - Processing

/**
 * @brief Perform source file encryption / decryption (basing on provided cryptor).
 *
 * @param sourceURL URL of local file which should be processed with cryptor.
 * @param targetURL Location where processed file should be stored. File will be stored in \c temporary directory if \c nil is  passed (\c temporary file
 *   will be removed after completion block return) and \c location will be returned in completion \c block.
 * @param cryptor Configured cryptor which should be used for file processing.
 * @param block File processing completion block.
 */
+ (void)processFileAtURL:(NSURL *)sourceURL
                   toURL:(nullable NSURL *)targetURL
             withCryptor:(PNAES *)cryptor
              completion:(void(^)(NSURL *location, NSError *error))block;


#pragma mark - Misc

/**
 * @brief Complete cryptor configuration using provided initialization vector.
 *
 * @since 4.15.0
 */
- (void)setupCryptor;

/**
 * @brief Generate random bytes and write to provided \c buffer.
 *
 * @param buffer Memory address to which random bytes should be written.
 *
 * @since 4.15.0
 */
+ (void)getRandomInitializationVector:(void *)buffer;

/**
 @brief Compose error instance depending on error status which has been passed from CCCryptor 
        operation.
 
 @param status Data processing resulting status (one of \c CCCryptorStatus fields).
 
 @return Created and ready to use \a NSError instance.
 
 @since 4.0
 */
+ (NSError *)errorFor:(CCCryptorStatus)status;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNAES


#pragma mark - Informartion

- (NSUInteger)cipherBlockSize {
    return kCCBlockSizeAES128;
}


#pragma mark Initialization & Configuration

+ (instancetype)encryptorWithCipherKey:(NSString *)cipherKey {
    return [[self alloc] initWithCipherKey:cipherKey forOperation:kCCEncrypt];
}

+ (instancetype)decryptorWithCipherKey:(NSString *)cipherKey {
    return [[self alloc] initWithCipherKey:cipherKey forOperation:kCCDecrypt];
}

- (instancetype)initWithCipherKey:(NSString *)cipherKey forOperation:(CCOperation)operation {
    if ((self = [super init])) {
        _cipherKey = [cipherKey copy];
        _operation = operation;
        
        // Random initialization vector possible only for encryption.
        if (operation == kCCEncrypt) {
            const void *vectorBytes[kCCBlockSizeAES128];
            [[self class] getRandomInitializationVector:&vectorBytes];
            
            // Store information about random initialization vector.
            _initializationVector = [NSData dataWithBytes:vectorBytes length:kCCBlockSizeAES128];
            [self setupCryptor];
        }
    }
    
    return self;
}


#pragma mark - Data encryption

+ (NSString *)encrypt:(NSData *)data withKey:(NSString *)key {
    return [self encrypt:data withKey:key andError:NULL];
}

+ (NSString *)encrypt:(NSData *)data
              withKey:(NSString *)key
             andError:(NSError * __autoreleasing *)error {

    return [self encrypt:data withRandomIV:NO cipherKey:key andError:error];
}

+ (NSString *)encrypt:(NSData *)data
         withRandomIV:(BOOL)useRandomIV
            cipherKey:(NSString *)key
             andError:(NSError *__autoreleasing *)error {

    NSError *encryptionError = nil;
    NSData *processedData = nil;
    
    if (data.length && key.length) {
        CCCryptorStatus status;
        processedData = [self processedDataFrom:data
                                   withRandomIV:useRandomIV
                                      cipherKey:key
                                   forOperation:kCCEncrypt
                                      andStatus:&status];
        
        if (status != kCCSuccess) {
            encryptionError = [self errorFor:status];
        }
    } else {
        NSString *description = @"Empty NSData instance has been passed for encryption.";
        NSInteger errorCode = kPNAESEmptyObjectError;
        
        if (!key.length) {
            description = @"Empty encryption key has been passed.";
            errorCode = kPNAESConfigurationError;
        }
        
        encryptionError = [NSError errorWithDomain:kPNAESErrorDomain
                                              code:errorCode
                                          userInfo:@{ NSLocalizedDescriptionKey: description }];
    }
    
    if (encryptionError) {
        if (error != NULL) {
            *error = encryptionError;
        } else {
            PNLLogger *logger = [PNLLogger loggerWithIdentifier:kPNClientIdentifier];
#if DEBUG
            [logger enableLogLevel:PNAESErrorLogLevel];
#endif
            PNLogAESError(logger, @"<PubNub::AES> Encryption error: %@", encryptionError);
        }
    }
    
    return processedData ? [PNData base64StringFrom:processedData] : nil;
}

+ (void)encryptFileAtURL:(NSURL *)fileURL
                   toURL:(NSURL *)encryptedFileURL
           withCipherKey:(NSString *)key
              completion:(void(^)(NSURL *location, NSError *error))block {
    
    PNAES *encryptor = [self encryptorWithCipherKey:key];
    
    [self processFileAtURL:fileURL toURL:encryptedFileURL withCryptor:encryptor completion:block];
}


#pragma mark - Data decryption

+ (NSData *)decrypt:(NSString *)object withKey:(NSString *)key {
    return [self decrypt:object withKey:key andError:NULL];
}

+ (NSData *)decrypt:(NSString *)object withKey:(NSString *)key andError:(NSError **)error {
    return [self decrypt:object withRandomIV:NO cipherKey:key andError:error];
}

+ (NSData *)decrypt:(NSString *)object
       withRandomIV:(BOOL)useRandomIV
          cipherKey:(NSString *)key
           andError:(NSError *__autoreleasing *)error {
    NSError *decryptionError = nil;
    id decryptedObject = nil;
    
    NSCharacterSet *trimCharSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    object = [object stringByTrimmingCharactersInSet:trimCharSet];
    
    if (object.length && key.length) {
        NSData *JSONData = [PNString base64DataFrom:object];
        
        if (JSONData.length) {
            CCCryptorStatus status;
            decryptedObject = [self processedDataFrom:JSONData
                                         withRandomIV:useRandomIV
                                            cipherKey:key
                                         forOperation:kCCDecrypt
                                            andStatus:&status];
            
            if (status != kCCSuccess) {
                decryptionError = [self errorFor:status];
            }
        } else {
            decryptedObject = [PNString UTF8DataFrom:object];
            NSString *description = @"Incompatible string has been passed. Required Base64-encoded "
                                     "string.";
            decryptionError = [NSError errorWithDomain:kPNAESErrorDomain
                                                  code:kPNAESDecryptionError
                                              userInfo:@{ NSLocalizedDescriptionKey: description }];
        }
    } else {
        decryptedObject = [PNString UTF8DataFrom:object];
        NSString *description = @"Empty string has been passed for decryption.";
        NSInteger errorCode = kPNAESEmptyObjectError;
        
        if (key.length) {
            description = @"Empty decryption key has been passed.";
            errorCode = kPNAESConfigurationError;
        }
        
        decryptionError = [NSError errorWithDomain:kPNAESErrorDomain
                                              code:errorCode
                                          userInfo:@{ NSLocalizedDescriptionKey: description }];
    }
    
    if (decryptionError) {
        if (error != NULL) {
            *error = decryptionError;
        } else {
            PNLLogger *logger = [PNLLogger loggerWithIdentifier:kPNClientIdentifier];
#if DEBUG
            [logger enableLogLevel:PNAESErrorLogLevel];
#endif
            PNLogAESError(logger, @"<PubNub::AES> Decryption error: %@", decryptionError);
        }
    }
    
    return decryptedObject;
}

+ (void)decryptFileAtURL:(NSURL *)fileURL
                   toURL:(NSURL *)decryptedFileURL
           withCipherKey:(NSString *)key
              completion:(void (^)(NSURL *location, NSError *error))block {
    
    PNAES *decryptor = [self decryptorWithCipherKey:key];
    
    [self processFileAtURL:fileURL toURL:decryptedFileURL withCryptor:decryptor completion:block];
}


#pragma mark - Data processing

+ (NSData *)SHA256HexFromKey:(NSString *)cipherKey {
    static pthread_mutex_t _cipherKeysLock;
    static NSMutableDictionary *_cipherKeys;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&_cipherKeysLock, nil);
        _cipherKeys = [NSMutableDictionary new];
    });
    
    __block NSData *key = nil;
    pn_lock(&_cipherKeysLock, ^{
        key = _cipherKeys[cipherKey];
        
        if (!key) {
            NSString *SHA256String = [PNData HEXFrom:[PNString SHA256DataFrom:cipherKey]];
            key = [PNString UTF8DataFrom:[SHA256String lowercaseString]];
            _cipherKeys[cipherKey] = key;
        }
    });
    
    return key;
}

+ (nullable NSData *)processedDataFrom:(NSData *)data
                          withRandomIV:(BOOL)useRandomIV
                             cipherKey:(NSString *)cipherKey
                          forOperation:(CCOperation)operation
                             andStatus:(CCCryptorStatus *)status {
    
    NSData *cryptorKeyData = [self SHA256HexFromKey:cipherKey];
    CCCryptorStatus processingStatus = kCCParamError;
    uint8_t *iv = kPNAESInitializationVector;
    NSUInteger dataLength = data.length;
    NSMutableData *processedData = nil;
    NSUInteger dataOffset = 0;
    
    if (useRandomIV && (operation == kCCEncrypt || operation == kCCDecrypt)) {
        uint8_t vectorBytes[kCCBlockSizeAES128];
        
        if (operation == kCCEncrypt) {
            [self getRandomInitializationVector:&vectorBytes];
        } else {
            [data getBytes:&vectorBytes length:kCCBlockSizeAES128];
            dataOffset = kCCBlockSizeAES128;
            dataLength -= dataOffset;
        }
        
        iv = vectorBytes;
    }
    
    // Create new cryptor
    CCCryptorRef cryptor;
    CCCryptorStatus initStatus = CCCryptorCreate(operation,
                                                 kCCAlgorithmAES128,
                                                 kCCOptionPKCS7Padding,
                                                 cryptorKeyData.bytes,
                                                 cryptorKeyData.length,
                                                 iv,
                                                 &cryptor);
    
    if (initStatus == kCCSuccess) {
        size_t processedDataLength = CCCryptorGetOutputLength(cryptor, dataLength, true);
        processedData = [[NSMutableData alloc] initWithLength:processedDataLength];
        size_t updatedProcessedDataLength = 0;
        
        processingStatus = CCCryptorUpdate(cryptor,
                                           data.bytes + dataOffset,
                                           dataLength,
                                           processedData.mutableBytes,
                                           processedData.length,
                                           &updatedProcessedDataLength);
        
        if (processingStatus == kCCSuccess) {
            char *processedDataEndPointer = processedData.mutableBytes + updatedProcessedDataLength;
            size_t unfilledSize = processedData.length - updatedProcessedDataLength;
            size_t remainingUnprocessedDataLength;
            processingStatus = CCCryptorFinal(cryptor,
                                              processedDataEndPointer,
                                              unfilledSize,
                                              &remainingUnprocessedDataLength);
            [processedData setLength:(updatedProcessedDataLength + remainingUnprocessedDataLength)];
        }
        
        if (processingStatus == kCCSuccess) {
            if (operation == kCCDecrypt && dataLength > 0 && processedData.length == 0) {
                processingStatus = kCCDecodeError;
            }

            if (useRandomIV && operation == kCCEncrypt) {
                [processedData replaceBytesInRange:NSMakeRange(0, 0)
                                         withBytes:iv
                                            length:kCCBlockSizeAES128];
            }
        }
    }
    CCCryptorRelease(cryptor);
    
    if (status) {
        *status = processingStatus;
    }
    
    
    return [processedData copy];
}


#pragma mark - Processing

+ (void)processFileAtURL:(NSURL *)sourceURL
                   toURL:(NSURL *)targetURL
             withCryptor:(PNAES *)cryptor
              completion:(void(^)(NSURL *location, NSError *error))block {
    
    sourceURL = targetURL.isFileURL ? sourceURL : [NSURL fileURLWithPath:sourceURL.absoluteString];
    targetURL = targetURL.isFileURL ? targetURL : [NSURL fileURLWithPath:targetURL.absoluteString];
    __block NSError *processingError = cryptor.processingError;
    BOOL isTemporary = NO;
    
    if (![sourceURL checkResourceIsReachableAndReturnError:nil]) {
        NSString *description = @"File doesn't exists or directory.";
        processingError = [NSError errorWithDomain:kPNAESErrorDomain
                                              code:kPNAESEmptyObjectError
                                          userInfo:@{ NSLocalizedDescriptionKey: description }];
    } else if (!processingError && !targetURL) {
        NSSearchPathDirectory searchPath = (TARGET_OS_IPHONE ? NSCachesDirectory : NSLibraryDirectory);
        NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(searchPath, NSUserDomainMask, YES);
        NSURL *temporaryDirectoryURL = [NSURL URLWithString:(paths.firstObject ?: NSTemporaryDirectory())];;
        targetURL = [temporaryDirectoryURL URLByAppendingPathComponent:sourceURL.lastPathComponent];
        isTemporary = YES;
    }
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!processingError) {
            processingError = [cryptor processFileAtURL:sourceURL toURL:targetURL];
        }
            
        if (processingError) {
            PNLLogger *logger = [PNLLogger loggerWithIdentifier:kPNClientIdentifier];
    #if DEBUG
            [logger enableLogLevel:PNAESErrorLogLevel];
    #endif
            PNLogAESError(logger, @"<PubNub::AES> %@ error: %@",
                          cryptor.operation == kCCEncrypt ? @"Encryption" : @"Decryption", processingError);
        }
        
        block(!processingError ? targetURL : nil, processingError);
        
        if (isTemporary || processingError) {
            if (![NSFileManager.defaultManager removeItemAtURL:targetURL error:&processingError]) {
                NSLog(@"<PubNub::AES> %@ clean up error: %@",
                      cryptor.operation == kCCEncrypt ? @"Encryption" : @"Decryption",
                      processingError);
            }
        }
    });
}

- (NSError *)processFileAtURL:(NSURL *)sourceURL toURL:(NSURL *)targetURL {
    NSOutputStream *outputStream = [NSOutputStream outputStreamWithURL:targetURL append:NO];
    NSInputStream *inputStream = [NSInputStream inputStreamWithURL:sourceURL];
    NSUInteger bufferSize = 1024 * 1024;
    NSUInteger currentBufferSize = bufferSize;
    
    NSMutableData *writeBuffer = [NSMutableData dataWithLength:bufferSize];
    NSMutableData *readBuffer = [NSMutableData dataWithLength:bufferSize];
    [outputStream open];
    [inputStream open];

    self.processingError = inputStream.streamError ?: outputStream.streamError;
    
    if (self.operation == kCCEncrypt) {
        currentBufferSize -= kCCBlockSizeAES128;
    }
    
    while (inputStream.streamStatus == NSStreamStatusOpen && !self.processingError) {
        NSInteger bytesRead = [inputStream read:readBuffer.mutableBytes maxLength:currentBufferSize];
        NSInteger bytesToWrite = 0;
        
        if (bytesRead > 0) {
            bytesToWrite = [self updateProcessedData:writeBuffer
                                        usingRawData:readBuffer.mutableBytes
                                          withLength:bytesRead];
            
            if (self.operation == kCCEncrypt && currentBufferSize < bufferSize) {
                NSData *processedData = [writeBuffer subdataWithRange:NSMakeRange(0, bytesToWrite)];
                writeBuffer = [NSMutableData dataWithData:self.initializationVector];
                bytesToWrite += self.initializationVector.length;
                [writeBuffer appendData:processedData];
            }
        } else if (bytesRead == 0) {
            bytesToWrite = [self finalizeProcessedData:writeBuffer withLength:currentBufferSize];
            [inputStream close];
        } else {
            self.processingError = inputStream.streamError;
            [inputStream close];
        }
        
        while (outputStream.streamStatus == NSStreamStatusOpen && bytesToWrite > 0) {
            NSInteger bytesWritten = [outputStream write:writeBuffer.mutableBytes maxLength:bytesToWrite];
            
            if (bytesRead > 0) {
                bytesToWrite -= bytesWritten;
            } else if (bytesWritten == 0) {
                NSInteger errorCode = self.operation == kCCEncrypt ? kPNAESEncryptionError : kPNAESDecryptionError;
                NSString *description = @"Processed data write did fail.";
                
                self.processingError = [NSError errorWithDomain:kPNAESErrorDomain
                                                           code:errorCode
                                                       userInfo:@{ NSLocalizedDescriptionKey: description }];
                
                [outputStream close];
            } else {
                self.processingError = outputStream.streamError;
                [outputStream close];
            }
        }
        
        NSRange bytesResetRange = NSMakeRange(0, currentBufferSize);
        [writeBuffer resetBytesInRange:bytesResetRange];
        [readBuffer resetBytesInRange:bytesResetRange];
        currentBufferSize = bufferSize;
    }
    
    return self.processingError;
}

- (NSInteger)updateProcessedData:(NSMutableData *)processedData
                    usingRawData:(uint8_t *)rawData
                      withLength:(NSUInteger)length {
    
    CCCryptorStatus status = kCCParamError;
    size_t processedDataLength = 0;
    NSUInteger offset = 0;
    
    if (self.cryptor == NULL && self.operation == kCCDecrypt) {
        self.initializationVector = [NSData dataWithBytes:rawData length:kCCBlockSizeAES128];
        [self setupCryptor];
        
        if (self.processingError) {
            return -1;
        }
        
        offset = self.initializationVector.length;
        length -= offset;
    }
    
    status = CCCryptorUpdate(self.cryptor,
                             rawData + offset,
                             length,
                             processedData.mutableBytes,
                             processedData.length,
                             &processedDataLength);
    
    if (status == kCCSuccess && self.operation == kCCDecrypt) {
        if (length > 0 && processedData.length == 0) {
            status = kCCDecodeError;
        }
    }
    
    if (status != kCCSuccess) {
        self.processingError = [[self class] errorFor:status];
        processedDataLength = -1;
    }
    
    return processedDataLength;
}

- (NSInteger)finalizeProcessedData:(NSMutableData *)processedData
                        withLength:(NSUInteger)length {
    
    CCCryptorStatus status = kCCParamError;
    size_t processedDataLength;
    status = CCCryptorFinal(self.cryptor, processedData.mutableBytes, length, &processedDataLength);
    
    if (status != kCCSuccess) {
        self.processingError = [[self class] errorFor:status];
        processedDataLength = 0;
    }
    
    return processedDataLength;
}


#pragma mark - Misc

- (void)setupCryptor {
    CCCryptorStatus status = kCCKeySizeError;

    if (_cipherKey.length) {
        NSData *cryptorKeyData = [[self class] SHA256HexFromKey:_cipherKey];
        status = CCCryptorCreate(self.operation,
                                 kCCAlgorithmAES128,
                                 kCCOptionPKCS7Padding,
                                 cryptorKeyData.bytes,
                                 cryptorKeyData.length,
                                 self.initializationVector.bytes,
                                 &_cryptor);
    }
    
    if (status != kCCSuccess) {
        self.processingError = [[self class] errorFor:status];
        
        if (_cryptor != NULL) {
            CCCryptorRelease(_cryptor);
            _cryptor = NULL;
        }
    }
}

+ (void)getRandomInitializationVector:(void *)buffer {
    if (SecRandomCopyBytes(kSecRandomDefault, kCCBlockSizeAES128, buffer) != kCCSuccess) {
        NSString *randomString = [[NSUUID UUID].UUIDString substringToIndex:kCCBlockSizeAES128];
        NSData *randomBytes = [randomString dataUsingEncoding:NSUTF8StringEncoding];
        [randomBytes getBytes:buffer length:kCCBlockSizeAES128];
    }
}

- (NSUInteger)targetBufferSize:(NSInteger)size {
    if (self.processingError || size == 0) {
        return 0;
    }
    
    return CCCryptorGetOutputLength(self.cryptor, size, false);
}

- (NSUInteger)finalTargetBufferSize:(NSInteger)size {
    if (self.processingError || size == 0) {
        return 0;
    }
    
    return CCCryptorGetOutputLength(self.cryptor, size, true);
}

+ (NSError *)errorFor:(CCCryptorStatus)status {
    NSString *description = @"Unknown error";
    NSInteger errorCode = kPNUnknownErrorCode;
    
    switch (status) {
        case kCCParamError:
        case kCCAlignmentError:
            description = @"Illegal parameter value has been used with AES configuration.";
            errorCode = kPNAESConfigurationError;
            break;
        case kCCBufferTooSmall:
        case kCCMemoryFailure:
            description = @"Unable to allocate required amount of memory to process data.";
            errorCode = kPNAESInsufficientMemoryError;
            break;
        case kCCKeySizeError:
        case kCCInvalidKey:
            description = @"Unacceptable cipher key has been provided.";
            errorCode = kPNAESConfigurationError;
            break;
        case kCCDecodeError:
        case kCCOverflow:
        case kCCRNGFailure:
            description = @"Provided data can't be processed (data can be not encryped).";
            errorCode = kPNAESDecryptionError;
            break;
        default:
            break;
    }
    
    
    return [NSError errorWithDomain:kPNAESErrorDomain
                               code:errorCode
                           userInfo:@{ NSLocalizedDescriptionKey: description }];
}

- (void)dealloc {
    if (_cryptor != NULL) {
        CCCryptorRelease(_cryptor);
        _cryptor = NULL;
    }
}

#pragma mark -


@end
