#import "PNBaseObjectsMembershipRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Remove \c channel's members request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNRemoveMembersRequest : PNBaseObjectsMembershipRequest


#pragma mark - Information

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNMemberFields enum.
 */
@property (nonatomic, assign) PNMemberFields includeFields;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c remove \c channel's members request.
 *
 * @param channel Name of channel from which members should be removed.
 * @param uuids List of \c UUIDs which should be removed from \c channel's list.
 *
 * @return Configured and ready to use \c remove \c channel's members request.
 */
+ (instancetype)requestWithChannel:(NSString *)channel uuids:(NSArray<NSString *> *)uuids;

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
