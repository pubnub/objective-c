#import "PNSendFileRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c upload \c file request extension to provide access to stream.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSendFileRequest (Private)


#pragma mark - Information

/**
 * @brief Input stream with data which should be uploaded to remote storage server / service.
 */
@property (nonatomic, readonly, strong) NSInputStream *stream;

/**
 * @brief Size of data which can be read from \c stream.
 */
@property (nonatomic, readonly, assign) NSUInteger size;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
