#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Object which is used to represent \c UUID \c metadata.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNUUIDMetadata : NSObject


#pragma mark - Information

/**
 * @brief Additional / complex attributes which should be associated with \c metadata.
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary *custom;

/**
 * @brief Identifier from external service (database, auth service).
 */
@property (nonatomic, nullable, readonly, copy) NSString *externalId;

/**
 * @brief URL at which profile available.
 */
@property (nonatomic, nullable, readonly, copy) NSString *profileUrl;

/**
 * @brief Email address.
 */
@property (nonatomic, nullable, readonly, copy) NSString *email;

/**
 * @brief Last \c metadata update date.
 */
@property (nonatomic, readonly, strong) NSDate *updated;

/**
 * @brief Name which should be stored in \c metadata associated with specified \c uuid.
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 * @brief \c UUID with which \c metadata has been associated.
 */
@property (nonatomic, readonly, copy) NSString *uuid;

/**
 * @brief \c UUID \c metadata object version identifier.
 */
@property (nonatomic, readonly, copy) NSString *eTag;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
