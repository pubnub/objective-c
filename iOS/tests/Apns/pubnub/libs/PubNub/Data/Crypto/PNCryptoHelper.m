//
//  PNCryptoHelper.m
//  pubnub
//  Helper which allow to encode user messages and responsible
//  for CCCryptor instance maintenance.
//
//
//  Created by Sergey Mamontov on 3/15/13.
//
//

#import "PNCryptoHelper.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+PNAddition.h"
#import "NSData+PNAdditions.h"
#import "PNPrivateImports.h"
#import "PNLoggerSymbols.h"


// ARC check
#if !__has_feature(objc_arc)
#error PubNub crypto helper must be built with ARC.
// You can turn on ARC for only PubNub files by adding '-fobjc-arc' to the build phase for each of its files.
#endif


#pragma mark Types

// Represents available cryptor types
typedef enum _PNCryptorType {
    PNCryptorEncrypt = kCCEncrypt,
    PNCryptorDecrypt = kCCDecrypt
} PNCryptorType;


#pragma mark - Private interface implementation

@interface PNCryptoHelper ()


#pragma mark - Properties

@property (nonatomic, assign) BOOL ready;

/**
 Stores reference on prepared cipher key.
 */
@property (nonatomic, strong) NSData *cryptorKeyData;
@property (nonatomic, strong) NSData *backedUpCryptorKeyData;

/**
 Stores reference on cryptor initialization vector.
 */
@property (nonatomic, strong) NSData *cryptorInitializationVectorData;


#pragma mark - Instance methods

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
/**
 Returns reference on array with encrypted values from original array in it. In case of encryption error message will 
 be generated.
 */
- (NSArray *)arrayOfEnryptedValues:(NSArray *)arrayForEncryption error:(PNError *__strong *)error;

/**
 Returns reference on dictionary with encrypted values from original dictionary in it. In case of encryption error 
 message will be generated.
 */
- (NSDictionary *)dictionaryOfEnryptedValues:(NSDictionary *)dictionaryForEncryption error:(PNError *__strong *)error;
/**
 Returns reference array with decrypted values from original array in it. In case of encryption error message will 
 be generated.
 */
- (NSArray *)arrayOfDecryptedValues:(NSArray *)arrayForDecryption error:(PNError *__strong *)error;

/**
 Returns reference dictionary with decrypted values from original dictionary in it.  In case of encryption error 
 message will be generated.
 */
- (NSDictionary *)dictionaryOfDecryptedValues:(NSDictionary *)dictionaryForDecryption error:(PNError *__strong *)error;
#endif

/**
 * Process data with specified cryptor and input data
 */
- (CCCryptorStatus)getProcessedData:(NSData **)outputData fromInputData:(NSData *)inputData
                    withCryptorType:(PNCryptorType)cryptorType;

/**
 * Process specified string and return processing result
 */
- (NSString *)processString:(NSString *)string cryptorType:(PNCryptorType)cryptorType error:(PNError *__strong *)error;


#pragma mark - Misc methods

/**
 Update/backup/restore cached data which is based on client's provided cipher key.
 
 @param cipherKey
 User provided cipher key which should be used for crypto helper configuration.
 */
- (void)updateCipherDataWithCipherKey:(NSString *)cipherKey;
- (void)backupCipherConfiguration;
- (void)restoreCipheConfiguration;

/**
 * Construct and return reference on prepared cryptor
 * which will be used for data encode/decode depending
 * on specified options
 */
- (CCCryptorStatus)getCryptor:(CCCryptorRef *)cryptor forOperation:(CCOperation)operation;

/**
 * Reset specified cryptor to initial state
 */
- (CCCryptorStatus)resetCryptor:(CCCryptorRef)cryptor;

/**
 * Retrieve error code from cryptor status
 */
- (NSInteger)errorCodeFromStatus:(CCCryptorStatus)status;

@end


#pragma mark - Public interface implementation

@implementation PNCryptoHelper


#pragma mark - Class methods

+ (PNCryptoHelper *)helperWithConfiguration:(PNConfiguration *)configuration error:(PNError **)error {
    
    PNCryptoHelper *helper = [self new];
    [helper updateWithConfiguration:configuration withError:error];
    if (*error != nil) {
        
        helper = nil;
    }
    
    
    return helper;
}


