#import <Foundation/Foundation.h>
#import "PNStructures.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Class which allow to perform AES based encryption/decryption on provided data.
 *
 * @discussion Encryption works with native Foundation objects which internally will be translated to JSON
 * object. Decryption process will return Foundation object in response on Base64 encoded string.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.0.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNAES : NSObject


#pragma mark - Data encryption

/**
 * @brief Encrypt \c data content and encode into Base64 string.
 *
 * @discussion Input \c data for example can be output of \a NSJSONSerialization or data created from
 * \a NSString with UTF-8 encoding.
 *
 * @param data \a NSData object which should be encrypted.
 * @param key Key which should be used to encrypt data basing on it.
 *
 * @return Encrypted Base64-encoded string received from Foundation object. \c nil will be returned in case of
 * failure.
 */
+ (nullable NSString *)encrypt:(NSData *)data withKey:(NSString *)key;

/**
 * @brief Encrypt \c data content and encode into Base64 string.
 *
 * @discussion Input \c data for example can be output of \a NSJSONSerialization or data created from
 *   \a NSString with UTF-8 encoding.
 * @discussion Extension to \c -encrypt:withKey: and allow to specify pointer where encryption error can be
 *   passed.
 *
 * @param data \a NSData object which should be encrypted.
 * @param key Key which should be used to encrypt data basing on it.
 * @param error Pointer into which encryption error will be stored in case of encryption failure. Error
 *   can be related to JSON string serialization as well as encryption itself.
 *
 * @return Encrypted Base64-encoded string received from Foundation object. \c nil will be returned
 * in case of failure.
 */
+ (nullable NSString *)encrypt:(NSData *)data
                       withKey:(NSString *)key
                      andError:(NSError *__autoreleasing *)error;

/**
 * @brief Encrypt \c data content and encode into Base64 string.
 *
 * @discussion Input \c data for example can be output of \a NSJSONSerialization or data created from
 *   \a NSString with UTF-8 encoding.
 * @discussion Extension to \c -encrypt:withKey: and allow to specify pointer where encryption error can be
 *   passed.
 *
 * @param data \a NSData object which should be encrypted.
 * @param useRandomIV Whether random initialization vector should be used by \b PNAES.
 * @param key Key which should be used to encrypt data basing on it.
 * @param error Pointer into which encryption error will be stored in case of encryption failure. Error
 *   can be related to JSON string serialization as well as encryption itself.
 *
 * @return Encrypted Base64-encoded string received from Foundation object. \c nil will be returned
 * in case of failure.
 */
+ (nullable NSString *)encrypt:(NSData *)data
                  withRandomIV:(BOOL)useRandomIV
                     cipherKey:(NSString *)key
                      andError:(NSError *__autoreleasing *)error;

/**
 * @brief Encrypt file at specified local URL.
 *
 * @param fileURL URL of local file which should be encrypted.
 * @param encryptedFileURL URL where encrypted file should be stored. Encrypted file will be stored in \c temporary directory if \c nil is
 *   passed (\c temporary file will be removed after completion block return) and \c location will be returned in completion \c block.
 * @param key Key which should be used to encrypt file.
 * @param block File encryption completion block.
 */
+ (void)encryptFileAtURL:(NSURL *)fileURL
                   toURL:(nullable NSURL *)encryptedFileURL
           withCipherKey:(NSString *)key
              completion:(void(^)(NSURL * _Nullable location, NSError * _Nullable error))block;


#pragma mark - Data decryption

/**
 * @brief Transform encrypted Base64 encoded string to \a NSData instance.
 *
 * @discussion Received data for example can be used with \a NSJSONSerialization to convert it's
 * content to Foundation objects.
 *
 * @param object Previously encrypted Base64-encoded string which should be decrypted.
 * @param key Key which should be used to decrypt data.
 *
 * @return Initial \a NSData which has been encrypted earlier. \c nil will be returned in case of
 * decryption error.
 */
+ (nullable NSData *)decrypt:(NSString *)object withKey:(NSString *)key;

/**
 * @brief Transform encrypted Base64 encoded string to \a NSData instance.
 *
 * @discussion Received data for example can be used with \a NSJSONSerialization to convert it's
 *   content to Foundation objects.
 * @discussion Extension to \c -decrypt:withKey: and allow to specify pointer where decryption error can be
 *   passed.
 *
 * @param object Previously encrypted Base64-encoded string which should be decrypted.
 * @param key Key which should be used to decrypt data.
 * @param error Pointer into which decryption error will be stored in case of decryption failure. Error
 *   can be related to JSON string deserialization as well as decryption itself.
 *
 * @return Initial \a NSData which has been encrypted earlier. \c nil will be returned in case of
 * decryption error.
 */
+ (nullable NSData *)decrypt:(NSString *)object
                     withKey:(NSString *)key
                    andError:(NSError *__autoreleasing *)error;

/**
 * @brief Transform encrypted Base64 encoded string to \a NSData instance.
 *
 * @discussion Received data for example can be used with \a NSJSONSerialization to convert it's
 *   content to Foundation objects.
 * @discussion Extension to \c -decrypt:withKey: and allow to specify pointer where decryption error can be
 *   passed.
 *
 * @param object Previously encrypted Base64-encoded string which should be decrypted.
 * @param useRandomIV Whether random initialization vector should be used by \b PNAES.
 * @param key Key which should be used to decrypt data.
 * @param error Pointer into which decryption error will be stored in case of decryption failure. Error
 *   can be related to JSON string deserialisation as well as decryption itself.
 *
 * @return Initial \a NSData which has been encrypted earlier. \c nil will be returned in case of
 * decryption error.
 */
+ (nullable NSData *)decrypt:(NSString *)object
                withRandomIV:(BOOL)useRandomIV
                   cipherKey:(NSString *)key
                    andError:(NSError *__autoreleasing *)error;

/**
 * @brief Decrypt file at specified local URL.
 *
 * @param fileURL URL of local file which should be decrypted.
 * @param decryptedFileURL URL where decrypted file should be stored. Decrypted file will be stored in \c temporary directory if \c nil is
 *   passed (\c temporary file will be removed after completion block return) and \c location will be returned in completion \c block.
 * @param key Key which should be used to decrypt file.
 * @param block File decryption completion block.
 */
+ (void)decryptFileAtURL:(NSURL *)fileURL
                   toURL:(nullable NSURL *)decryptedFileURL
           withCipherKey:(NSString *)key
              completion:(void(^)(NSURL *location, NSError * _Nullable error))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
