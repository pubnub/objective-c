#import "PNMembership.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c membership extension to provide ability to set data from service response.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNMembership (Private)


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c membership data model from dictionary.
 *
 * @param data Dictionary with information about \c membership from Objects API.
 *
 * @return Configured and ready to use \c membership data model.
 */
+ (instancetype)membershipFromDictionary:(NSDictionary *)data;

/**
 * @brief Create and configure \c membership data model.
 *
 * @param metadata \c Metadata which associated with \c UUID in context of \c channel.
 *
 * @return Configured and ready to use \c membership representation model.
 */
+ (instancetype)membershipWithChannelMetadata:(PNChannelMetadata *)metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
