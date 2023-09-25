#import <PubNub/PNBaseObjectsRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Remove \c UUID \c metadata request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNRemoveUUIDMetadataRequest : PNBaseObjectsRequest


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c remove \c UUID \c metadata request.
 *
 * @param uuid Identifier for which \c metadata should be removed.
 * Will be set to current \b PubNub configuration \c uuid if \a nil is set.
 *
 * @return Configured and ready to use \c remove \c UUID \c metadata request.
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
