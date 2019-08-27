#import "PNSpace.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c space extension to provide ability to set data from service response.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNSpace (Private)


#pragma mark - Information

/**
 * @brief Additional information about \c space.
 */
@property (nonatomic, nullable, copy) NSString *information;

/**
 * @brief Additional / complex attributes which has been associated with \c space.
 */
@property (nonatomic, nullable, copy) NSDictionary *custom;

/**
 * @brief \c Space creation date.
 */
@property (nonatomic, nullable, copy) NSDate *created;

/**
 * @brief \c Space data modification date.
 */
@property (nonatomic, nullable, copy) NSDate *updated;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c space data model from dictionary.
 *
 * @param data Dictionary with information about \c user from Objects API.
 *
 * @return Configured and ready to use \c space representation model.
 */
+ (instancetype)spaceFromDictionary:(NSDictionary *)data;

/**
 * @brief Create and configure \c space data model.
 *
 * @param identifier Unique \c space identifier.
 * @param name Name which has been associated to \c space with specified \c identifier.
 *
 * @return Configured and ready to use \c space representation model.
 */
+ (instancetype)spaceWithID:(NSString *)identifier name:(NSString *)name;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
