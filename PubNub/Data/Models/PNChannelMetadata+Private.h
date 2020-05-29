#import "PNChannelMetadata.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c channel \c metadata extension to provide ability to set data from service
 * response.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNChannelMetadata (Private)


#pragma mark - Information

/**
 * @brief Description which should be stored in \c metadata associated with specified \c channel.
 */
@property (nonatomic, nullable, copy) NSString *information;

/**
 * @brief Additional / complex attributes which should be stored in \c metadata associated with
 * specified \c channel.
 */
@property (nonatomic, nullable, strong) NSDictionary *custom;

/**
 * @brief Last \c metadata update date.
 */
@property (nonatomic, nullable, strong) NSDate *updated;

/**
 * @brief Name which should be stored in \c metadata associated with specified \c channel.
 */
@property (nonatomic, nullable, copy) NSString *name;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c channel \c metadata data model from dictionary.
 *
 * @param data Dictionary with information about \c channel \c metadata from Objects API.
 *
 * @return Configured and ready to use \c channel \c metadata representation model.
 */
+ (instancetype)channelMetadataFromDictionary:(NSDictionary *)data;

/**
 * @brief Create and configure \c channel \c metadata data model.
 *
 * @param channel Name of channel with which \c metadata associated.
 *
 * @return Configured and ready to use \c channel \c metadata representation model.
 */
+ (instancetype)metadataForChannel:(NSString *)channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
