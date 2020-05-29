#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief Object which is used to represent \c channel \c metadata.
 *
 * @author Serhii Mamontov
 * @version 4.14.0
 * @since 4.14.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNChannelMetadata : NSObject


#pragma mark - Information

/**
 * @brief Additional / complex attributes which should be stored in \c metadata associated with
 * specified \c channel.
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary *custom;

/**
 * @brief Description which should be stored in \c metadata associated with specified \c channel.
 */
@property (nonatomic, nullable, readonly, copy) NSString *information;

/**
 * @brief Name which should be stored in \c metadata associated with specified \c channel.
 */
@property (nonatomic, nullable, readonly, copy) NSString *name;

/**
 * @brief \c Channel name with which \c metadata has been associated.
 */
@property (nonatomic, readonly, copy) NSString *channel;

/**
 * @brief Last \c metadata update date.
 */
@property (nonatomic, readonly, strong) NSDate *updated;

/**
 * @brief \c Channel \c metadata object version identifier.
 */
@property (nonatomic, readonly, copy) NSString *eTag;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
