#import "PNObjectsPaginatedRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Fetch \c channel's members request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNFetchMembersRequest : PNObjectsPaginatedRequest


#pragma mark - Information

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNMemberFields enum.
 */
@property (nonatomic, assign) PNMemberFields includeFields;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c fetch \c channel's members request.
 *
 * @param channel Name of channel for which members list should be fetched.
 *
 * @return Configured and ready to use \c fetch \c channel's members request.
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
