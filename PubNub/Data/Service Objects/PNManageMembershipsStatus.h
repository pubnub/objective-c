#import "PNAcknowledgmentStatus.h"
#import "PNServiceData.h"
#import "PNMembership.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interfaces declaration

/**
 * @brief Object which is used to represent Objects API response for \c manage \c memberships
 * request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNManageMembershipsData : PNServiceData


#pragma mark - Information

/**
 * @brief List of updated \c memberships.
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
 * @brief Total number of \c updated \c memberships.
 *
 * @note Value will be \c 0 in case if \c includeCount of \b PNManageMembershipsRequest is set to
 * \c NO.
 */
@property (nonatomic, readonly, assign) NSUInteger totalCount;

#pragma mark -


@end


/**
 * @brief Object which is used to provide access to processed \c manage \c memberships request
 * results.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNManageMembershipsStatus : PNAcknowledgmentStatus


#pragma mark - Information

/**
 * @brief \c Manage \c memberships request processed information.
 */
@property (nonatomic, readonly, strong) PNManageMembershipsData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
