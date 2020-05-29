#import "PNBaseObjectsRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Fetch \c UUID \c metadata request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchUUIDMetadataRequest : PNBaseObjectsRequest


#pragma mark - Information

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNUUIDFields enum.
 * @note Default value (\b PNUUIDCustomField) can be reset by setting 0.
 */
@property (nonatomic, assign) PNUUIDFields includeFields;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c fetch \c UUID \c metadata request.
 *
 * @param uuid Identifier for \c metadata should be fetched.
 * Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 *
 * @return Configured and ready to use \c fetch \c UUID \c metadata request.
 */
+ (instancetype)requestWithUUID:(nullable NSString *)uuid;

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
