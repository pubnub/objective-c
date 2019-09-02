#import "PNBaseMessageActionRequest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/**
 * @brief Private \c base request extension to provide access to initializer.
 *
 * @author Serhii Mamontov
 * @version 4.11.0
 * @since 4.11.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNBaseMessageActionRequest (Private)


#pragma mark - Information

/**
 * @brief Name of channel in which target \c message is stored.
 */
@property (nonatomic, readonly, copy) NSString *channel;

/**
 * @brief Timetoken (\b PubNub's high precision timestamp) of \c message for which \c action should
 * be managed.
 */
@property (nonatomic, readonly, strong) NSNumber *messageTimetoken;


#pragma mark - Initialization & Configuration

/**
 * @brief Initialize \c base request.
 *
 * @param channel Name of channel in which target \c message is stored.
 * @param messageTimetoken Timetoken of \c message for which action should be managed.
 *
 * @return Initialized and ready to use \c request.
 */
- (instancetype)initWithChannel:(NSString *)channel messageTimetoken:(NSNumber *)messageTimetoken;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
