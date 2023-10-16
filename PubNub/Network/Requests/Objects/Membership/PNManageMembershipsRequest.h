#import <PubNub/PNBaseObjectsMembershipRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Manage \c UUID's memberships request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNManageMembershipsRequest : PNBaseObjectsMembershipRequest


#pragma mark - Information

/**
 * @brief List of \c channels within which \c UUID should be \c set as \c member.
 *
 * @discussion With this specified, request will set \c UUID's membership in specified list of
 * \c channels and associate \c metadata with \c UUID in context of specified \c channel
 * (if \c custom field is set).
 *
 * @note Each entry is dictionary with \c channel and \b optional \c custom fields. \c custom should
 * be dictionary with simple objects: \a NSString and \a NSNumber.
 */
@property (nonatomic, nullable, strong) NSArray<NSDictionary *> *setChannels;

/**
 * @brief List of \c channels from which \c UUID should be removed as \c member.
 */
@property (nonatomic, nullable, strong) NSArray<NSString *> *removeChannels;

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNMembershipFields enum.
 * @note Default value (\B PNMembershipsTotalCountField) can be reset by setting 0.
 */
@property (nonatomic, assign) PNMembershipFields includeFields;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c manage \c UUID's memberships request.
 *
 * @param uuid Identifier for which memberships should be managed.
 * Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 *
 * @return Configured and ready to use \c manage \c UUID's memberships request.
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
