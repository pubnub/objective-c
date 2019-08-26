#import "PNMembership.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c membership extension to provide ability to set data from service response.
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.10.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNMembership (Private)


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c membership data model from dictionary.
 *
 * @param data Dictionary with information about \c membership from Objects API.
 *
 * @return Configured and ready to use \c space membership model.
 */
+ (instancetype)membershipFromDictionary:(NSDictionary *)data;

/**
 * @brief Create and configure \c membership data model.
 *
 * @param identifier Identifier of \c space with which \c user has membership.
 * @param space \c Space with which \c user has membership.
 *
 * @return Configured and ready to use \c membership representation model.
 */
+ (instancetype)membershipWithSpaceId:(NSString *)identifier space:(nullable PNSpace *)space;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
