#import "PNObjectsPaginatedRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Update \c user's memberships request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNManageMembershipsRequest : PNObjectsPaginatedRequest


#pragma mark - Information

/**
 * @brief List of \c spaces to which \c user should join.
 *
 * @discussion With this specified, request will update \c user's membership in specified list of
 * \c spaces and associate additional information with \c user in context of specified \c space
 * (if \c custom field is set).
 *
 * @note Each entry is dictionary with \c spaceId and \b optional \c custom fields. \c custom should
 * be dictionary with simple objects: \a NSString and \a NSNumber.
 */
@property (nonatomic, nullable, strong) NSArray<NSDictionary *> *joinSpaces;

/**
 * @brief List of \c spaces for which additional information associated with \c user should be
 * updated.
 *
 * @discussion With this specified, request will update \c user's additional information associated
 * with membership.
 *
 * @note Each entry is dictionary with \c spaceId and \c custom fields. \c custom should be
 * dictionary with simple objects: \a NSString and \a NSNumber.
 */
@property (nonatomic, nullable, strong) NSArray<NSDictionary *> *updateSpaces;

/**
 * @brief List of \c spaces which \c user should leave.
 */
@property (nonatomic, nullable, strong) NSArray<NSString *> *leaveSpaces;

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNMembershipFields enum.
 * @note Omit this property if you don't want to retrieve additional attributes.
 */
@property (nonatomic, assign) PNMembershipFields includeFields;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c manage \c user's memberships request.
 *
 * @param identifier Identifier of \c user for which memberships should be managed.
 *
 * @return Configured and ready to use \c manage \c user's memberships request.
 */
+ (instancetype)requestWithUserID:(NSString *)identifier;

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
