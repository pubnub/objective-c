#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Input stream which allow to unify multiple streams and send as one on pulling data on
 * demand.
 *
 * @discussion This class makes easier to send multipart form data with attachments (which can be
 * even files on file system).
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNMultipartInputStream : NSInputStream


#pragma mark - Information

/**
 * @brief List of input streams from which data will be read.
 *
 * @discussion Input streams will be read one after another (in same order as they appear in
 * array) seamlessly to make it looks like work with single input stream.
 */
@property (nonatomic, readonly, strong) NSArray<NSInputStream *> *streams;

/**
 * @brief Overall stream size.
 */
@property (nonatomic, readonly, assign) NSUInteger size;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure multipart form data body input stream.
 *
 * @throws An exception in case if list of passed \c streams is empty.
 *
 * @param streams List of input stream which should be appended to request body.
 * @param sizes List with information about size of data which can be provided by each stream.
 * @param cipherKey Key which should be used to encrypt stream content.
 *
 * @return Configured and ready multipart form data body input stream.
 */
+ (instancetype)streamWithInputStreams:(NSArray<NSInputStream *> *)streams
                                 sizes:(NSArray<NSNumber *> *)sizes
                             cipherKey:(NSString *)cipherKey;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