#pragma mark - Instance methods

- (BOOL)updateWithConfiguration:(PNConfiguration *)configuration withError:(PNError **)error {

    // Temporary encrypt/decrypt objects to validate provided configuration
    CCCryptorRef encoder;
    CCCryptorRef decoder;

    PNError *cryptorInitError = nil;
    CCCryptorStatus initStatus = kCCSuccess;
    BOOL isEncryptorCreated = NO;
    
    // Check whether developer specified cipher key in configuration or not
    if ([configuration.cipherKey length] > 0) {
        
        [self backupCipherConfiguration];
        [self updateCipherDataWithCipherKey:configuration.cipherKey];
        
        // Create new cryptors with updated configuration
        initStatus = [self getCryptor:&encoder forOperation:kCCEncrypt];
        if (initStatus == kCCSuccess){
            
            isEncryptorCreated = YES;
            initStatus = [self getCryptor:&decoder forOperation:kCCDecrypt];

            CCCryptorRelease(encoder);
            CCCryptorRelease(decoder);
        }
        [self restoreCipheConfiguration];
    }
    else {
        
        cryptorInitError = [PNError errorWithCode:kPNCryptoEmptyCipherKeyError];
    }
    
    
    // Ensure that initialization was successful or generate
    // error message
    if (initStatus != kCCSuccess && cryptorInitError == nil) {

        NSString *errorMessage = [NSString stringWithFormat:@"%@ initalization error",
                                                            isEncryptorCreated ? @"Decryptor" : @"Encryptor"];
        cryptorInitError = [PNError errorWithMessage:errorMessage code:[self errorCodeFromStatus:initStatus]];
    }

    
    // Return reference on generated error if it is possible
    if (cryptorInitError != nil) {
        
        if (error != NULL) {
            
            *error = cryptorInitError;
        }
    }
    else {

        self.ready = YES;
    }


    return cryptorInitError == nil;
}

- (NSString *)encryptedStringFromString:(NSString *)plainString error:(PNError *__strong *)error {

    return [self processString:plainString cryptorType:PNCryptorEncrypt error:error];
}

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
- (id)encryptedObjectFromObject:(id)objectForEncryption error:(PNError *__strong *)error {

    id encryptedMessage = nil;

    if ([objectForEncryption isKindOfClass:[NSString class]]) {

        encryptedMessage = [self encryptedStringFromString:objectForEncryption error:error];
    }
    else if ([objectForEncryption isKindOfClass:[NSArray class]]) {

        encryptedMessage = [self arrayOfEnryptedValues:objectForEncryption error:error];
    }
    else if ([objectForEncryption isKindOfClass:[NSDictionary class]]) {

        encryptedMessage = [self dictionaryOfEnryptedValues:objectForEncryption error:error];
    }


    return encryptedMessage;
}

- (NSArray *)arrayOfEnryptedValues:(NSArray *)arrayForEncryption error:(PNError *__strong *)error {

    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:[arrayForEncryption count]];
    [arrayForEncryption enumerateObjectsUsingBlock:^(id objectForEncryption, NSUInteger objectIndex,
                                                     BOOL *objectEnumeratorStop) {

        id encryptedObject = [self encryptedObjectFromObject:objectForEncryption error:error];
        if (((error != NULL && *error == NULL) || error == NULL) && encryptedObject != nil) {

            [messages addObject:encryptedObject];
        }
        else {

            *objectEnumeratorStop = YES;
        }
    }];


    return messages;
}

- (NSDictionary *)dictionaryOfEnryptedValues:(NSDictionary *)dictionaryForEncryption error:(PNError *__strong *)error {

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[dictionaryForEncryption count]];
    [dictionaryForEncryption enumerateKeysAndObjectsUsingBlock:^(id key,
                                                                 id objectForEncryption,
                                                                 BOOL *objectEnumeratorStop) {

        id encryptedObject = [self encryptedObjectFromObject:objectForEncryption error:error];
        if (((error != NULL && *error == NULL) || error == NULL) && encryptedObject != nil) {

            [dictionary setValue:encryptedObject forKey:key];
        }
        else {

            *objectEnumeratorStop = YES;
        }
    }];


    return dictionary;
}
#endif

