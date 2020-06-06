#import "PNAcknowledgmentStatus.h"
#import "PNServiceData.h"
#import "PNMembership.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Objects API response for \c memberships
 * \c set / \c remove / \c manage request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNManageMembershipsData : PNServiceData


#pragma mark - Information

/**
 * @brief List of existing \c memberships.
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
 * @brief Total number of existing objects.
 *
 * @note Value will be \c 0 in case if \b PNMembershipsTotalCountField not added to \c includeFields
 * of \b PNSetMembershipsRequest / \b PNRemoveMembershipsRequest / \b PNManageMembershipsRequest or
 * \b PNFetchMembershipsRequest.
 */
@property (nonatomic, readonly, assign) NSUInteger totalCount;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c memberships
 * \c set / \c remove / \c manage request
 * results.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNManageMembershipsStatus : PNAcknowledgmentStatus


#pragma mark - Information

/**
 * @brief \c Memberships \c set / \c remove / \c manage request processed information.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
