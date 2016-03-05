/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNAES.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "PubNub+CorePrivate.h"
#import <libkern/OSAtomic.h>
#import "PNErrorCodes.h"
#import "PNLogMacro.h"
#import "PNHelpers.h"


#pragma mark CocoaLumberjack logging support

/**
 @brief  Cocoa Lumberjack logging level configuration for cryptor helper.
 
 @since 4.0
 */
static DDLogLevel ddLogLevel = (NSUInteger)PNAESErrorLogLevel;


#pragma mark - Static

/**
 @brief  Initializing vector used to initialize (de)cryptor.
 
 @since 4.0
 */
static const void * kPNAESInitializationVector = "0123456789012345";


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface PNAES ()


#pragma mark - Data processing

/**
 @brief  Translate provided cipher key into SHA256 hex string.
 
 @return HEX string from cipher key.
 */
+ (NSData *)SHA256HexFromKey:(NSString *)cipherKey;

/**
 @brief Data processing method which basing on configuration able to encrypt or decrypt provided \c data.
 
 @param data      Reference on initial data which depending from \c operation will be encrypted or decrypted.
 @param cipherKey Reference on key which should be used during encryption/decryption process to get expected 
                  results.
 @param operation Encryption (\c kCCEncrypt) or decryption (\c kCCDecrypt) operation type.
 @param status    Data processing resulting status (one of \c CCCryptorStatus fields).
 
 @return Output from processed \c data using provided \c cipherKey for concrete \c operation.
 
 @since 4.0
 */
+ (nullable NSData *)processedDataFrom:(NSData *)data withKey:(NSString *)cipherKey
                          forOperation:(CCOperation)operation andStatus:(CCCryptorStatus *)status;


#pragma mark - Misc

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


#pragma mark - Logger

/**
 @brief  Called by Cocoa Lumberjack during initialization.
 
 @return Desired logger level for \b PubNub client main class.
 
 @since 4.0
 */
+ (DDLogLevel)ddLogLevel {
    
    return ddLogLevel;
}

/**
 @brief  Allow modify logger level used by Cocoa Lumberjack with logging macros.
 
 @param logLevel New log level which should be used by logger.
 
 @since 4.0
 */
+ (void)ddSetLogLevel:(DDLogLevel)logLevel {
    
    ddLogLevel = logLevel;
}


#pragma mark - Data encryption

+ (nullable NSString *)encrypt:(NSData *)data withKey:(NSString *)key {
    
    return [self encrypt:data withKey:key andError:NULL];
}

+ (nullable NSString *)encrypt:(NSData *)data withKey:(NSString *)key
                      andError:(NSError *__autoreleasing *)error {
    
    NSData *processedData = nil;
    NSError *encryptionError = nil;
    if ([data length] && [key length]) {
        
        // Encrypt passed data
        CCCryptorStatus status;
        processedData = [self processedDataFrom:data withKey:key forOperation:kCCEncrypt
                                      andStatus:&status];
        if (status != kCCSuccess) { encryptionError = [self errorFor:status]; }
    }
    // AES can't complete w/o actual data or encryption key. Construct processing error instance
    // which will be passed to the user.
    else {
        
        NSString *description = @"Empty NSData instance has been passed for encryption.";
        NSInteger errorCode = kPNAESEmptyObjectError;
        if ([key length]) {
            
            description = @"Empty encryption key has been passed.";
            errorCode = kPNAESConfigurationError;
        }
        
        encryptionError = [NSError errorWithDomain:kPNAESErrorDomain code:errorCode
                                          userInfo:@{NSLocalizedDescriptionKey:description}];
    }
    
    if (encryptionError) {
        
        if (error != NULL) { *error = encryptionError; }
        else { DDLogAESError([self ddLogLevel], @"<PubNub::AES> Encryption error: %@", encryptionError); }
    }
    
    return [PNData base64StringFrom:processedData];
}


#pragma mark - Data decryption

+ (nullable NSData *)decrypt:(NSString *)object withKey:(NSString *)key {
    
    return [self decrypt:object withKey:key andError:NULL];
}

