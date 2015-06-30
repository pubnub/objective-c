#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNChannelGroupClientStateResult, PNChannelClientStateResult, PNClientStateUpdateStatus,
       PNErrorStatus;

#pragma mark Types

/**
 @brief State modification completion block.
 
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNSetStateCompletionBlock)(PNClientStateUpdateStatus *status);

/**
 @brief  Channel state audition completion block.
 
 @param result Reference on result object which describe service response on channel state audit
               request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNChannelStateCompletionBlock)(PNChannelClientStateResult *result,
                                             PNErrorStatus *status);

/**
 @brief  Channel group state audition completion block.
 
 @param result Reference on result object which describe service response on channel group state 
               audit request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNChannelGroupStateCompletionBlock)(PNChannelGroupClientStateResult *result,
                                                  PNErrorStatus *status);


#pragma mark - API group interface

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
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client setState:@{@"state":@"online"} forUUID:self.client.uuid onChannel:@"chat"
        withCompletion:^(PNClientStateUpdateStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Client state successfully modified on specified channel.
     }
     // Request processing failed.
     else {
     
         // Handle client state modification error. Check 'category' property to find out possible
         // issue because of which request did fail.
         //
         // Request can be resent using: [status retry];
     }
 }];
 @endcode
 
 @param state   Reference on dictionary which should be bound to \c uuid on specified channel.
 @param uuid    Reference on unique user identifier for which state should be bound.
 @param channel Name of the channel which will store provided state information for \c uuid.
 @param block   State modification for user on channel processing completion block which pass only
                one argument - request processing status to report about how data pushing was 
                successful or not.
 
 @since 4.0
 */
- (void)setState:(NSDictionary *)state forUUID:(NSString *)uuid onChannel:(NSString *)channel
  withCompletion:(PNSetStateCompletionBlock)block;

/**
 @brief  Modify state information for \c uuid on specified channel group.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client setState:@{@"announcement":@"New red is blue"} forUUID:self.client.uuid 
        onChannelGroup:@"system" withCompletion:^(PNClientStateUpdateStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Client state successfully modified on specified channel group.
     }
     // Request processing failed.
     else {
     
         // Handle client state modification error. Check 'category' property to find out possible
         // issue because of which request did fail.
         //
         // Request can be resent using: [status retry];
     }
 }];
 @endcode
 
 @param state  Reference on dictionary which should be bound to \c uuid on channel group.
 @param uuid   Reference on unique user identifier for which state should be bound.
 @param group  Name of channel group which will store provided state information for \c uuid.
 @param block  State modification for user on channel processing completion block which pass only
               one argument - request processing status to report about how data pushing was 
               successful or not.
 
 @since 4.0
 */
- (void)setState:(NSDictionary *)state forUUID:(NSString *)uuid onChannelGroup:(NSString *)group
  withCompletion:(PNSetStateCompletionBlock)block;


///------------------------------------------------
/// @name Client state information audit
///------------------------------------------------

/**
 @brief  Retrieve state information for \c uuid on specified channel.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client stateForUUID:self.client.uuid onChannel:@"chat"    
            withCompletion:^(PNChannelClientStateResult *result, PNErrorStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Handle downloaded state information using: result.data.state
     }
     // Request processing failed.
     else {
     
         // Handle client state audit error. Check 'category' property to find out possible
         // issue because of which request did fail.
         //
         // Request can be resent using: [status retry];
     }
 }];
 @endcode

 @param uuid    Reference on unique user identifier for which state should be retrieved.
 @param channel Name of channel from which state information for \c uuid will be pulled out.
 @param block   State audition for user on channel processing completion block which pass two
                arguments: \c result - in case of successful request processing \c data field will
                contain results of client state retrieve operation; \c status - in case if error
                occurred during request processing.
 
 @since 4.0
 */
- (void)stateForUUID:(NSString *)uuid onChannel:(NSString *)channel
      withCompletion:(PNChannelStateCompletionBlock)block;

/**
 @brief  Retrieve state information for \c uuid on specified channel group.
 
 @code
 @endcode
 \b Example:
 
 @code
 // Client configuration.
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client stateForUUID:self.client.uuid onChannelGroup:@"system"
            withCompletion:^(PNChannelGroupClientStateResult *result, PNErrorStatus *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Handle downloaded state information using: result.data.channels 
         // Each channel entry contain state as value.
     }
     // Request processing failed.
     else {
     
         // Handle client state audit error. Check 'category' property to find out possible
         // issue because of which request did fail.
         //
         // Request can be resent using: [status retry];
     }
 }];
 @endcode

 @param uuid  Reference on unique user identifier for which state should be retrieved.
 @param group Name of channel group from which state information for \c uuid will be pulled out.
 @param block State audition for user on channel group processing completion block which pass two
              arguments: \c result - in case of successful request processing \c data field will 
              contain results of client state retrieve operation; \c status - in case if error 
              occurred during request processing.
 
 @since 4.0
 */
- (void)stateForUUID:(NSString *)uuid onChannelGroup:(NSString *)group
      withCompletion:(PNChannelGroupStateCompletionBlock)block;

#pragma mark -


@end