- (NSString *)decryptedStringFromString:(NSString *)encodedString error:(PNError *__strong *)error {

    return [self processString:encodedString cryptorType:PNCryptorDecrypt error:error];
}

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
- (id)decryptedObjectFromObject:(id)encodedObject error:(PNError *__strong *)error {

    id decryptedMessage = nil;

    if ((error != NULL && *error == nil) || error == NULL) {
        
        if ([encodedObject isKindOfClass:[NSString class]]) {
            
            decryptedMessage = [self decryptedStringFromString:encodedObject error:error];
        }
        else if ([encodedObject isKindOfClass:[NSArray class]]) {
            
            decryptedMessage = [self arrayOfDecryptedValues:encodedObject error:error];
        }
        else if ([encodedObject isKindOfClass:[NSDictionary class]]) {
            
            decryptedMessage = [self dictionaryOfDecryptedValues:encodedObject error:error];
        }
    }
    
    return decryptedMessage;
}

- (NSArray *)arrayOfDecryptedValues:(NSArray *)arrayForDecryption error:(PNError *__strong *)error {

    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:[arrayForDecryption count]];
    [arrayForDecryption enumerateObjectsUsingBlock:^(id objectForDecryption,
                                                     NSUInteger objectIndex,
                                                     BOOL *objectEnumeratorStop) {

        id decryptedObject = [self decryptedObjectFromObject:objectForDecryption error:error];
        if (((error != NULL && *error == NULL) || error == NULL) && decryptedObject != nil) {

            [messages addObject:decryptedObject];
        }
        else {

            *objectEnumeratorStop = YES;
        }
    }];


    return messages;
}

- (NSDictionary *)dictionaryOfDecryptedValues:(NSDictionary *)dictionaryForDecryption error:(PNError *__strong *)error {

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[dictionaryForDecryption count]];
    [dictionaryForDecryption enumerateKeysAndObjectsUsingBlock:^(id key, id objectForDecryption,
                                                                 BOOL *objectEnumeratorStop) {

        id decryptedObject = [self decryptedObjectFromObject:objectForDecryption error:error];
        if (((error != NULL && *error == NULL) || error == NULL) && decryptedObject != nil) {

            [dictionary setValue:decryptedObject forKey:key];
        }
        else {

            *objectEnumeratorStop = YES;
        }
    }];


    return dictionary;
}
#endif

- (CCCryptorStatus)getProcessedData:(NSData **)outputData fromInputData:(NSData *)inputData
                    withCryptorType:(PNCryptorType)cryptorType {

    CCCryptorStatus processingStatus = kCCParamError;
    if (self.ready) {

        // Create new cryptor
        CCCryptorRef cryptor;
        CCCryptorStatus initStatus = [self getCryptor:&cryptor forOperation:cryptorType];

        // Check whether cryptor was successfully created or not
        if (initStatus == kCCSuccess) {

            // Prepare storage for processed data
            size_t processedDataLength = CCCryptorGetOutputLength(cryptor, [inputData length], true);
            NSMutableData *processedData = [NSMutableData dataWithLength:processedDataLength];

            // Perform processing and response data size adjustment calculation
            size_t updatedProcessedDataLength;
            processingStatus = CCCryptorUpdate(cryptor, [inputData bytes], [inputData length], [processedData mutableBytes],
                                               [processedData length], &updatedProcessedDataLength);

            if (processingStatus == kCCSuccess) {

                // Complete data processing
                char *processedDataEndPointer = [processedData mutableBytes]+updatedProcessedDataLength;
                size_t unfilledSize = [processedData length] - updatedProcessedDataLength;
                size_t remainingUnprocessedDataLength;
                processingStatus = CCCryptorFinal(cryptor, processedDataEndPointer, unfilledSize, &remainingUnprocessedDataLength);
                [processedData setLength:(updatedProcessedDataLength+remainingUnprocessedDataLength)];
            }


            // Check whether processing completed or not
            if (processingStatus == kCCSuccess) {

                if (outputData != NULL) {

                    *outputData = processedData;
                }
                
                if (cryptorType == PNCryptorDecrypt) {
                    
                    // Check whether length of processed data is zero when input data has positive value (maybe AES decryptor parsed as empty string
                    // but it should be treated as error)
                    if ([inputData length] > 0 && [processedData length] == 0) {
                        
                        processingStatus = kCCDecodeError;
                    }
                }
            }
        }
        CCCryptorRelease(cryptor);
    }


    return processingStatus;
}

