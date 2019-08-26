#import "PNServiceData.h"
#import "PNResult.h"
#import "PNSpace.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Objects API response for \c fetch \c space request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchSpaceData : PNServiceData


#pragma mark - Information

/**
 * @brief Requested space object.
 */
@property (nonatomic, nullable, readonly, strong) PNSpace *space;

#pragma mark -


@end


/**
 * @brief Object which is used to represent Objects API response for \c fetch \c all \c spaces
 * request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchSpacesData : PNServiceData


#pragma mark - Information

/**
 * @brief List of space objects created for current subscribe key.
 */
@property (nonatomic, readonly, strong) NSArray<PNSpace *> *spaces;

/**
 * @brief Cursor bookmark for fetching the next page.
 */
@property (nonatomic, nullable, readonly, strong) NSString *next;

/**
 * @brief Cursor bookmark for fetching the previous page.
 */
@property (nonatomic, nullable, readonly, strong) NSString *prev;

/**
 * @brief Total number of spaces created for current subscribe key.
 *
 * @note Value will be \c 0 in case if \c includeCount of \b PNFetchSpacesRequest is set to \c NO.
 */
@property (nonatomic, readonly, assign) NSUInteger totalCount;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to \c fetch \c space request response.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchSpaceResult : PNResult


#pragma mark - Information

/**
 * @brief \c Fetch \c space request processed information.
 */
@property (nonatomic, readonly, strong) PNFetchSpaceData *data;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to \c fetch \c all \c spaces request response.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchSpacesResult : PNResult


#pragma mark - Information

/**
 * @brief \c Fetch \c all \c spaces request processed information.
 */
@property (nonatomic, readonly, strong) PNFetchSpacesData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
