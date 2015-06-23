#import "PNResult.h"
#import "PNServiceData.h"


/**
 @brief  Class which allow to get access to global presence processed result.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNPresenceGlobalHereNowData : PNServiceData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief      Active channels list.
 @discussion Each dictionary key represent channel name and it's value is presence information for 
             it.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSDictionary *channels;

/**
 @brief  Total number of active channels.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *totalChannels;

/**
 @brief  Total number of subscribers.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *totalOccupancy;

#pragma mark -


@end


/**
 @brief  Class which is used to provide access to request processing results.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNPresenceGlobalHereNowResult : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on global presence request processing information.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNPresenceGlobalHereNowData *data;

#pragma mark -


@end
