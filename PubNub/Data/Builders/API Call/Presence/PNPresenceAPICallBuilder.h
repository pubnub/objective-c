#import "PNAPICallBuilder.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PNPresenceWhereNowAPICallBuilder, PNPresenceHereNowAPICallBuilder, PNPresenceHeartbeatAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Presence API call builder.
 *
 * @author Serhii Mamontov
 * @since 4.5.4
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNPresenceAPICallBuilder : PNAPICallBuilder


#pragma mark - Here Now

/**
 * @brief 'Here now' presence API access builder block.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceHereNowAPICallBuilder * (^hereNow)(void);


#pragma mark - Where Now

/**
 * @brief 'Where now' presence API access builder block.
 *
 * @return API call configuration builder.
 *
 * @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceWhereNowAPICallBuilder * (^whereNow)(void);


#pragma mark - Connected state

/**
 * @brief Client's connected presence state management API access builder block.
 *
 * @note Since \b 4.8.0 this API work only if \c managePresenceListManually client configuration
 * property is set to \c YES.
 *
 * @param connected Whether client should be set as connected / disconnected on set of channels
 *     specified with builder or not.
 *
 * @since 4.7.5
 */
@property (nonatomic, readonly, strong) PNPresenceHeartbeatAPICallBuilder * (^connected)(BOOL connected);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
