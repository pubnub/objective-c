#import "PNSendFileStatus.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interfaces declaration

/**
 * @brief \c Send \c file status data object extension to provide access to state setters.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSendFileData (Private)


#pragma mark - Information

/**
 * @brief Whether file uploaded or not.
 *
 * @note This property should be used during error handling to identify whether send file request should be resend or only file message
 * publish.
 */
@property (nonatomic, assign) BOOL fileUploaded;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
