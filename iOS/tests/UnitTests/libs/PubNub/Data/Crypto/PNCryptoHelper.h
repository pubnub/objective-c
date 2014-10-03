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


#pragma mark - Public interface declaration

@interface PNCryptoHelper : NSObject


#pragma mark - Properties

/**
 Stores whether crypto helper configuration completed or not.
 */
@property (nonatomic, readonly, assign) BOOL ready;


#pragma mark - Class methods

/**
 Create and initialize crypto helper with specified set of configuration information.
 
 @param configuration
 Reference on configuration instance which hold all information which is required to complete crypto helper configuration.
 
 @param error
 Pointer which will store error object in case if any confuguration information can't be applied.
 
 @return Reference on fully initialized and ready to use \b PNCryptoHelper. \c nil will be returned in case if configuration
 can't be applied to the instance.
 */
+ (PNCryptoHelper *)helperWithConfiguration:(PNConfiguration *)configuration error:(PNError **)error;


#pragma mark - Instance methods

/**
 Update helper configuration and return whether it was successful and error in case if there is some.
 
 @param configuration
 Reference on configuration instance which hold all information which is required to complete crypto helper configuration.
 
 @param error
 Pointer which will store error object in case if any confuguration information can't be applied.
 
 @return \c YES in case if valid configuration has been provided.
 
 @warning In case if configuration update failed, cryptor will try to restore previous configuration. If this is initial
 configuration which is failed, cryptor helper won't be able to work as expected.
 */
- (BOOL)updateWithConfiguration:(PNConfiguration *)configuration withError:(PNError **)error;

/**
 Returns reference on encrypted string which can be sent to remote PubNub origin for processing. In case of encryption 
 error message will be generated.
 */
- (NSString *)encryptedStringFromString:(NSString *)plainString error:(PNError *__strong *)error;

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
/**
 Returns reference on encrypted object which was retrieved from object. In case of encryption error message will be 
 generated.
 */
- (id)encryptedObjectFromObject:(id)objectForEncryption error:(PNError *__strong *)error;
#endif

/**
 Returns reference on decrypted string which received from encoded server response. In case of decryption error message
 will be generated.
 */
- (NSString *)decryptedStringFromString:(NSString *)encodedString error:(PNError *__strong *)error;

#ifdef CRYPTO_BACKWARD_COMPATIBILITY_MODE
/**
 Returns reference on decrypted object which received from encoded server response. In case of encryption error message
 will be generated.
 */
- (id)decryptedObjectFromObject:(id)encodedObject error:(PNError *__strong *)error;
#endif

#pragma mark -


@end
