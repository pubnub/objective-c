#import <PubNub/PNServiceData.h>
#import <PubNub/PNOperationResult.h>
#import <PubNub/PNChannelMetadata.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Objects API response for \c fetch \c channel
 * \c metadata request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchChannelMetadataData : PNServiceData


#pragma mark - Information

/**
 * @brief Requested \c channel \c metadata object.
 */
@property (nonatomic, nullable, readonly, strong) PNChannelMetadata *metadata;

#pragma mark -


@end


/**
 * @brief Object which is used to represent Objects API response for \c fetch \c all \c channels
 * \c metadata request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchAllChannelsMetadataData : PNServiceData


#pragma mark - Information

/**
 * @brief List of \c channels \c metadata objects created for current subscribe key.
 */
@property (nonatomic, readonly, strong) NSArray<PNChannelMetadata *> *metadata;

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
 * @note Value will be \c 0 in case if \b PNChannelTotalCountField not added to \c includeFields
 * of \b PNFetchAllChannelsMetadataRequest.
 */
@property (nonatomic, readonly, assign) NSUInteger totalCount;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to \c fetch \c channel \c metadata request
 * response.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchChannelMetadataResult : PNOperationResult


#pragma mark - Information

/**
 * @brief \c Fetch \c channel \c metadata request processed information.
 */
@property (nonatomic, readonly, strong) PNFetchChannelMetadataData *data;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to \c fetch \c all \c channels \c metadata request
 * response.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchAllChannelsMetadataResult : PNOperationResult


#pragma mark - Information

/**
 * @brief \c Fetch \c all \c channels \c metadata request processed information.
 */
@property (nonatomic, readonly, strong) PNFetchAllChannelsMetadataData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
