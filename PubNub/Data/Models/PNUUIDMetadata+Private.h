#import "PNUUIDMetadata.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c UUID \c metadata extension to provide ability to set data from service
 * response.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNUUIDMetadata (Private)


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
 * @brief Last \c metadata update date.
 */
@property (nonatomic, nullable, strong) NSDate *updated;

/**
 * @brief Email address.
 */
@property (nonatomic, nullable, copy) NSString *email;

/**
 * @brief Name which should be stored in \c metadata associated with specified \c uuid.
 */
@property (nonatomic, nullable, copy) NSString *name;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c UUID \c metadata data model from dictionary.
 *
 * @param data Dictionary with information about \c UUID \c metadata from Objects API.
 *
 * @return Configured and ready to use \c UUID \c metadata representation model.
 */
+ (instancetype)uuidMetadataFromDictionary:(NSDictionary *)data;

/**
 * @brief Create and configure \c UUID \c metadata data model.
 *
 * @param uuid Identifier with which \c metadata associated.
 *
 * @return Configured and ready to use \c UUID \c metadata representation model.
 */
+ (instancetype)metadataForUUID:(NSString *)uuid;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
