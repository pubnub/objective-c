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
#import "NSString+PNAddition.h"
#import "PNPrivateImports.h"


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


#pragma mark Static

static PNCryptoHelper *_sharedInstance;
static dispatch_once_t onceToken;


// Stores reference on recent configuration which
// was used for crypto helper
static PNConfiguration *_configuration = nil;

// Stores reference on initialization vector
static NSData *_cryptorInitializationVectorData = nil;

// Stores reference on prepared cipher key
static NSData *_cryptorKeyData = nil;


#pragma mark - Private interface implementation

@interface PNCryptoHelper ()


#pragma mark - Properties

@property (nonatomic, assign, getter = isReady) BOOL ready;


#pragma mark - Instance methods

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
/**
 * Returns reference on array with encrypted values
 * from original array in it.
 * In case of encryption error message will be generated.
 */
- (NSArray *)arrayOfEnryptedValues:(NSArray *)arrayForEncryption error:(PNError *__autoreleasing *)error;

/**
 * Returns reference on dictionary with encrypted values
 * from original dictionary in it.
 * In case of encryption error message will be generated.
 */
- (NSDictionary *)dictionaryOfEnryptedValues:(NSDictionary *)dictionaryForEncryption
                                       error:(PNError *__autoreleasing *)error;
/**
 * Returns reference array with decrypted values
 * from original array in it.
 * In case of encryption error message will be generated.
 */
- (NSArray *)arrayOfDecryptedValues:(NSArray *)arrayForDecryption error:(PNError *__autoreleasing *)error;

/**
 * Returns reference dictionary with decrypted values
 * from original dictionary in it.
 * In case of encryption error message will be generated.
 */
- (NSDictionary *)dictionaryOfDecryptedValues:(NSDictionary *)dictionaryForDecryption
                                        error:(PNError *__autoreleasing *)error;
#endif

/**
 * Process data with specified cryptor and input data
 */
- (CCCryptorStatus)getProcessedData:(NSData * __autoreleasing *)outputData
                      fromInputData:(NSData *)inputData
                    withCryptorType:(PNCryptorType)cryptorType;

/**
 * Process specified string and return processing result
 */
- (NSString *)processString:(NSString *)string cryptorType:(PNCryptorType)cryptorType error:(PNError *__autoreleasing *)error;


#pragma mark - Misc methods

/**
 * Update cached data which is based on client's configuration
 */
- (void)updateCipherData;

/**
 * Construct and return reference on prepared cryptor
 * which will be used for data encode/decode depending
 * on specified options
 */
- (CCCryptorStatus)getCryptor:(CCCryptorRef *)cryptor
                 forOperation:(CCOperation)operation;

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

+ (PNCryptoHelper *)sharedInstance {

    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [self new];
    });
    
    
    return _sharedInstance;
}

+ (void)resetHelper {

    onceToken = 0;
    _configuration = nil;
    _cryptorInitializationVectorData = nil;
    _cryptorKeyData = nil;

    _sharedInstance = nil;
}


#pragma mark - Instance methods

