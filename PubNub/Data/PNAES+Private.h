#import "PNAES.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Private data encryption extension which allow to create encryptor instances for files
 * processing.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNAES (Private)


#pragma mark - Information

/**
 * @brief Data \c encryption / \c decryption error.
 */
@property (nonatomic, readonly, nullable, strong) NSError *processingError;

/**
 * @brief Cryptor initialization vector which can be used to encrypt data using AES128 algorithm.
 */
@property (nonatomic, readonly, strong) NSData *initializationVector;

/**
 * @brief Smallest size of encrypted plaintext.
 */
@property (nonatomic, readonly, assign) NSUInteger cipherBlockSize;


#pragma mark Initialization & Configuration

/**
 * @brief Create and configure data encryptor.
 *
 * @param cipherKey Key which should be used during data \c encryption.
 *
 * @return Configured and ready to use encryptor instance.
 */
+ (instancetype)encryptorWithCipherKey:(NSString *)cipherKey;

/**
 * @brief Create and configure data decryptor.
 *
 * @param cipherKey Key which should be used during data \c decryption.
 *
 * @return Configured and ready to use decryptor instance.
 */
+ (instancetype)decryptorWithCipherKey:(NSString *)cipherKey;


#pragma mark - Processing

/**
 * @brief Process more \c data using currently configured cryptor.
 *
 * @param processedData Data which already has been processed.
 * @param rawData Address from which data should be \c encrypted / \c decrypted.
 * @param length Number of bytes which should be processed for provided pointer.
 *
 * @return Number of bytes which has been written to \c processedData.
 */
- (NSInteger)updateProcessedData:(NSMutableData *)processedData
                    usingRawData:(uint8_t *)rawData
                      withLength:(NSUInteger)length;

/**
 * @brief Complete data processing using currently configured cryptor.
 *
 * @param processedData Data which already has been processed.
 * @param length Number of bytes which should be processed.
 *
 * @return Number of bytes which has been written to \c processedData.
 */
- (NSInteger)finalizeProcessedData:(NSMutableData *)processedData
                        withLength:(NSUInteger)length;


#pragma mark - Misc

/**
 * @brief Calculate size of buffer which is required to fit data of specified \c size.
 *
 * @param size Size of data for which target buffer size is required.
 *
 * @return Size of buffer which will be able to fit processed data.
 */
- (NSUInteger)targetBufferSize:(NSInteger)size;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
