#import "PNResult.h"
#import "PNServiceData.h"


NS_ASSUME_NONNULL_BEGIN

/**
 @brief  Class which allow to get access to channel presence processed result.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNPresenceChannelHereNowData : PNServiceData


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Active channel subscribers unique identifiers.
 @note   This object can be empty in case if only occupancy has been requested.
 @note   This object can contain list of uuids or dictionary with uuids and client state information
         bound to them.
 
 @since 4.0
 */
@property (nonatomic, nullable, readonly, strong) id uuids;

/**
 @brief  Active subscribers count.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *occupancy;

#pragma mark -


@end


/**
 @brief  Class which is used to provide access to request processing results.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PNPresenceChannelHereNowResult : PNResult


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Stores reference on channel presence request processing information.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) PNPresenceChannelHereNowData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
