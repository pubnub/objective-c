#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


/**
 @brief      \b PubNub client core class extension to provide access to 'state' API group.
 @discussion Set of API which allow to fetch events which has been moved from remote data object
             live feed to persistent storage.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@interface PubNub (State)


///------------------------------------------------
/// @name Client state information manipulation
///------------------------------------------------

/**
 @brief  Modify state information for \c uuid on specified remote data object (channel or channel
         group).
 
 @param state   Reference on dictionary which should be bound to \c uuid on specified channel.
 @param uuid    Reference on unique user identifier for which state should be bound.
 @param channel Name of the channel which will store provided state information for \c uuid.
 @param block   State modification for user on cahnnel processing completion block which pass two 
                arguments: \c result - in case of successful request processing \c data field will 
                contain results of client state update operation; \c status - in case if error 
                occurred during request processing.
 
 @since 4.0
 */
- (void)setState:(NSDictionary *)state forUUID:(NSString *)uuid onChannel:(NSString *)channel
  withCompletion:(PNCompletionBlock)block;

/**
 @brief  Modify state information for \c uuid on specified channel group.
 
 @param state  Reference on dictionary which should be bound to \c uuid on channel group.
 @param uuid   Reference on unique user identifier for which state should be bound.
 @param group  Name of channel group which will store provided state information for \c uuid.
 @param block  State modification for user on cahnnel group processing completion block which pass 
               two arguments: \c result - in case of successful request processing \c data field 
               will contain results of client state update operation; \c status - in case if error
               occurred during request processing.
 
 @since 4.0
 */
- (void)setState:(NSDictionary *)state forUUID:(NSString *)uuid onChannelGroup:(NSString *)group
  withCompletion:(PNCompletionBlock)block;


///------------------------------------------------
/// @name Client state information audit
///------------------------------------------------

/**
 @brief  Retrieve state information for \c uuid on specified channel.

 @param uuid    Reference on unique user identifier for which state should be retrieved.
 @param channel Name of channel from which state information for \c uuid will be pulled out.
 @param block   State audition for user on cahnnel processing completion block which pass two
                arguments: \c result - in case of successful request processing \c data field will
                contain results of client state retrieve operation; \c status - in case if error
                occurred during request processing.
 
 @since 4.0
 */
- (void)stateForUUID:(NSString *)uuid onChannel:(NSString *)channel
      withCompletion:(PNCompletionBlock)block;

/**
 @brief  Retrieve state information for \c uuid on specified channel group.

 @param uuid  Reference on unique user identifier for which state should be retrieved.
 @param group Name of channel group from which state information for \c uuid will be pulled out.
 @param block State audition for user on cahnnel group processing completion block which pass two 
              arguments: \c result - in case of successful request processing \c data field will 
              contain results of client state retrieve operation; \c status - in case if error 
              occurred during request processing.
 
 @since 4.0
 */
- (void)stateForUUID:(NSString *)uuid onChannelGroup:(NSString *)group
      withCompletion:(PNCompletionBlock)block;

#pragma mark -

@end
