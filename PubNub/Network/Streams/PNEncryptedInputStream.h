#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Input stream with ability to encrypt data read data.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNEncryptedInputStream : NSInputStream


#pragma mark - Information

/**
 * @brief Overall stream size (which include random initialization vector).
 */
@property (nonatomic, readonly, assign) NSUInteger size;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure encrypted input stream from.
 *
 * @param inputStream Input stream with raw data, which should be encrypted during read.
 * @param size Size of data which will be provided by \c inputStream.
 * @param cipherKey Key which should be used to encrypt stream content.
 *
 * @return Configured and ready to use encrypted input stream.
 */
+ (instancetype)inputStreamWithInputStream:(NSInputStream *)inputStream
                                      size:(NSUInteger)size
                                 cipherKey:(NSString *)cipherKey;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
