#import "PNObjectsPaginatedRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Fetch \c UUID memberships request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchMembershipsRequest : PNObjectsPaginatedRequest


#pragma mark - Information

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNMembershipFields enum.
 */
@property (nonatomic, assign) PNMembershipFields includeFields;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c fetch \c UUID's memberships request.
 *
 * @param uuid Identifier for which memberships in \c channels should be fetched.
 * Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 *
 * @return Configured and ready to use \c fetch \c UUID's memberships request.
 */
+ (instancetype)requestWithUUID:(nullable NSString *)uuid;

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