- (BOOL)updateWithConfiguration:(PNConfiguration *)configuration withError:(PNError *__autoreleasing *)error {

    _configuration = configuration;
    [self updateCipherData];

    // Temporary encrypt/decrypt objects to validate provided
    // configuration
    CCCryptorRef encoder;
    CCCryptorRef decoder;

    PNError *cryptorInitError = nil;
    CCCryptorStatus initStatus = kCCSuccess;
    BOOL isEncryptorCreated = NO;
    
    // Check whether developer specified cipher key in configuration or not
    if ([configuration.cipherKey length] > 0) {
        
        // Create new cryptors with updated configuration
        initStatus = [self getCryptor:&encoder forOperation:kCCEncrypt];
        if (initStatus == kCCSuccess){
            
            isEncryptorCreated = YES;
            initStatus = [self getCryptor:&decoder forOperation:kCCDecrypt];

            CCCryptorRelease(encoder);
            CCCryptorRelease(decoder);
        }
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

- (NSString *)encryptedStringFromString:(NSString *)plainString error:(PNError **)error {

    return [self processString:plainString cryptorType:PNCryptorEncrypt error:error];
}

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
- (id)encryptedObjectFromObject:(id)objectForEncryption error:(PNError *__autoreleasing *)error {

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

- (NSArray *)arrayOfEnryptedValues:(NSArray *)arrayForEncryption error:(PNError *__autoreleasing *)error {

    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:[arrayForEncryption count]];
    [arrayForEncryption enumerateObjectsUsingBlock:^(id objectForEncryption,
                                                     NSUInteger objectIndex,
                                                     BOOL *objectEnumeratorStop) {

        id encryptedObject = [self encryptedObjectFromObject:objectForEncryption error:error];
        if ((error != NULL && *error == NULL) && encryptedObject != nil) {

            [messages addObject:encryptedObject];
        }
        else {

            *objectEnumeratorStop = YES;
        }
    }];


    return messages;
}

- (NSDictionary *)dictionaryOfEnryptedValues:(NSDictionary *)dictionaryForEncryption
                                       error:(PNError *__autoreleasing *)error {

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[dictionaryForEncryption count]];
    [dictionaryForEncryption enumerateKeysAndObjectsUsingBlock:^(id key,
                                                                 id objectForEncryption,
                                                                 BOOL *objectEnumeratorStop) {

        id encryptedObject = [self encryptedObjectFromObject:objectForEncryption error:error];
        if ((error != NULL && *error == NULL) && encryptedObject != nil) {

            [dictionary setValue:encryptedObject forKey:key];
        }
        else {

            *objectEnumeratorStop = YES;
        }
    }];


    return dictionary;
}
#endif

- (NSString *)decryptedStringFromString:(NSString *)encodedString error:(PNError **)error {

    return [self processString:encodedString cryptorType:PNCryptorDecrypt error:error];
}

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
- (id)decryptedObjectFromObject:(id)encodedObject error:(PNError *__autoreleasing *)error {

    id decryptedMessage = nil;

    if ([encodedObject isKindOfClass:[NSString class]]) {

        decryptedMessage = [self decryptedStringFromString:encodedObject error:error];
    }
    else if ([encodedObject isKindOfClass:[NSArray class]]) {

        decryptedMessage = [self arrayOfDecryptedValues:encodedObject error:error];
    }
    else if ([encodedObject isKindOfClass:[NSDictionary class]]) {

        decryptedMessage = [self dictionaryOfDecryptedValues:encodedObject error:error];
    }


    return decryptedMessage;
}

- (NSArray *)arrayOfDecryptedValues:(NSArray *)arrayForDecryption error:(PNError *__autoreleasing *)error {

    NSMutableArray *messages = [NSMutableArray arrayWithCapacity:[arrayForDecryption count]];
    [arrayForDecryption enumerateObjectsUsingBlock:^(id objectForDecryption,
                                                     NSUInteger objectIndex,
                                                     BOOL *objectEnumeratorStop) {

        id decryptedObject = [self decryptedObjectFromObject:objectForDecryption error:error];
        if ((error != NULL && *error == NULL) && decryptedObject != nil) {

            [messages addObject:decryptedObject];
        }
        else {

            *objectEnumeratorStop = YES;
        }
    }];


    return messages;
}

- (NSDictionary *)dictionaryOfDecryptedValues:(NSDictionary *)dictionaryForDecryption
                                        error:(PNError *__autoreleasing *)error {

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[dictionaryForDecryption count]];
    [dictionaryForDecryption enumerateKeysAndObjectsUsingBlock:^(id key,
                                                                 id objectForDecryption,
                                                                 BOOL *objectEnumeratorStop) {

        id decryptedObject = [self decryptedObjectFromObject:objectForDecryption error:error];
        if ((error != NULL && *error == NULL) && decryptedObject != nil) {

            [dictionary setValue:decryptedObject forKey:key];
        }
        else {

            *objectEnumeratorStop = YES;
        }
    }];


    return dictionary;
}
#endif

- (CCCryptorStatus)getProcessedData:(NSData * __autoreleasing *)outputData
                      fromInputData:(NSData *)inputData
                    withCryptorType:(PNCryptorType)cryptorType {

    CCCryptorStatus processingStatus = kCCParamError;
    if (self.isReady) {

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
            processingStatus = CCCryptorUpdate(cryptor,
                                               [inputData bytes],
                                               [inputData length],
                                               [processedData mutableBytes],
                                               [processedData length],
                                               &updatedProcessedDataLength);

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
            }
        }
        CCCryptorRelease(cryptor);
    }


    return processingStatus;
}

- (NSString *)processString:(NSString *)string cryptorType:(PNCryptorType)cryptorType error:(PNError *__autoreleasing *)error {
    
    NSString *processedString = string;
    NSInteger errorCode = -1;
    
    if (self.isReady) {
        
        CCCryptorStatus status = kCCSuccess;
        NSData *inputData;
        if (cryptorType == PNCryptorDecrypt) {

            inputData = [NSData dataFromBase64String:string];
            
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

                    processedString = [processedData base64Encoding];
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

- (void)updateCipherData {

    if (_cryptorInitializationVectorData == nil) {

        // Prepare cryptor initialization vector
        _cryptorInitializationVectorData = [@"0123456789012345" dataUsingEncoding:NSUTF8StringEncoding];
    }

#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
    // Update cryptor key
    _cryptorKeyData = [[_configuration.cipherKey sha256HEXString] dataUsingEncoding:NSUTF8StringEncoding];
#else
    // Update cryptor key
    _cryptorKeyData = [_configuration.cipherKey md5Data];
#endif
}

- (CCCryptorStatus)getCryptor:(CCCryptorRef *)cryptor
                 forOperation:(CCOperation)operation {

    CCCryptorStatus cryptCreateStatus = CCCryptorCreate(operation,
                                                        kCCAlgorithmAES128,
                                                        kCCOptionPKCS7Padding,
                                                        [_cryptorKeyData bytes],
                                                        [_cryptorKeyData length],
                                                        [_cryptorInitializationVectorData bytes],
                                                        cryptor);
    
    return cryptCreateStatus;
}

- (CCCryptorStatus)resetCryptor:(CCCryptorRef)cryptor {
    
    return CCCryptorReset(cryptor, [_cryptorInitializationVectorData bytes]);
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

    PNLog(PNLogGeneralLevel, self, @"Destroyed");
}

#pragma mark -


@end