+ (nullable NSData *)decrypt:(NSString *)object withKey:(NSString *)key
                    andError:(NSError *__autoreleasing *)error {
    
    NSError *decryptionError = nil;
    id decryptedObject = nil;
    
    // Clean up source string from enclosing "
    NSCharacterSet *trimCharSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    object = [object stringByTrimmingCharactersInSet:trimCharSet];
    if ([object length] && [key length]) {
        
        // Extract NSData which was encoded into Base64 string.
        NSData *JSONData = [PNString base64DataFrom:object];
        
        if ([JSONData length]) {
            
            // Decrypt data from Base64-encoded string.
            CCCryptorStatus status;
            decryptedObject = [self processedDataFrom:JSONData withKey:key forOperation:kCCDecrypt
                                            andStatus:&status];
            
            if (status != kCCSuccess) {
                
                decryptionError = [self errorFor:status];
            }
        }
        // Looks like non-Base64 encoded string has been provided. Construct processing error
        // instance which will be passed to the user.
        else {
            
            decryptedObject = [PNString UTF8DataFrom:object];
            NSString *description = @"Incompatible string has been passed. Required Base64-encoded "
                                     "string.";
            decryptionError = [NSError errorWithDomain:kPNAESErrorDomain code:kPNAESDecryptionError
                                              userInfo:@{NSLocalizedDescriptionKey:description}];
        }
    }
    // AES can't complete w/o actual data or decryption key. Construct processing error instance
    // which will be passed to the user.
    else {
        
        decryptedObject = [PNString UTF8DataFrom:object];
        NSString *description = @"Empty string has been passed for decryption.";
        NSInteger errorCode = kPNAESEmptyObjectError;
        if ([key length]) {
            
            description = @"Empty decryption key has been passed.";
            errorCode = kPNAESConfigurationError;
        }
        
        decryptionError = [NSError errorWithDomain:kPNAESErrorDomain code:errorCode
                                          userInfo:@{NSLocalizedDescriptionKey:description}];
    }
    
    if (decryptionError) {
        
        if (error != NULL) { *error = decryptionError; }
        else { DDLogAESError([self ddLogLevel], @"<PubNub::AES> Decryption error: %@", decryptionError); }
    }
    
    return decryptedObject;
}


#pragma mark - Data processing

+ (NSData *)SHA256HexFromKey:(NSString *)cipherKey {
    
    static OSSpinLock _cipherKeysSpinLock;
    static NSMutableDictionary *_cipherKeys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _cipherKeysSpinLock = OS_SPINLOCK_INIT;
        _cipherKeys = [NSMutableDictionary new];
    });
    
    OSSpinLockLock(&_cipherKeysSpinLock);
    NSData *key = _cipherKeys[cipherKey];
    if (!key) {
        
        NSString *SHA256String = [PNData HEXFrom:[PNString SHA256DataFrom:cipherKey]];
        key = [PNString UTF8DataFrom:[SHA256String lowercaseString]];
        _cipherKeys[cipherKey] = key;
    }
    OSSpinLockUnlock(&_cipherKeysSpinLock);
    
    return key;
}

+ (nullable  NSData *)processedDataFrom:(NSData *)data withKey:(NSString *)cipherKey
                           forOperation:(CCOperation)operation andStatus:(CCCryptorStatus *)status {
    
    NSData *cryptorKeyData = [self SHA256HexFromKey:cipherKey];
    NSMutableData *processedData = nil;
    CCCryptorStatus processingStatus = kCCParamError;
    
    // Create new cryptor
    CCCryptorRef cryptor;
    CCCryptorStatus initStatus = CCCryptorCreate(operation, kCCAlgorithmAES128,
                                                 kCCOptionPKCS7Padding, [cryptorKeyData bytes],
                                                 [cryptorKeyData length],kPNAESInitializationVector,
                                                 &cryptor);
    
    // Check whether cryptor was successfully created or not
    if (initStatus == kCCSuccess) {
        
        // Prepare storage for processed data
        size_t processedDataLength = CCCryptorGetOutputLength(cryptor, [data length], true);
        processedData = [[NSMutableData alloc] initWithLength:processedDataLength];
        
        // Perform processing and response data size adjustment calculation
        size_t updatedProcessedDataLength;
        processingStatus = CCCryptorUpdate(cryptor, [data bytes], [data length],
                                           [processedData mutableBytes], [processedData length],
                                           &updatedProcessedDataLength);
        
        if (processingStatus == kCCSuccess) {
            
            // Complete data processing
            char *processedDataEndPointer = [processedData mutableBytes]+updatedProcessedDataLength;
            size_t unfilledSize = [processedData length] - updatedProcessedDataLength;
            size_t remainingUnprocessedDataLength;
            processingStatus = CCCryptorFinal(cryptor, processedDataEndPointer, unfilledSize,
                                              &remainingUnprocessedDataLength);
            [processedData setLength:(updatedProcessedDataLength+remainingUnprocessedDataLength)];
        }
        
        // Check whether processing completed or not
        if (processingStatus == kCCSuccess) {
            
            if (operation == kCCDecrypt) {
                
                // Check whether length of processed data is zero when input data has positive value
                // (maybe AES decryptor parsed as empty string but it should be treated as error)
                if ([data length] > 0 && [processedData length] == 0) {
                    
                    processingStatus = kCCDecodeError;
                }
            }
        }
    }
    CCCryptorRelease(cryptor);
    
    if (status) {
        
        *status = processingStatus;
    }
    
    
    return [processedData copy];
}


#pragma mark - Misc

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
        case kCCDecodeError:
        case kCCOverflow:
        case kCCRNGFailure:
            
            description = @"Provided data can't be processed (data can be not encryped).";
            errorCode = kPNAESDecryptionError;
            break;
            
        default:
            break;
    }
    
    
    return [NSError errorWithDomain:kPNAESErrorDomain code:errorCode
                           userInfo:@{NSLocalizedDescriptionKey:description}];
}

#pragma mark -


@end
