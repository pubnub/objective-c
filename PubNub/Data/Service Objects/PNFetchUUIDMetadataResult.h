#import "PNUUIDMetadata.h"
#import "PNServiceData.h"
#import "PNResult.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Objects API response for \c fetch \c UUID \c metadata
 * request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchUUIDMetadataData : PNServiceData


#pragma mark - Information

/**
 * @brief Requested \c UUID \c metadata object.
 */
@property (nonatomic, nullable, readonly, strong) PNUUIDMetadata *metadata;

#pragma mark -


@end

/**
 * @brief Object which is used to represent Objects API response for \c fetch \c all \c UUID
 * \c metadata request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchAllUUIDMetadataData : PNServiceData


#pragma mark - Information

/**
 * @brief List of \c UUIDs \c metadata objects created for current subscribe key.
 */
@property (nonatomic, readonly, strong) NSArray<PNUUIDMetadata *> *metadata;

/**
 * @brief Cursor bookmark for fetching the next page.
 */
@property (nonatomic, nullable, readonly, strong) NSString *next;

/**
 * @brief Cursor bookmark for fetching the previous page.
 */
@property (nonatomic, nullable, readonly, strong) NSString *prev;

/**
 * @brief Total number of objects created for current subscribe key.
 *
 * @note Value will be \c 0 in case if \b PNUUIDTotalCountField not added to \c includeFields
 * of \b PNFetchAllUUIDMetadataRequest.
 */
@property (nonatomic, readonly, assign) NSUInteger totalCount;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to \c fetch \c UUID \c metadata request response.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchUUIDMetadataResult : PNResult


#pragma mark - Information

/**
 * @brief \c Fetch \c UUID \c metadata request processed information.
 */
@property (nonatomic, readonly, strong) PNFetchUUIDMetadataData *data;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to \c fetch \c all \c UUIDs \c metadata request
 * response.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchAllUUIDMetadataResult : PNResult


#pragma mark - Information

/**
 * @brief \c Fetch \c all \c UUIDs \c metadata request processed information.
 */
@property (nonatomic, readonly, strong) PNFetchAllUUIDMetadataData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
