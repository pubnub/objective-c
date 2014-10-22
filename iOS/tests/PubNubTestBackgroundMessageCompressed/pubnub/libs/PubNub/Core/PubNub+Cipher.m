/**
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-14 PubNub Inc.
 
 */

#import "PubNub+Cipher.h"
#import "PNJSONSerialization.h"
#import "PubNub+Protected.h"
#import "PNCryptoHelper.h"

#import "PNLogger+Protected.h"
#import "PNLoggerSymbols.h"


#pragma mark - Category private interface declaration

@interface PubNub (CipherPrivate)


#pragma mark - Instance methods


#pragma mark -


@end


#pragma mark - Category methods implementation

@implementation PubNub (Cipher)


#pragma mark - Class (singleton) methods

+ (id)AESDecrypt:(id)object {
    
    return [self AESDecrypt:object error:NULL];
}

+ (id)AESDecrypt:(id)object error:(PNError **)decryptionError {
    
    return [[self sharedInstance] AESDecrypt:object error:decryptionError];
}

+ (NSString *)AESEncrypt:(id)object {
    
    return [self AESEncrypt:object error:NULL];
}


+ (NSString *)AESEncrypt:(id)object error:(PNError **)encryptionError {
    
    return [[self sharedInstance] AESEncrypt:object error:encryptionError];
}


#pragma mark - Instance methods

- (id)AESDecrypt:(id)object {
    
    return [self AESDecrypt:object error:NULL];
}

- (id)AESDecrypt:(id)object error:(PNError **)decryptionError {
    
    __block id decryptedObject = nil;
    
    // Check whether user provided JSON string or not.
    if ([PNJSONSerialization isJSONString:object]) {
        
        if ([object isKindOfClass:[NSString class]]) {
            
            __block id decodedJSONObject = nil;
            [PNJSONSerialization JSONObjectWithString:object completionBlock:^(id result, BOOL isJSONP,
                                                                               NSString *callbackMethodName) {
                                          
                                          decodedJSONObject = result;
                                      }
                                           errorBlock:^(NSError *error) {
                                               
                                               [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                                   
                                                   return @[PNLoggerSymbols.api.messageDecryptionError,
                                                            (error? error : [NSNull null])];
                                               }];
                                           }];
            
            object = decodedJSONObject;
        }
        else {
            
            decryptedObject = object;
        }
    }
    
    if (self.cryptoHelper.ready) {
        
        PNError *processingError;
        NSInteger processingErrorCode = -1;
        
        #ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
            BOOL isExpectedDataType = [object isKindOfClass:[NSString class]];
        #else
            BOOL isExpectedDataType = [object isKindOfClass:[NSString class]] ||
            [object isKindOfClass:[NSArray class]] ||
            [object isKindOfClass:[NSDictionary class]];
        #endif
        if (isExpectedDataType) {
            
            #ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
                NSString *decodedMessage = [self.cryptoHelper decryptedStringFromString:object error:&processingError];
            #else
                id decodedMessage = [self.cryptoHelper decryptedObjectFromObject:object error:&processingError];
            #endif
            if (decodedMessage == nil || processingError != nil) {
                
                processingErrorCode = kPNCryptoInputDataProcessingError;
            }
            else if (decodedMessage != nil) {
                
                decryptedObject = decodedMessage;
            }
            
            #ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
                if (processingError == nil && processingErrorCode < 0) {
                    
                    [PNJSONSerialization JSONObjectWithString:decodedMessage
                                              completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName) {
                                                  
                                                  decryptedObject = result;
                                              }
                                                   errorBlock:^(NSError *error) {
                                                       
                                                       [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                                                           
                                                           return @[PNLoggerSymbols.api.messageDecryptionError,
                                                                    (error? error : [NSNull null])];
                                                       }];
                                                   }];
                }
            #endif
        }
        else {
            
            processingErrorCode = kPNCryptoInputDataProcessingError;
        }
        
        if (processingError != nil || processingErrorCode > 0) {
            
            if (processingErrorCode > 0) {
                
                processingError = [PNError errorWithCode:processingErrorCode];
            }
            if (decryptionError != NULL) {
                
                *decryptionError = processingError;
            }
            [PNLogger logGeneralMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.messageDecryptionError, (processingError? processingError : [NSNull null])];
            }];
            decryptedObject = @"DECRYPTION_ERROR";
        }
    }
    else {
        
        decryptedObject = object;
    }
    
    
    return decryptedObject;
}

- (NSString *)AESEncrypt:(id)object {
    
    return [self AESEncrypt:object error:NULL];
}

- (NSString *)AESEncrypt:(id)object error:(PNError **)encryptionError {
    
    PNError *processingError;
    NSString *encryptedObjectHash = nil;
    if (self.cryptoHelper.ready) {
        
        #ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
            object = object ? [PNJSONSerialization stringFromJSONObject:object] : @"";
            NSString *encryptedData = [self.cryptoHelper encryptedStringFromString:object error:&processingError];
            
            encryptedObjectHash = [NSString stringWithFormat:@"\"%@\"", encryptedData];
        #else
            id encryptedMessage = [self.cryptoHelper encryptedObjectFromObject:object error:&processingError];
            NSString *encryptedData = [PNJSONSerialization stringFromJSONObject:encryptedMessage];
            
            encryptedObjectHash = [NSString stringWithFormat:@"%@", encryptedData];
        #endif
        
        if (processingError != nil) {
            
            if (encryptionError != NULL) {
                
                *encryptionError = processingError;
            }
            [PNLogger logCommunicationChannelErrorMessageFrom:self withParametersFromBlock:^NSArray *{
                
                return @[PNLoggerSymbols.api.messageEncryptionError, (processingError ? processingError : [NSNull null])];
            }];
        }
    }
    
    
    return encryptedObjectHash;
}

#pragma mark -


@end
