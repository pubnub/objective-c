#import "PNStructures.h"
#import "PNRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c File \c upload \c URL request.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNGenerateFileUploadURLRequest : PNRequest


#pragma mark - Information

/**
 * @brief Arbitrary percent encoded query parameters which should be sent along with original API call.
 */
@property (nonatomic, nullable, strong) NSDictionary *arbitraryQueryParameters;

/**
 * @brief Name which should be used to store uploaded data.
 */
@property (nonatomic, copy) NSString *filename;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c upload \c data \c URL \c generation request.
 *
 * @param channel Name of channel to which \c data should be uploaded.
 * @param name File name which will be used to store uploaded \c data.
 *
 * @return Configured and ready to use \c upload \c data \c URL \c generation request.
 */
+ (instancetype)requestWithChannel:(NSString *)channel filename:(NSString *)name;

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
