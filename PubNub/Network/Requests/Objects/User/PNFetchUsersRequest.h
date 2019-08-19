#import "PNObjectsPaginatedRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Fetch \c all \c users request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchUsersRequest : PNObjectsPaginatedRequest


#pragma mark - Information

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNUserFields enum.
 * @note Omit this property if you don't want to retrieve additional attributes.
 */
@property (nonatomic, assign) PNUserFields includeFields;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
