#import "PNFilesAPICallBuilder.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Download \c file API call builder.
 *
 * @author Serhii Mamontov
 * @version 4.15.0 
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNDownloadFileAPICallBuilder : PNFilesAPICallBuilder


#pragma mark - Configuration

/**
 * @brief Key which is used to decrypt downloaded file
 *
 * @param cipherKey Data decryption key.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNDownloadFileAPICallBuilder * (^cipherKey)(NSString *key);

/**
 * @brief URL to location where file should be stored.
 *
 * @note If file URL not set, file will be loaded in-memory.
 *
 * @param url URL on local file system.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNDownloadFileAPICallBuilder * (^url)(NSURL *url);


#pragma mark - Execution

/**
 * @brief Perform API call.
 *
 * @param block \c Download \c file completion handler block.
 */
@property (nonatomic, readonly, strong) void(^performWithCompletion)(PNDownloadFileCompletionBlock block);


#pragma mark - Misc

/**
 * @brief Arbitrary query parameters addition block.
 *
 * @param params List of arbitrary percent-encoded query parameters which should be sent along with
 * original API call.
 *
 * @return API call configuration builder.
 */
@property (nonatomic, readonly, strong) PNDownloadFileAPICallBuilder * (^queryParam)(NSDictionary *params);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
