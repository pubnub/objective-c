#import "PNServiceData.h"
#import "PNMembership.h"
#import "PNResult.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Objects API response for \c fetch \c memberships
 * request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchMembershipsData : PNServiceData


#pragma mark - Information

/**
 * @brief List of fetched \c memberships.
 */
@property (nonatomic, readonly, strong) NSArray<PNMembership *> *memberships;

/**
 * @brief Cursor bookmark for fetching the next page.
 */
@property (nonatomic, nullable, readonly, strong) NSString *next;

/**
 * @brief Cursor bookmark for fetching the previous page.
 */
@property (nonatomic, nullable, readonly, strong) NSString *prev;

/**
 * @brief Total number of \c memberships in which \c user participate.
 *
 * @note Value will be \c 0 in case if \c includeCount of \b PNFetchMembershipsRequest is set to
 * \c NO.
 */
@property (nonatomic, readonly, assign) NSUInteger totalCount;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c fetch \c memberships request
 * results.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchMembershipsResult : PNResult


#pragma mark - Information

/**
 * @brief \c Fetch \c memberships request processed information.
 */
@property (nonatomic, readonly, strong) PNFetchMembershipsData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
