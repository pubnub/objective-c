#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


#pragma mark API group protocols

/**
 @brief      Protocol which describe client state update status data object structure.
 @discussion Contain information about final state which has been applied or error information.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNSetStateData <PNErrorStatusData>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  User-provided client state information.
 
 @return Client state which has been used during subscription process or using 'set state' API.
 
 @since 4.0
 */
- (NSDictionary *)state;

@end


/**
 @brief      Protocol which describe client state audit on channel result data object structure.
 @discussion Contain information about client state which has been assigned to the channel.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNChannelStateData <PNSetStateData>

@end


/**
 @brief      Protocol which describe client state audit on channel group result data object 
             structure.
 @discussion Contain information about client state which has been assigned to the channel group.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNChannelGroupStateData <PNChannelStateData>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Multi channel client state information.
 @note   In case if status object represent error, this property may contain list of channels to 
         which client doesn't have access.
 
 @return Return dictionary which contains name of the channels as keys and their state stored as
         value.
 
 @since 4.0
 */
- (id)channels;

@end


/**
 @brief      Protocol which describe object returned from channel state audit API.
 @discussion This method allow to provide access to structured response data field.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNChannelStateResult <PNResult>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Reference on service response data casted to required type.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNChannelStateData> *data;

@end


/**
 @brief      Protocol which describe object returned from channel group state audit API.
 @discussion This method allow to provide access to structured response data field.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNChannelGroupStateResult <PNResult>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Reference on service response data casted to required type.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNChannelGroupStateData> *data;

@end


/**
 @brief  Protocol which describe operation processing status object with typed with \c data field
         with corresponding data type.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNChannelStateStatus <PNStatus>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Reference on service response data casted to required type.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNChannelStateData> *data;

@end


/**
 @brief  Protocol which describe operation processing status object with typed with \c data field
         with corresponding data type.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNChannelGroupStateStatus <PNStatus>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Reference on service response data casted to required type.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNChannelGroupStateData> *data;

@end


/**
 @brief  Protocol which describe operation processing status object with typed with \c data field
         with corresponding data type.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNSetStateStatus <PNStatus>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Reference on service response data casted to required type.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNSetStateData> *data;

@end


#pragma mark - Types

/**
 @brief State modification completion block.
 
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNSetStateCompletionBlock)(PNStatus<PNSetStateStatus> *status);

/**
 @brief  Channel state audition completion block.
 
 @param result Reference on result object which describe service response on channel state audit
               request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNChannelStateCompletionBlock)(PNResult<PNChannelStateResult> *result,
                                             PNStatus<PNChannelStateStatus> *status);

/**
 @brief  Channel group state audition completion block.
 
 @param result Reference on result object which describe service response on channel group state 
               audit request.
 @param status Reference on status instance which hold information about processing results.
 
 @since 4.0
 */
typedef void(^PNChannelGroupStateCompletionBlock)(PNResult<PNChannelGroupStateResult> *result,
                                                  PNStatus<PNChannelGroupStateStatus> *status);


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
        withCompletion:^(PNStatus<PNSetStateStatus> *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Client state successfully modified on specified channel.
     }
     // Request processing failed.
     else {
     
         // Handle client state modification error. Check 'category' property to find out possible
         // issue because of which request did fail.
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param state   Reference on dictionary which should be bound to \c uuid on specified channel.
 @param uuid    Reference on unique user identifier for which state should be bound.
 @param channel Name of the channel which will store provided state information for \c uuid.
 @param block   State modification for user on cahnnel processing completion block which pass only 
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
        onChannelGroup:@"system" withCompletion:^(PNStatus<PNSetStateStatus> *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Client state successfully modified on specified channel group.
     }
     // Request processing failed.
     else {
     
         // Handle client state modification error. Check 'category' property to find out possible
         // issue because of which request did fail.
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode
 
 @param state  Reference on dictionary which should be bound to \c uuid on channel group.
 @param uuid   Reference on unique user identifier for which state should be bound.
 @param group  Name of channel group which will store provided state information for \c uuid.
 @param block  State modification for user on cahnnel processing completion block which pass only
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
            withCompletion:^(PNResult<PNChannelStateResult> *result, 
                             PNStatus<PNChannelStateStatus> *status) {
 
     // Check whether request successfully completed or not.
     if (!status.isError) {
         
         // Handle downloaded state information using: result.data.state
     }
     // Request processing failed.
     else {
     
         // Handle client state audit error. Check 'category' property to find out possible
         // issue because of which request did fail.
         //
         // Request can be resend using: [status retry];
     }
 }];
 @endcode

 @param uuid    Reference on unique user identifier for which state should be retrieved.
 @param channel Name of channel from which state information for \c uuid will be pulled out.
 @param block   State audition for user on cahnnel processing completion block which pass two
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
            withCompletion:^(PNResult<PNChannelStateResult> *result, 
                             PNStatus<PNChannelStateStatus> *status) {
 
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
         // Request can be resend using: [status retry];
     }
 }];
 @endcode

 @param uuid  Reference on unique user identifier for which state should be retrieved.
 @param group Name of channel group from which state information for \c uuid will be pulled out.
 @param block State audition for user on cahnnel group processing completion block which pass two 
              arguments: \c result - in case of successful request processing \c data field will 
              contain results of client state retrieve operation; \c status - in case if error 
              occurred during request processing.
 
 @since 4.0
 */
- (void)stateForUUID:(NSString *)uuid onChannelGroup:(NSString *)group
      withCompletion:(PNChannelGroupStateCompletionBlock)block;

#pragma mark -


@end
