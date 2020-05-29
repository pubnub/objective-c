#import "PNBaseObjectsRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Set \c UUID \c metadata request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSetUUIDMetadataRequest : PNBaseObjectsRequest


#pragma mark - Information

/**
 * @brief Additional / complex attributes which should be associated with \c metadata.
 */
@property (nonatomic, nullable, strong) NSDictionary *custom;

/**
 * @brief Identifier from external service (database, auth service).
 */
@property (nonatomic, nullable, copy) NSString *externalId;

/**
 * @brief URL at which profile available.
 */
@property (nonatomic, nullable, copy) NSString *profileUrl;

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNUUIDFields enum.
 * @note Default value (\b PNUUIDCustomField ) can be reset by setting \c 0.
 */
@property (nonatomic, assign) PNUUIDFields includeFields;

/**
 * @brief Email address.
 */
@property (nonatomic, nullable, copy) NSString *email;

/**
 * @brief Name which should be stored in \c metadata associated with specified \c identifier.
 */
@property (nonatomic, nullable, copy) NSString *name;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c set \c UUID \c metadata request.
 *
 * @param uuid Identifier with which \c metadata is linked.
 * Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 *
 * @return Configured and ready to use \c set \c UUID \c metadata request.
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
