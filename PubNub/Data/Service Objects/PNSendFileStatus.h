#import "PNAcknowledgmentStatus.h"
#import "PNServiceData.h"
#import "PNFile.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to provide access to additional data available to describe \c file \c upload status.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSendFileData : PNServiceData


#pragma mark - Information

/**
 * @brief Unique identifier which has been assigned to file during upload.
 */
@property (nonatomic, nullable, readonly, strong) NSString *fileIdentifier;

/**
 * @brief Name under which uploaded data has been stored.
 */
@property (nonatomic, nullable, readonly, strong) NSString *fileName;

/**
 * @brief Whether file uploaded or not.
 *
 * @note This property should be used during error handling to identify whether send file request should be resend or only file message
 * publish.
 */
@property (nonatomic, readonly, assign) BOOL fileUploaded;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c send \c file request.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSendFileStatus : PNAcknowledgmentStatus


#pragma mark - Information

/**
 * @brief \c Send \c file request processed information.
 */
@property (nonatomic, readonly, strong) PNSendFileData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
