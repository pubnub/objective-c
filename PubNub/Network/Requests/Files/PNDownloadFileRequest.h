#import "PNStructures.h"
#import "PNRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Download \c file request.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNDownloadFileRequest : PNRequest


#pragma mark - Information

/**
 * @brief Arbitrary percent encoded query parameters which should be sent along with original API call.
 */
@property (nonatomic, nullable, strong) NSDictionary *arbitraryQueryParameters;

/**
 * @brief Key which should be used to decrypt downloaded data.
 *
 * @note Configured \b PubNub instance \c cipherKey will be used if this property not set.
 */
@property (nonatomic, nullable, copy) NSString *cipherKey;

/**
 * @brief URL where downloaded file should be stored locally.
 *
 * @note File will be downloaded to temporary location if value not set. Location will be passed to completion block and file will be
 * removed on completion block exit.
 */
@property (nonatomic, nullable, strong) NSURL *targetURL;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c download \c file request.
 *
 * @param channel Name of channel from which \c file with \c name should be downloaded.
 * @param identifier Unique \c file identifier which has been assigned during \c file upload.
 * @param name Name under which uploaded \c file is stored for \c channel.
 *
 * @return Configured and ready to use \c download \c file request.
 */
+ (instancetype)requestWithChannel:(NSString *)channel
                        identifier:(NSString *)identifier
                              name:(NSString *)name;

/**
 * @brief Forbids request initialization.
 *
 * @throws Interface not available exception and requirement to use provided constructor method.
 *
 * @return Initialized request.
 */
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
