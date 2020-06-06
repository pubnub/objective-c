#import "PNChannelMember.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c member extension to provide ability to set data from service response.
 *
 * @author Serhii Mamontov
 * @version 4.14.1
 * @since 4.14.1
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNChannelMember (Private)


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c member data model from dictionary.
 *
 * @param data Dictionary with information about \c member from Objects API.
 *
 * @return Configured and ready to use \c member model.
 */
+ (instancetype)memberFromDictionary:(NSDictionary *)data;

/**
 * @brief Create and configure \c member data model.
 *
 * @param metadata \c Metadata which associated with specified \c UUID in context of \c channel.
 *
 * @return Configured and ready to use \c member representation model.
 */
+ (instancetype)memberWithUUIDMetadata:(PNUUIDMetadata *)metadata;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
