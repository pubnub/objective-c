#import <PubNub/PNBaseObjectsRequest.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Remove \c channel \c metadata request.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNRemoveChannelMetadataRequest : PNBaseObjectsRequest


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c remove \c channel \c metadata request.
 *
 * @param channel Name of channel for which \c metadata should be removed.
 *
 * @return Configured and ready to use \c remove \c channel \c metadata request.
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
