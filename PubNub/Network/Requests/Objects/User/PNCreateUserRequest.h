#import "PNManageUserDataRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Create \c user request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNCreateUserRequest : PNManageUserDataRequest


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c create \c user request.
 *
 * @param identifier Unique identifier for new \c user entry.
 * @param name Name which should be associated with new \c user entry.
 *
 * @return Configured and ready to use \c create \c user request.
 */
+ (instancetype)requestWithUserID:(NSString *)identifier name:(NSString *)name;

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
