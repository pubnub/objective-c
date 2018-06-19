#import "PNAPICallBuilder.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PNPresenceWhereNowAPICallBuilder, PNPresenceHereNowAPICallBuilder, PNPresenceHeartbeatAPICallBuilder;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Presence API call builder.
 @discussion Class describe interface which provide access to various presence endpoints.
 
 @author Sergey Mamontov
 @since 4.5.4
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNPresenceAPICallBuilder : PNAPICallBuilder


///------------------------------------------------
/// @name Here Now
///------------------------------------------------

/**
 @brief      Stores reference on construction block which return \c builder which is responsible for access to 
             'here now' API.
 @discussion On block call return builder which provide interface to access channel / group 'here now' 
             presence information.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceHereNowAPICallBuilder *(^hereNow)(void);


///------------------------------------------------
/// @name Where Now
///------------------------------------------------

/**
 @brief      Stores reference on construction block which return \c builder which is responsible for access to
             'where now' API.
 @discussion On block call return builder which provide interface to access user's presence information (on 
             which channels \c user subscribed).
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceWhereNowAPICallBuilder *(^whereNow)(void);


///------------------------------------------------
/// @name Connected state
///------------------------------------------------

/**
 * @brief      Stores reference on construction block which return \c builder which is responsible
 *             for access to client's connected presence state management.
 * @discussion On block call return block which consume client's \c connected state flag and
 *             provide interface to access client's connected presence state management.
 * @discussion \b Important: since \b 4.8.0 this API work only if \c managePresenceListManually client configuration property is set to
 *             \c YES.
 *
 * @since 4.7.5
 */
@property (nonatomic, readonly, strong) PNPresenceHeartbeatAPICallBuilder *(^connected)(BOOL connected);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
