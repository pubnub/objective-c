#import <PubNub/PNServiceData.h>
#import <PubNub/PNOperationResult.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Files API response for \c download \c file request.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNDownloadFileData : PNServiceData


#pragma mark - Information

/**
 * @brief Whether file is temporary or not.
 *
 * @warning Temporary file will be removed as soon as completion block will exit. Make sure to move temporary files (w/o scheduling
 * task on secondary thread) to persistent location.
 */
@property (nonatomic, readonly, assign, getter = isTemporary) BOOL temporary;

/**
 * @brief Location where downloaded file can be found.
 */
@property (nonatomic, readonly, nullable, readonly, strong) NSURL *location;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c download \c file request results.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNDownloadFileResult : PNOperationResult


#pragma mark - Information

/**
 * @brief \c Download \c file request processed information.
 */
@property (nonatomic, readonly, strong) PNDownloadFileData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
