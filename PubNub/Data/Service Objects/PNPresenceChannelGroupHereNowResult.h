#import "PNPresenceGlobalHereNowResult.h"


/**
 * @brief Class which allow to get access to channel groups presence processed result.
 *
 * @author Serhii Mamontov
 * @version 4.15.8
 * @since 4.0.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNPresenceChannelGroupHereNowData : PNPresenceGlobalHereNowData


#pragma mark -


@end


/**
 * @brief Class which is used to provide access to request processing results.
 *
 * @author Serhii Mamontov
 * @version 4.15.8
 * @since 4.0.0
 * @copyright © 2010-2020 PubNub, Inc.
 */
@interface PNPresenceChannelGroupHereNowResult : PNResult


#pragma mark - Information

/**
 * @brief Stores reference on channel group presence request processing information.
 */
@property (nonatomic, nonnull, readonly, strong) PNPresenceChannelGroupHereNowData *data;


#pragma mark -


@end
