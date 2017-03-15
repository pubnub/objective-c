#import <Foundation/Foundation.h>
#import "PNPresenceChannelGroupHereNowAPICallBuilder.h"
#import "PNPresenceChannelHereNowAPICallBuilder.h"
#import "PNPresenceWhereNowAPICallBuilder.h"
#import "PNPresenceHereNowAPICallBuilder.h"
#import "PNPresenceAPICallBuilder.h"
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNPresenceChannelGroupHereNowResult, PNPresenceChannelHereNowResult,
       PNPresenceGlobalHereNowResult, PNPresenceWhereNowResult, PNErrorStatus;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - API group interface
/**
 @brief      \b PubNub client core class extension to provide access to 'presence' API group.
 @discussion Set of API which allow to retrieve information about subscriber(s) on remote data object live 
             feeds and perform heartbeat requests to let \b PubNub service know what client still interested 
             in updates from feed.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
@interface PubNub (Presence)


///------------------------------------------------
/// @name API Builder support
///------------------------------------------------

/**
 @brief      Stores reference on presence API access \c builder construction block.
 @discussion On block call return builder which allow to configure parameters for presence API access.
 
 @since 4.5.4
 */
@property (nonatomic, readonly, strong) PNPresenceAPICallBuilder *(^presence)(void);


///------------------------------------------------
/// @name Global here now
///------------------------------------------------

/**
 @brief      Request information about subscribers on all remote data objects live feeds.
 @discussion This is application wide request for all remote data objects which is registered under publish 
             and subscribe keys used for client configuration.
 @note       This API will retrieve only list of UUIDs along with their state for each remote data object and 
             number of subscribers in total for objects and overall.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client hereNowWithCompletion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded presence information using:
       //   result.data.channels - dictionary with active channels and presence information on 
       //                          each. Each channel will have next fields: "uuids" - list of
       //                          subscribers; occupancy - number of active subscribers.
       //                          Each uuids entry has next fields: "uuid" - identifier and 
       //                          "state" if it has been provided.
       //   result.data.totalChannels - total number of active channels.
       //   result.data.totalOccupancy - total number of active subscribers.
    }
    // Request processing failed.
    else {
    
       // Handle presence audit error. Check 'category' property to find out possible issue because
       // of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param block Here now processing completion block which pass two arguments: \c result - in case of successful
              request processing \c data field will contain results of here now operation; \c status - in case
              if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowWithCompletion:(PNGlobalHereNowCompletionBlock)block NS_SWIFT_NAME(hereNowWithCompletion(_:));

/**
 @brief      Request information about subscribers on all remote data objects live feeds.
 @discussion This is application wide request for all remote data objects which is registered under publish 
             and subscribe keys used for client configuration.
 @discussion Extension to \c -hereNowWithCompletion: and allow to specify here now data which should be
             returned by \b PubNub service.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client hereNowWithVerbosity:PNHereNowState
                       completion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded presence information using:
       //   result.data.channels - dictionary with active channels and presence information on 
       //                          each. Each channel will have next fields: "uuids" - list of
       //                          subscribers; "occupancy" - number of active subscribers.
       //                          Each uuids entry has next fields: "uuid" - identifier and 
       //                          "state" if it has been provided.
       //   result.data.totalChannels - total number of active channels.
       //   result.data.totalOccupancy - total number of active subscribers.
    }
    // Request processing failed.
    else {
    
       // Handle presence audit error. Check 'category' property to find out possible issue because
       // of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param level  Reference on one of \b PNHereNowVerbosityLevel fields to instruct what exactly data it expected
               in response.
 @param block  Here now processing completion block which pass two arguments: \c result - in case of 
               successful request processing \c data field will contain results of here now operation; 
               \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowWithVerbosity:(PNHereNowVerbosityLevel)level completion:(PNGlobalHereNowCompletionBlock)block NS_SWIFT_NAME(hereNowWithVerbosity(_:completion:));


///------------------------------------------------
/// @name Channel here now
///------------------------------------------------

/**
 @brief      Request information about subscribers on specific channel live feeds.
 @note       This API will retrieve only list of UUIDs along with their state for each remote data object and 
             number of subscribers in total for objects and overall. 
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client hereNowForChannel:@"pubnub" withCompletion:^(PNPresenceChannelHereNowResult *result,
                                                          PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded presence information using:
       //   result.data.uuids - dictionary with active subscriber. Each entry will have next 
       //                       fields: "uuid" - identifier and "state" if it has been provided.
       //   result.data.occupancy - total number of active subscribers.
    }
    // Request processing failed.
    else {
    
       // Handle presence audit error. Check 'category' property to find out possible issue because
       // of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param channel Reference on channel for which here now information should be received (\b Required). Error 
                status will rerurn if \c nil passed.
 @param block   Here now processing completion block which pass two arguments: \c result - in case of 
                successful request processing \c data field will contain results of here now operation; 
                \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowForChannel:(NSString *)channel withCompletion:(PNHereNowCompletionBlock)block NS_SWIFT_NAME(hereNowForChannel(_:withCompletion:));

/**
 @brief      Request information about subscribers on specific channel live feeds.
 @discussion Extension to \c -hereNowForChannel:withCompletion: and allow to specify here now data which
             should be returned by \b PubNub service.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client hereNowForChannel:@"pubnub"  withVerbosity:PNHereNowState
                    completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded presence information using:
       //   result.data.uuids - dictionary with active subscriber. Each entry will have next 
       //                       fields: "uuid" - identifier and "state" if it has been provided.
       //   result.data.occupancy - total number of active subscribers.
    }
    // Request processing failed.
    else {
    
       // Handle presence audit error. Check 'category' property to find out possible issue because
       // of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param channel Reference on channel for which here now information should be received (\b Required). Error 
                status will rerurn if \c nil passed.
 @param level   Reference on one of \b PNHereNowVerbosityLevel fields to instruct what exactly data it 
                expected in response.
 @param block   Here now processing completion block which pass two arguments: \c result - in case of
                successful request processing \c data field will contain results of here now operation; 
                \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowForChannel:(NSString *)channel withVerbosity:(PNHereNowVerbosityLevel)level
               completion:(PNHereNowCompletionBlock)block NS_SWIFT_NAME(hereNowForChannel(_:withVerbosity:completion:));


///------------------------------------------------
/// @name Channel group here now
///------------------------------------------------

/**
 @brief      Request information about subscribers on specific channel group live feeds.
 @note       This API will retrieve only list of UUIDs along with their state for each remote data object and 
             number of subscribers in total for objects and overall.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client hereNowForChannelGroup:@"developers" 
                     withCompletion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded presence information using:
       //   result.data.channels - dictionary with active channels and presence information on 
       //                          each. Each channel will have next fields: "uuids" - list of
       //                          subscribers; occupancy - number of active subscribers.
       //                          Each uuids entry has next fields: "uuid" - identifier and 
       //                          "state" if it has been provided.
       //   result.data.totalChannels - total number of active channels.
       //   result.data.totalOccupancy - total number of active subscribers.
    }
    // Request processing failed.
    else {
    
       // Handle presence audit error. Check 'category' property to find out possible issue because
       // of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param group Reference on channel group name for which here now information should be received. 
              (\b Required). Error status will rerurn if \c nil passed.
 @param block Here now processing completion block which pass two arguments: \c result - in case of successful
              request processing \c data field will contain results of here now operation; \c status - in case
              if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowForChannelGroup:(NSString *)group withCompletion:(PNChannelGroupHereNowCompletionBlock)block NS_SWIFT_NAME(hereNowForChannelGroup(_:withCompletion:));

/**
 @brief      Request information about subscribers on specific channel group live feeds.
 @discussion Extension to \c -hereNowForChannelGroup:withCompletion: and allow to specify here now data which 
             should be returned by \b PubNub service.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client hereNowForChannelGroup:@"developers" withVerbosity:PNHereNowState
                         completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded presence information using:
       //   result.data.channels - dictionary with active channels and presence information on 
       //                          each. Each channel will have next fields: "uuids" - list of
       //                          subscribers; occupancy - number of active subscribers.
       //                          Each uuids entry has next fields: "uuid" - identifier and 
       //                          "state" if it has been provided.
       //   result.data.totalChannels - total number of active channels.
       //   result.data.totalOccupancy - total number of active subscribers.
    }
    // Request processing failed.
    else {
    
       // Handle presence audit error. Check 'category' property to find out possible issue because
       // of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param group Reference on channel group for which here now information should be received (\b Required).
              Error status will rerurn if \c nil passed.
 @param level Reference on one of \b PNHereNowVerbosityLevel fields to instruct what exactly data it expected 
              in response.
 @param block Here now processing completion block which pass two arguments: \c result - in case of successful
              request processing \c data field will contain results of here now operation; \c status - in case
              if error occurred during request processing.
 
 @since 4.0
 */
