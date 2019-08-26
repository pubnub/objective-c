#import "PNBaseObjectsRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Private \c create / \c update user request extension to provide ability specify data for
 * pre-defined fields.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNManageUserDataRequest : PNBaseObjectsRequest


#pragma mark - Information

/**
 * @brief \c User identifier from external service (database, auth service).
 */
@property (nonatomic, nullable, copy) NSString *externalId;

/**
 * @brief URL at which user's profile available.
 */
@property (nonatomic, nullable, copy) NSString *profileUrl;

/**
 * @brief Additional / complex attributes which should be associated to \c user with specified
 * \c identifier.
 */
@property (nonatomic, nullable, copy) NSDictionary *custom;

/**
 * @brief Email address which should be associated to \c user with specified \c identifier.
 */
@property (nonatomic, nullable, copy) NSString *email;

/**
 * @brief Name which should be associated to \c user with specified \c identifier.
 */
@property (nonatomic, copy) NSString *name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
