#import "PNManageSpaceDataRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Update \c space request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNUpdateSpaceRequest : PNManageSpaceDataRequest


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c update \c space request.
 *
 * @param identifier Identifier of \c space which should be updated.
 *
 * @return Configured and ready to use \c update \c space request.
 */
+ (instancetype)requestWithSpaceID:(NSString *)identifier;

/**
 * @brief Forbids request initialization.
 *
 * @throws Interface not available exception and requirement to use provided constructor method.
 *
 * @return Initialized request.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
