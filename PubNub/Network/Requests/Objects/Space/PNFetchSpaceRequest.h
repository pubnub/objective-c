#import "PNBaseObjectsRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Fetch \c space request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchSpaceRequest : PNBaseObjectsRequest


#pragma mark - Information

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNSpaceFields enum.
 * @note Omit this property if you don't want to retrieve additional attributes.
 */
@property (nonatomic, assign) PNSpaceFields includeFields;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c fetch \c space request.
 *
 * @param identifier Identifier of \c space which should be fetched.
 *
 * @return Configured and ready to use \c fetch \c space request.
 */
+ (instancetype)requestWithSpaceID:(NSString *)identifier;

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
