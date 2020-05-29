#import "PNBaseObjectsMembershipRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Remove \c UUID's memberships request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNRemoveMembershipsRequest : PNBaseObjectsMembershipRequest


#pragma mark - Information

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNMembershipFields enum.
 */
@property (nonatomic, assign) PNMembershipFields includeFields;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c remove \c UUID's memberships request.
 *
 * @param uuid Identifier for which memberships information should be removed.
 *   Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 * @param channels List of \c channels from which \c UUID should be removed as \c member.
 *
 * @return Configured and ready to use \c remove \c UUID's memberships request.
 */
+ (instancetype)requestWithUUID:(nullable NSString *)uuid channels:(NSArray<NSString *> *)channels;

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
