#import "PNObjectsPaginatedRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Update \c space's members.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNManageMembersRequest : PNObjectsPaginatedRequest


#pragma mark - Information

/**
 * @brief List of \c users which should be added to \c space's members list.
 *
 * @discussion With this specified, request will update \c spaces's members list by addition of
 * specified list of \c users and associate additional information with \c user in context of
 * \c space (if \c custom field is set).
 *
 * @note Each entry is dictionary with \c userId and \b optional \c custom fields. \c custom should
 * be dictionary with simple objects: \a NSString and \a NSNumber.
 */
@property (nonatomic, nullable, strong) NSArray<NSDictionary *> *addMembers;

/**
 * @brief List of \c users for which additional information associated with each of them in context
 * of \c space should be updated.
 *
 * @discussion With this specified, request will update \c user's additional information associated
 * with him in context of \c space.
 *
 * @note Each entry is dictionary with \c userId and \c custom fields. \c custom should be
 * dictionary with simple objects: \a NSString and \a NSNumber.
 */
@property (nonatomic, nullable, strong) NSArray<NSDictionary *> *updateMembers;

/**
 * @brief List of \c users which should be removed from \c members list.
 */
@property (nonatomic, nullable, strong) NSArray<NSString *> *removeMembers;

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNMemberFields enum.
 * @note Omit this property if you don't want to retrieve additional attributes.
 */
@property (nonatomic, assign) PNMemberFields includeFields;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c manage \c space's members request.
 *
 * @param identifier Identifier of \c space for which members list should be updated.
 *
 * @return Configured and ready to use \c manage \c space's members request.
 */
+ (instancetype)requestWithSpaceID:(NSString *)identifier;

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
