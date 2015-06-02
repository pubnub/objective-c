#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PubNub;


/**
 @brief      Presence heartbeat manager used by client to ping \b PubNub network.
 @discussion Allow to notify service and tell what subscriber still alive and waiting for events 
             from live feed.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PNHeartbeat : NSObject


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Construct and configure heartbeat manager.
 
 @param client Reference on \b PubNub client for which heartbeat manager has been created.
 
 @return Constructed and ready to use heartbeat manager.
 
 @since 4.0
 */
+ (instancetype)heartbeatForClient:(PubNub *)client;


///------------------------------------------------
/// @name State manipulation
///------------------------------------------------

/**
 @brief  If client configured with heartbeat value and interval client will send "heartbeat" 
         notification to \b PubNub service.
 
 @since 4.0
 */
- (void)startHeartbeatIfRequired;

/**
 @brief  In case if there is active heartbeat timer it will be stopped.

 @since 4.0
 */
- (void)stopHeartbeatIfPossible;

#pragma mark -


@end