- (void)hereNowForChannelGroup:(NSString *)group withVerbosity:(PNHereNowVerbosityLevel)level
                    completion:(PNChannelGroupHereNowCompletionBlock)block NS_SWIFT_NAME(hereNowForChannelGroup(_:withVerbosity:completion:));


///------------------------------------------------
/// @name Client where now
///------------------------------------------------

/**
 @brief      Request information about remote data object live feeds on which client with specified UUID
             subscribed at this moment.
 @discussion \b Example:
 
 @code
// Client configuration.
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client whereNowUUID:@"Steve" withCompletion:^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {

    // Check whether request successfully completed or not.
    if (!status.isError) {

       // Handle downloaded presence 'where now' information using: result.data.channels
    }
    // Request processing failed.
    else {
    
       // Handle presence audit error. Check 'category' property to find out possible issue because
       // of which request did fail.
       //
       // Request can be resent using: [status retry];
    }
}];
 @endcode
 
 @param uuid  Reference on UUID for which request should be performed.
 @param block Where now processing completion block which pass two arguments: \c result - in case of
              successful request processing \c data field will contain results of where now operation;
              \c status - in case if error occurred during request processing.
 
 @since 4.0
 */
- (void)whereNowUUID:(NSString *)uuid withCompletion:(PNWhereNowCompletionBlock)block NS_SWIFT_NAME(whereNowUUID(_:withCompletion:));

#pragma mark -


@end

NS_ASSUME_NONNULL_END
