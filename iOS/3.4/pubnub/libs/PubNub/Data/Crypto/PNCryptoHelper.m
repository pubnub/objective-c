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
#import "PNConfiguration.h"
#import "PNError.h"


#pragma mark Static

/**
 * Stores reference on encryptor which will be used to
 * encode data (stored for performance reasons)
 */
static CCCryptorRef _sharedEncryptor = NULL;

/**
 * Stores reference on decryptor which will be used to
 * decode data (stored for performance reasons)
 */
static CCCryptorRef _sharedDecryptor = NULL;

/**
 * Stores reference on intialization vector
 */
static NSData *_cryptorInitializationVectorData = nil;


#pragma mark - Private interface implementation

@interface PNCryptoHelper ()


#pragma mark - Instance methods

/**
 * Process data with specified cryptor and input data
 */
- (CCCryptorStatus)getProcessedData:(NSData *__autoreleasing *)outputData
                      fromInputData:(NSData *)inputData
                        withCryptor:(CCCryptorRef)cryptor;

/**
 * Process specified string and return processing result
 */
- (NSString *)processString:(NSString *)string withCryptor:(CCCryptorRef)cryptor error:(PNError *__autoreleasing *)error;


#pragma mark - Misc methods

/**
 * Construct and return reference on prepared cryptor
 * which will be used for data encode/decode depending
 * on specified options
 */
- (CCCryptorStatus)getCryptor:(CCCryptorRef *)cryptor
                 forOperation:(CCOperation)operation
            withConfiguration:(PNConfiguration *)configuration;

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
    
    static PNCryptoHelper *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [self new];
    });
    
    
    return _sharedInstance;
}


#pragma mark - Instance methods

- (BOOL)updateWithConfiguration:(PNConfiguration *)configuration withError:(PNError *__autoreleasing *)error {
    
    // Destroy previously created encryptor instance
    if (_sharedEncryptor != NULL) {
        
        CCCryptorRelease(_sharedEncryptor);
    }
    
    // Destroy previously created decryptor instance
    if (_sharedDecryptor != NULL) {
        
        CCCryptorRelease(_sharedDecryptor);
    }
    
    
    PNError *cryptorInitError = nil;
    CCCryptorStatus initStatus = kCCSuccess;
    BOOL isEncryptorCreated = NO;
    
    // Check whether developer specified cipher key in configuration or not
    if ([configuration.cipherKey length] > 0) {
        
        // Create new cryptors with updated configuration
        initStatus = [self getCryptor:&_sharedEncryptor forOperation:kCCEncrypt withConfiguration:configuration];
        if (initStatus == kCCSuccess){
            
            isEncryptorCreated = YES;
            initStatus = [self getCryptor:&_sharedDecryptor forOperation:kCCDecrypt withConfiguration:configuration];
        }
    }
    else {
        
        cryptorInitError = [PNError errorWithCode:kPNCryptoEmptyCipherKeyError];
    }
    
    
    // Ensure that intialization was successfull or generate
    // error message
    if (initStatus != kCCSuccess && cryptorInitError == nil) {
        
        NSString *errorMessage = [NSString stringWithFormat:@"%@ initalization error",
                                  isEncryptorCreated?@"Decryptor":@"Encryptor"];
        cryptorInitError = [PNError errorWithMessage:errorMessage code:[self errorCodeFromStatus:initStatus]];
    }

    
    // Return reference on generated error if it is possible
    if (cryptorInitError != nil) {
        
        if (error != NULL) {
            
            *error = cryptorInitError;
        }
    }


    return cryptorInitError == nil;
}

- (NSString *)encryptedStringFromString:(NSString *)plainString error:(PNError **)error {
    
    return [self processString:plainString withCryptor:_sharedEncryptor error:error];
}

- (NSString *)decryptedStringFromString:(NSString *)encodedString error:(PNError **)error {
    
    return [self processString:encodedString withCryptor:_sharedDecryptor error:error];
}

- (CCCryptorStatus)getProcessedData:(NSData *__autoreleasing *)outputData
                      fromInputData:(NSData *)inputData
                        withCryptor:(CCCryptorRef)cryptor; {
    
    // Prepare storage for processed data
    size_t processedDataLength = CCCryptorGetOutputLength(cryptor, [inputData length], true);
    NSMutableData *processedData = [NSMutableData dataWithLength:processedDataLength];
    
    // Perform processing and response data size adjustment calculation
    size_t updatedProcessedDataLength;
    CCCryptorStatus processingStatus = CCCryptorUpdate(cryptor,
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
    
    return processingStatus;
}

- (NSString *)processString:(NSString *)string withCryptor:(CCCryptorRef)cryptor error:(PNError *__autoreleasing *)error {
    
    NSString *processedString = string;
    
    if (cryptor != NULL) {
        
        NSInteger errorCode = -1;
        CCCryptorStatus status = [self resetCryptor:cryptor];
        if (status == kCCSuccess) {
            
            NSData *processedData = nil;
            status = [self getProcessedData:&processedData
                              fromInputData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                withCryptor:cryptor];
            
            if (status == kCCSuccess) {
                
                if (processedData != nil) {
                    
                    if (cryptor == _sharedEncryptor) {
                        
                        processedString = [processedData base64Encoding];
                    }
                    else {
                        
                    }
                }
            }
            else {
                
                errorCode = [self errorCodeFromStatus:status];
            }
        }
        else {
            
            errorCode = kPNCryptoStateResetError;
        }
        
        if (errorCode >= 0) {
            
            if (error != NULL) {
                
                *error = [PNError errorWithCode:errorCode];
            }
        }
    }
    
    
    return processedString;
}


#pragma mark - Misc methods

- (CCCryptorStatus)getCryptor:(CCCryptorRef *)cryptor
                 forOperation:(CCOperation)operation
            withConfiguration:(PNConfiguration *)configuration; {
    
    // Prepare key
    NSMutableData *key = [[[configuration.cipherKey sha256HEXString] dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    
    if (_cryptorInitializationVectorData == nil) {
        
        // Prepare cryptor initialization vector
        _cryptorInitializationVectorData = [@"0123456789012345" dataUsingEncoding:NSUTF8StringEncoding];
        
    }
    
    
    // Create cryptor
    CCCryptorStatus cryptCreateStatus = CCCryptorCreateWithMode(operation,
                                                                kCCModeCBC,
                                                                kCCAlgorithmAES128,
                                                                ccPKCS7Padding,
                                                                [_cryptorInitializationVectorData bytes],
                                                                [key bytes],
                                                                [key length],
                                                                NULL,
                                                                0,
                                                                0,
                                                                0,
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

#pragma mark -


@end
