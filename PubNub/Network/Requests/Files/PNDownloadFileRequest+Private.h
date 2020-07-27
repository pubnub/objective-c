#import "PNDownloadFileRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c download \c file request extension to provide access to file information.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNDownloadFileRequest (Private)


#pragma mark - Information

/**
 * @brief Unique \c file identifier which has been assigned during \c file upload.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 * @brief Name of channel from which \c file with \c name should be downloaded.
 */
@property (nonatomic, readonly, copy) NSString *channel;

/**
 * @brief Name under which uploaded \c file is stored for \c channel.
 */
@property (nonatomic, readonly, copy) NSString *name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
