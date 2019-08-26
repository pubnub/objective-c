#import "PNBaseObjectsRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Delete \c space request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNDeleteSpaceRequest : PNBaseObjectsRequest


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c delete \c space request.
 *
 * @param identifier Identifier of \c space which should be removed.
 *
 * @return Configured and ready to use \c delete \c space request.
 */
+ (instancetype)requestWithSpaceID:(NSString *)identifier;

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
