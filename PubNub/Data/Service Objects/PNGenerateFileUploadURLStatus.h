#import "PNAcknowledgmentStatus.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Files API response for \c upload \c file \c URL
 * request.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNGenerateFileUploadURLData : PNServiceData


#pragma mark - Information

/**
 * @brief List of form-fields which should be prepended to user data in request body.
 *
 * @note \c multipart/form-data Content-Type will be set in case if any fields is present in array.
 */
@property (nonatomic, nullable, readonly, strong) NSArray<NSDictionary *> *formFields;

/**
 * @brief Unique file identifier.
 */
@property (nonatomic, nullable, readonly, strong) NSString *fileIdentifier;

/**
 * @brief HTTP method which should be used during file upload request.
 */
@property (nonatomic, nullable, readonly, strong) NSString *httpMethod;

/**
 * @brief Name which will be used to store user data on server.
 */
@property (nonatomic, nullable, readonly, strong) NSString *filename;

/**
 * @brief URL which should be used to upload user data.
 */
@property (nonatomic, nullable, readonly, strong) NSURL *requestURL;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c upload \c file \c URL request
 * results.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNGenerateFileUploadURLStatus : PNAcknowledgmentStatus


#pragma mark - Information

/**
 * @brief \c Fetch \c members request processed information.
 */
@property (nonatomic, readonly, strong) PNGenerateFileUploadURLData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
