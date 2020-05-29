#import "PNBaseObjectsMembershipRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Manage \c channel's members request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNManageMembersRequest : PNBaseObjectsMembershipRequest


#pragma mark - Information

/**
 * @brief List of \c UUIDs which should be added to \c channel's \c members list.
 *
 * @discussion With this specified, request will update \c channel's members list by addition of
 * specified list of \c UUIDs and associate \c metadata with \c UUID in context of \c channel
 * (if \c custom field is set).
 *
 * @note Each entry is dictionary with \c uuid and \b optional \c custom fields. \c custom should
 * be dictionary with simple objects: \a NSString and \a NSNumber.
 */
@property (nonatomic, nullable, strong) NSArray<NSDictionary *> *setMembers;

/**
 * @brief List of \c UUIDs which should be removed from \c channel's list.
 */
@property (nonatomic, nullable, strong) NSArray<NSString *> *removeMembers;

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNMemberFields enum.
 */
@property (nonatomic, assign) PNMemberFields includeFields;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c manage \c channel's members request.
 *
 * @param channel Name of channel for which members list should be updated.
 *
 * @return Configured and ready to use \c manage \c channel's members request.
 */
+ (instancetype)requestWithChannel:(NSString *)channel;

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
