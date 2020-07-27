#import "PNBasePublishRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/**
 * @brief \c Publish \c message request.
 *
 * @author Serhii Mamontov
 * @version 4.15.0
 * @since 4.15.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNPublishRequest : PNBasePublishRequest


#pragma mark - Information

/**
 * @brief Whether message should be replicated across the PubNub Real-Time Network and sent simultaneously to all subscribed
 * clients on a channel.
 */
@property (nonatomic, assign, getter = shouldReplicate) BOOL replicate;

/**
 * @brief Whether message should be compressed before sending or not.
 */
@property (nonatomic, assign, getter = shouldCompress) BOOL compress;

/**
 * @brief Dictionary with payloads for different vendors (Apple with "apns" key and Google with "gcm").
 */
@property (nonatomic, nullable, strong) NSDictionary *payloads;


#pragma mark - Initialization & Configuration

/**
 * @brief Create and configure \c publish \c message  request.
 *
 * @param channel Name of channel to which message should be published.
 *
 * @return Configured and ready to use \c publish \c message request.
 */
+ (instancetype)requestWithChannel:(NSString *)channel;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
