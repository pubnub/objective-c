#import <Foundation/Foundation.h>
#import "PNStateModificationAPICallBuilder.h"
#import "PNStateAuditAPICallBuilder.h"
#import "PNStateAPICallBuilder.h"
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNChannelGroupClientStateResult, PNChannelClientStateResult, PNClientStateUpdateStatus,
       PNErrorStatus;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - API group interface

/**
 @brief      \b PubNub client core class extension to provide access to 'state' API group.
 @discussion Set of API which allow to fetch events which has been moved from remote data object live feed to 
             persistent storage.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PubNub (State)


///------------------------------------------------
/// @name API Builder support
///------------------------------------------------

/**
 @brief      Stores reference on presence state API access \c builder construction block.
 @discussion On block call return builder which allow to configure parameters for presence state API access.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNStateAPICallBuilder *(^state)(void);


///------------------------------------------------
/// @name Client state information manipulation
///------------------------------------------------

/**
 @brief      Modify state information for \c uuid on specified remote data object (channel or channel group).
 @discussion \b Example:
 
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
 @param block   State modification for user on channel processing completion block which pass only one 
                argument - request processing status to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)setState:(nullable NSDictionary<NSString *, id> *)state forUUID:(NSString *)uuid 
       onChannel:(NSString *)channel withCompletion:(nullable PNSetStateCompletionBlock)block NS_SWIFT_NAME(setState(_:forUUID:onChannel:withCompletion:));

/**
 @brief      Modify state information for \c uuid on specified channel group.
 @discussion \b Example:
 
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
 @param block  State modification for user on channel processing completion block which pass only one 
               argument - request processing status to report about how data pushing was successful or not.
 
 @since 4.0
 */
- (void)setState:(nullable NSDictionary<NSString *, id> *)state forUUID:(NSString *)uuid
  onChannelGroup:(NSString *)group withCompletion:(nullable PNSetStateCompletionBlock)block NS_SWIFT_NAME(setState(_:forUUID:onChannelGroup:withCompletion:));


///------------------------------------------------
/// @name Client state information audit
///------------------------------------------------

/**
 @brief      Retrieve state information for \c uuid on specified channel.
 @discussion \b Example:
 
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
 @param block   State audition for user on channel processing completion block which pass two arguments: 
                \c result - in case of successful request processing \c data field will contain results of 
                client state retrieve operation; \c status - in case if error occurred during request 
                processing.
 
 @since 4.0
 */
- (void)stateForUUID:(NSString *)uuid onChannel:(NSString *)channel
      withCompletion:(PNChannelStateCompletionBlock)block NS_SWIFT_NAME(stateForUUID(_:onChannel:withCompletion:));

/**
 @brief      Retrieve state information for \c uuid on specified channel group.
 @discussion \b Example:
 
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
 @param block State audition for user on channel group processing completion block which pass two arguments:
              \c result - in case of successful request processing \c data field will contain results of 
              client state retrieve operation; \c status - in case if error  occurred during request 
              processing.
 
 @since 4.0
 */
- (void)stateForUUID:(NSString *)uuid onChannelGroup:(NSString *)group
      withCompletion:(PNChannelGroupStateCompletionBlock)block NS_SWIFT_NAME(stateForUUID(_:onChannelGroup:withCompletion:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
