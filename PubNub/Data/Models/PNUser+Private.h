#import "PNUser.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c user extension to provide ability to set data from service response.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNUser (Private)


#pragma mark - Information

/**
 * @brief \c User identifier from external service (database, auth service).
 */
@property (nonatomic, nullable, copy) NSString *externalId;

/**
 * @brief URL at which \c user's profile available.
 */
@property (nonatomic, nullable, copy) NSString *profileUrl;

/**
 * @brief Additional / complex attributes which has been associated with \c user.
 */
@property (nonatomic, nullable, copy) NSDictionary *custom;

/**
 * @brief \c User creation date.
 */
@property (nonatomic, nullable, copy) NSDate *created;

/**
 * @brief \c User data modification date.
 */
@property (nonatomic, nullable, copy) NSDate *updated;

/**
 * @brief Email address which should be associated with \c user.
 */
@property (nonatomic, nullable, copy) NSString *email;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c user data model from dictionary.
 *
 * @param data Dictionary with information about \c user from Objects API.
 *
 * @return Configured and ready to use \c user representation model.
 */
+ (instancetype)userFromDictionary:(NSDictionary *)data;

/**
 * @brief Create and configure \c user data model.
 *
 * @param identifier Unique \c user identifier.
 * @param name Name which has been associated with \c user.
 *
 * @return Configured and ready to use \c user representation model.
 */
+ (instancetype)userWithID:(NSString *)identifier name:(NSString *)name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
