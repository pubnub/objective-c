#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Object which is used to represent \c user.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNUser : NSObject


#pragma mark - Information

/**
 * @brief \c User identifier from external service (database, auth service).
 */
@property (nonatomic, nullable, readonly, copy) NSString *externalId;

/**
 * @brief URL at which \c user's profile available.
 */
@property (nonatomic, nullable, readonly, copy) NSString *profileUrl;

/**
 * @brief Additional / complex attributes which has been associated with \c user.
 */
@property (nonatomic, nullable, readonly, copy) NSDictionary *custom;

/**
 * @brief Email address which should be associated with \c user.
 */
@property (nonatomic, nullable, readonly, copy) NSString *email;

/**
 * @brief \c User identifier.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 * @brief \c User creation date.
 */
@property (nonatomic, readonly, copy) NSDate *created;

/**
 * @brief \c User data modification date.
 */
@property (nonatomic, readonly, copy) NSDate *updated;

/**
 * @brief Name which has been associated with \c user.
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 * @brief \c User object version identifier.
 */
@property (nonatomic, readonly, copy) NSString *eTag;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
