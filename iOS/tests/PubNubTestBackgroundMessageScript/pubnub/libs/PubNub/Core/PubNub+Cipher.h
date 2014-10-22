#import "PubNub.h"

/**
 Base class extension which provide methods for encryption/descryption manipulation.
 
 @author Sergey Mamontov
 @version 3.7.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PubNub (Cipher)


#pragma mark - Class (singleton) methods

/**
 Cryptographic function which allow to decrypt AES hash stored inside 'base64' string and return object
 */
+ (id)AESDecrypt:(id)object;
+ (id)AESDecrypt:(id)object error:(PNError **)decryptionError;

/**
 Cryptographic function which allow to encrypt object into 'base64' string using AES and return hash string
 */
+ (NSString *)AESEncrypt:(id)object;
+ (NSString *)AESEncrypt:(id)object error:(PNError **)encryptionError;


#pragma mark - Instance methods

/**
 Cryptographic function which allow to decrypt AES hash stored inside 'base64' string and return object
 */
- (id)AESDecrypt:(id)object;
- (id)AESDecrypt:(id)object error:(PNError **)decryptionError;

/**
 Cryptographic function which allow to encrypt object into 'base64' string using AES and return hash string
 */
- (NSString *)AESEncrypt:(id)object;
- (NSString *)AESEncrypt:(id)object error:(PNError **)encryptionError;

#pragma mark -


@end