- (NSString *)processString:(NSString *)string cryptorType:(PNCryptorType)cryptorType error:(PNError *__strong *)error {
    
    NSString *processedString = string;
    NSInteger errorCode = -1;
    
    if (self.ready) {
        
        CCCryptorStatus status = kCCSuccess;
        NSData *inputData;
        if (cryptorType == PNCryptorDecrypt) {

            inputData = [NSData pn_dataFromBase64String:string];
            
            if (inputData == nil) {
                
                status = kCCDecodeError;
            }
        }
        else {
            
            inputData = [string dataUsingEncoding:NSUTF8StringEncoding];
        }

        NSData *processedData = nil;
        if (status == kCCSuccess) {
            
            status = [self getProcessedData:&processedData fromInputData:inputData withCryptorType:cryptorType];
        }

        if (status == kCCSuccess) {

            if (processedData != nil) {

                if (cryptorType == PNCryptorEncrypt) {

                    processedString = [processedData pn_base64Encoding];
                }
                else {

                    processedString = [NSString stringWithUTF8String:[processedData bytes]];
                }
            }
        }
        else {

            errorCode = [self errorCodeFromStatus:status];
        }
    }
    else {

        errorCode = kPNCryptoIllegalInitializationParametersError;
    }


    if (errorCode >= 0) {

        if (error != NULL) {

            *error = [PNError errorWithCode:errorCode];
        }
    }
    
    
    return processedString;
}


#pragma mark - Misc methods

- (void)updateCipherDataWithCipherKey:(NSString *)cipherKey {

    if (self.cryptorInitializationVectorData == nil) {

        // Prepare cryptor initialization vector
        self.cryptorInitializationVectorData = [@"0123456789012345" dataUsingEncoding:NSUTF8StringEncoding];
    }

#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
    // Update cryptor key
    self.cryptorKeyData = [[cipherKey pn_sha256HEXString] dataUsingEncoding:NSUTF8StringEncoding];
#else
    // Update cryptor key
    self.cryptorKeyData = [cipherKey pn_md5Data];
#endif
}

- (void)backupCipherConfiguration {
    
    self.backedUpCryptorKeyData = self.cryptorKeyData;
}

- (void)restoreCipheConfiguration {
    
    if (self.backedUpCryptorKeyData) {
        
        self.cryptorKeyData = self.backedUpCryptorKeyData;
    }
}

- (CCCryptorStatus)getCryptor:(CCCryptorRef *)cryptor forOperation:(CCOperation)operation {

    CCCryptorStatus cryptCreateStatus = CCCryptorCreate(operation, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                                        [self.cryptorKeyData bytes], [self.cryptorKeyData length],
                                                        [self.cryptorInitializationVectorData bytes], cryptor);
    
    return cryptCreateStatus;
}

- (CCCryptorStatus)resetCryptor:(CCCryptorRef)cryptor {
    
    return CCCryptorReset(cryptor, [self.cryptorInitializationVectorData bytes]);
}

- (NSInteger)errorCodeFromStatus:(CCCryptorStatus)status {
    
    NSInteger errorCode = -1;
    switch (status) {
        case kCCParamError:
            
            errorCode = kPNCryptoIllegalInitializationParametersError;
            break;
        case kCCBufferTooSmall:
            
            errorCode = kPNCryptoInsufficentBufferSizeError;
            break;
        case kCCMemoryFailure:
            
            errorCode = kPNCryptoInsufficentMemoryError;
            break;
        case kCCAlignmentError:
            
            errorCode = kPNCryptoAligmentInputDataError;
            break;
        case kCCDecodeError:
            
            errorCode = kPNCryptoInputDataProcessingError;
            break;
        case kCCUnimplemented:
            
            errorCode = kPNCryptoUnavailableFeatureError;
            break;
            
        default:
            break;
    }


    return errorCode;
}


#pragma mark - Memory management

- (void)dealloc {

    [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{

        return @[PNLoggerSymbols.cryptor.destroyed];
    }];
}

#pragma mark -


@end
