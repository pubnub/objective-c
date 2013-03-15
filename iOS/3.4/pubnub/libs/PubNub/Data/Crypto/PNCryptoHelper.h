//
//  PNCryptoHelper.h
//  pubnub
//  Helper which allow to encode user messages and responsible
//  for CCCryptor instance maintenance.
//
//  Created by Sergey Mamontov on 3/15/13.
//
//

#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNConfiguration, PNError;


@interface PNCryptoHelper : NSObject


#pragma mark - Class methods

/**
 * Retrieve reference on on helper instance.
 * At first launch instance should be configurated.
 */
+ (PNCryptoHelper *)sharedInstance;


#pragma mark - Instance methods

/**
 * Update helper configuration and return whether it was
 * successful and error in case if there is some
 */
- (BOOL)updateWithConfiguration:(PNConfiguration *)configuration withError:(PNError *__autoreleasing *)error;

/**
 * Returns reference on encrypted string which can be sent
 * to remote PubNub origin for processing.
 * In case of encryption error message will be generated.
 */
- (NSString *)encryptedStringFromString:(NSString *)plainString error:(PNError *__autoreleasing *)error;

/**
 * Returns reference on decrypted string which received from 
 * encoded server response
 * In case of decryption error message will be generated.
 */
- (NSString *)decryptedStringFromString:(NSString *)encodedString error:(PNError *__autoreleasing *)error;

#pragma mark -


@end
