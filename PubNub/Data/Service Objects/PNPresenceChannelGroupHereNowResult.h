#import "PNPresenceGlobalHereNowResult.h"


/**
 @brief  Class which allow to get access to channel groups presence processed result.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNPresenceChannelGroupHereNowData : PNPresenceGlobalHereNowData


#pragma mark -


@end


/**
 @brief  Class which is used to provide access to request processing results.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PNPresenceChannelGroupHereNowResult : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on channel group presence request processing information.
 
 @since 4.0
 */
@property (nonatomic, nonnull, readonly, strong) PNPresenceChannelGroupHereNowData *data;


#pragma mark -


@end
