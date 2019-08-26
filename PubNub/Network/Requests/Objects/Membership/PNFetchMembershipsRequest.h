#import "PNObjectsPaginatedRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Fetch \c user's memberships request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNFetchMembershipsRequest : PNObjectsPaginatedRequest


#pragma mark - Information

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNMembershipFields enum.
 * @note Omit this property if you don't want to retrieve additional attributes.
 */
@property (nonatomic, assign) PNMembershipFields includeFields;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c fetch \c user's memberships request.
 *
 * @param identifier Identifier of \c user for which memberships in \c spaces should be fetched.
 *
 * @return Configured and ready to use \c fetch \c user's memberships request.
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
