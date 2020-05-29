#import "PNBaseObjectsMembershipRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Set \c UUID's memberships request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNSetMembershipsRequest : PNBaseObjectsMembershipRequest


#pragma mark - Information

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNMembershipFields enum.
 */
@property (nonatomic, assign) PNMembershipFields includeFields;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c set \c UUID's memberships request.
 *
 * @discussion Request will set \c UUID's \c metadata associated with membership.
 *
 * @param uuid Identifier for which memberships \c metadata should be set.
 *     Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 * @param channels List of \c channels for which \c metadata associated with \c UUID should be set.
 *     Each entry is dictionary with \c channel and \b optional \c custom fields. \c custom should
 *     be dictionary with simple objects: \a NSString and \a NSNumber.
 *
 * @return Configured and ready to use \c set \c UUID's memberships request.
 */
+ (instancetype)requestWithUUID:(nullable NSString *)uuid
                       channels:(NSArray<NSDictionary *> *)channels;

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
