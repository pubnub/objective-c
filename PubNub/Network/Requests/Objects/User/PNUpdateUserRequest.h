#import "PNManageUserDataRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Update \c user request.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNUpdateUserRequest : PNManageUserDataRequest


#pragma mark - Information

/**
 * @brief Bitfield set to fields which should be returned with response.
 *
 * @note Supported keys specified in \b PNUserFields enum.
 * @note Omit this property or set to \c 0 if you don't want to retrieve additional attributes.
 * @note By default set to \b PNSpaceCustomField.
 */
@property (nonatomic, assign) PNUserFields includeFields;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c update \c user request.
 *
 * @param identifier Identifier of \c user which should be updated.
 *
 * @return Configured and ready to use \c update \c user request.
 */
+ (instancetype)requestWithUserID:(NSString *)identifier;

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
