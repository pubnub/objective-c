#import <PubNub/PubNub+Core.h>

// Request
#import <PubNub/PNPresenceHeartbeatRequest.h>
#import <PubNub/PNPresenceWhereNowResult.h>
#import <PubNub/PNWhereNowRequest.h>
#import <PubNub/PNHereNowRequest.h>

// Response
#import <PubNub/PNPresenceChannelGroupHereNowResult.h>
#import <PubNub/PNPresenceChannelHereNowResult.h>
#import <PubNub/PNPresenceGlobalHereNowResult.h>
#import <PubNub/PNPresenceHereNowResult.h>

// Deprecated
#import <PubNub/PNPresenceChannelGroupHereNowAPICallBuilder.h>
#import <PubNub/PNPresenceChannelHereNowAPICallBuilder.h>
#import <PubNub/PNPresenceHeartbeatAPICallBuilder.h>
#import <PubNub/PNPresenceWhereNowAPICallBuilder.h>
#import <PubNub/PNPresenceHereNowAPICallBuilder.h>
#import <PubNub/PNPresenceAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// **PubNub** `Presence` APIs.
///
/// Set of APIs which allow retrieving information about channels and user presence and perform heartbeat requests to
/// let PubNub service know what client still present.
@interface PubNub (Presence)


#pragma mark - Presence API builder interdace (deprecated)

/// Presence API access builder.
@property (nonatomic, readonly, strong) PNPresenceAPICallBuilder * (^presence)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");


#pragma mark - Channel and Channel Groups presence


/// Retrieve channels and groups presence information.
///
/// Depending from used request it is possible to retrieve global or presence on channels / channel groups.
///
/// #### Examples:
/// ##### Global presence:
/// ```objc
/// PNHereNowRequest *request = [PNHereNowRequest requestGlobal];
/// [self.client hereNowWithRequest:request completion:^(PNPresenceHereNowResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded presence information using:
///         //   `result.data.channels` - dictionary with active channels and presence information on each. Each channel
///         //                          will have next fields: `uuids` - list of subscribers; `occupancy` - number of
///         //                          active subscribers.
///         //                          Each uuids entry has next fields: `uuid` - identifier and `state` if it has been
///         //                          provided.
///         //   `result.data.totalChannels` - total number of active channels.
///         //   `result.data.totalOccupancy` - total number of active subscribers.
///     } else {
///         // Handle presence audit error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// ##### Channels presence:
/// ```objc
/// PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[@"test-channel-a", @"test-channel-b"]];
/// [self.client hereNowWithRequest:request completion:^(PNPresenceHereNowResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded presence information using:
///         //   `result.data.channels` - dictionary with active channels and presence information on each. Each channel
///         //                            will have next fields: `uuids` - list of subscribers; `occupancy` - number of
///         //                            active subscribers.
///         //                            Each uuids entry has next fields: `uuid` - identifier and `state` if it has
///         //                            been provided.
///         //   `result.data.totalChannels` - total number of active channels.
///         //   `result.data.totalOccupancy` - total number of active subscribers.
///     } else {
///         // Handle presence audit error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// ##### Channel groups presence:
/// ```objc
/// PNHereNowRequest *request = [PNHereNowRequest requestForChannelGroups:@[@"channel-group-a", @"channel-group-b"]];
/// [self.client hereNowWithRequest:request completion:^(PNPresenceHereNowResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded presence information using:
///         //   `result.data.channels` - dictionary with active channels and presence information on each. Each channel
///         //                            will have next fields: `uuids` - list of subscribers; `occupancy` - number of
///         //                            active subscribers.
///         //                            Each uuids entry has next fields: `uuid` - identifier and `state` if it has 
///         //                            been provided.
///         //   `result.data.totalChannels` - total number of active channels.
///         //   `result.data.totalOccupancy` - total number of active subscribers.
///     } else {
///         // Handle presence audit error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information required to retrieve presence information.
///   - block: Channel / channel group presence retrieved request completion block.
- (void)hereNowWithRequest:(PNHereNowRequest *)request completion:(PNHereNowCompletionBlock)block
    NS_SWIFT_NAME(hereNowWithRequest(_:completion:));


#pragma mark - Global here now

/// Request information about subscribers on all remote data objects live feeds.
///
/// This is application wide request for all remote data objects which is registered under publish and subscribe keys
/// used for client configuration.
///
/// > Note: This API will retrieve only list of UUIDs along with their state for each remote data object and number of
/// subscribers in total for objects and overall.
///
/// #### Example:
/// ```objc
/// [self.client hereNowWithCompletion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded presence information using:
///         //   `result.data.channels` - dictionary with active channels and presence information on each. Each channel
///         //                            will have next fields: `uuids` - list of subscribers; `occupancy` - number of
///         //                            active subscribers.
///         //                            Each uuids entry has next fields: `uuid` - identifier and `state` if it has
///         //                            been provided.
///         //   `result.data.totalChannels` - total number of active channels.
///         //   `result.data.totalOccupancy` - total number of active subscribers.
///     } else {
///         // Handle presence audit error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameter block: Here now fetch completion block.
- (void)hereNowWithCompletion:(PNGlobalHereNowCompletionBlock)block
    NS_SWIFT_NAME(hereNowWithCompletion(_:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-hereNowWithRequest:completion:' method instead.");

/// Request information about subscribers on all remote data objects live feeds.
///
/// This is application wide request for all remote data objects which is registered under publish and subscribe keys
/// used for client configuration.
///
/// #### Example:
/// ```objc
/// [self.client hereNowWithVerbosity:PNHereNowState
///                      completion:^(PNPresenceGlobalHereNowResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded presence information using:
///         //   `result.data.channels` - dictionary with active channels and presence information on each. Each channel
///         //                            will have next fields: `uuids` - list of subscribers; `occupancy` - number of
///         //                            active subscribers.
///         //                            Each uuids entry has next fields: `uuid` - identifier and `state` if it has
///         //                            been provided.
///         //   `result.data.totalChannels` - total number of active channels.
///         //   `result.data.totalOccupancy` - total number of active subscribers.
///     } else {
///         // Handle presence audit error. Check `category` property to find out possible issue because of which 
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - level: One of **PNHereNowVerbosityLevel** fields to instruct what exactly data it expected in response.
///   - block: Here now fetch completion block.
- (void)hereNowWithVerbosity:(PNHereNowVerbosityLevel)level
                  completion:(PNGlobalHereNowCompletionBlock)block
    NS_SWIFT_NAME(hereNowWithVerbosity(_:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-hereNowWithRequest:completion:' method instead.");


#pragma mark - Channel here now

/// Request information about subscribers on specific channel live feeds.
///
/// > Note: This API will retrieve only list of UUIDs along with their state for each remote data object and number of
/// subscribers in total for objects and overall.
///
/// #### Example:
/// ```objc
/// [self.client hereNowForChannel:@"pubnub"
///                 withCompletion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded presence information using:
///         //   `result.data.uuids` - dictionary with active subscriber. Each entry will have next fields:
///         //                         `uuid` - identifier and `state` if it has been provided.
///         //   `result.data.occupancy` - total number of active subscribers.
///     } else {
///         // Handle presence audit error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Channel for which here now information should be received.
///   - block: Here now fetch completion block.
- (void)hereNowForChannel:(NSString *)channel withCompletion:(PNChannelHereNowCompletionBlock)block
    NS_SWIFT_NAME(hereNowForChannel(_:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-hereNowWithRequest:completion:' method instead.");

/// Request information about subscribers on specific channel live feeds.
///
/// #### Example:
/// ```objc
/// [self.client hereNowForChannel:@"pubnub"
///                  withVerbosity:PNHereNowState
///                     completion:^(PNPresenceChannelHereNowResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded presence information using:
///         //   `result.data.uuids` - dictionary with active subscriber. Each entry will have next fields:
///         //                         `uuid` - identifier and `state` if it has been provided.
///         //   `result.data.occupancy` - total number of active subscribers.
///     } else {
///         // Handle presence audit error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - channel: Channel for which here now information should be received.
///   - level: One of **PNHereNowVerbosityLevel** fields to instruct what exactly data it expected in response.
///   - block: Here now fetch completion block.
- (void)hereNowForChannel:(NSString *)channel
            withVerbosity:(PNHereNowVerbosityLevel)level
               completion:(PNChannelHereNowCompletionBlock)block
    NS_SWIFT_NAME(hereNowForChannel(_:withVerbosity:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-hereNowWithRequest:completion:' method instead.");


#pragma mark - Channel group here now

/// Request information about subscribers on specific channel group live feeds.
///
/// > Note: This API will retrieve only list of UUIDs along with their state for each remote data object and number of
/// subscribers in total for objects and overall.
///
/// #### Example:
/// ```objc
/// [self.client hereNowForChannelGroup:@"developers"
///                      withCompletion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded presence information using:
///         //   `result.data.channels` - dictionary with active channels and presence information on each. Each channel
///         //                            will have next fields: `uuids` - list of subscribers; `occupancy` - number of
///         //                            active subscribers.
///         //                            Each uuids entry has next fields: `uuid` - identifier and `state` if it has
///         //                             been provided.
///         //   `result.data.totalChannels` - total number of active channels.
///         //   `result.data.totalOccupancy` - total number of active subscribers.
///     } else {
///         // Handle presence audit error. Check `category` property to find out possible issue because of which 
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - group: Channel group name for which here now information should be received.
///   - block: Here now fetch completion block.
- (void)hereNowForChannelGroup:(NSString *)group withCompletion:(PNChannelGroupHereNowCompletionBlock)block
    NS_SWIFT_NAME(hereNowForChannelGroup(_:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-hereNowWithRequest:completion:' method instead.");

/// Request information about subscribers on specific channel group live feeds.
///
/// #### Example:
/// ```objc
/// [self.client hereNowForChannelGroup:@"developers" 
///                       withVerbosity:PNHereNowState
///                          completion:^(PNPresenceChannelGroupHereNowResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded presence information using:
///         //   `result.data.channels` - dictionary with active channels and presence information on each. Each channel
///         //                            will have next fields: `uuids` - list of subscribers; `occupancy` - number of
///         //                            active subscribers.
///         //                            Each uuids entry has next fields: `uuid` - identifier and `state` if it has
///         //                            been provided.
///         //   `result.data.totalChannels` - total number of active channels.
///         //   `result.data.totalOccupancy` - total number of active subscribers.
///     } else {
///         // Handle presence audit error. Check `category` property to find out possible issue because of which 
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - group: Channel group for which here now information should be received.
///   - level: One of **PNHereNowVerbosityLevel** fields to instruct what exactly data it expected in response.
///   - block: Here now fetch completion block.
- (void)hereNowForChannelGroup:(NSString *)group
                 withVerbosity:(PNHereNowVerbosityLevel)level
                    completion:(PNChannelGroupHereNowCompletionBlock)block
    NS_SWIFT_NAME(hereNowForChannelGroup(_:withVerbosity:completion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-hereNowWithRequest:completion:' method instead.");


#pragma mark - Client where now


/// Retrieve user presence information.
///
/// #### Example:
/// ```objc
/// PNWhereNowRequest *request = [PNWhereNowRequest requestForUserId:@"Steve"];
/// [self.client whereNowWithRequest:request completion:^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle fetched `where now` information using: `result.data.channels`
///     } else {
///         // Handle fetch `where now` error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information required to retrieve user's presence information.
///   - block: User presence retrieved request completion block.
- (void)whereNowWithRequest:(PNWhereNowRequest *)request completion:(PNWhereNowCompletionBlock)block
    NS_SWIFT_NAME(whereNowWithRequest(_:completion:));

/// Request information about remote data object live feeds on which client with specified UUID subscribed at this
/// moment.
///
/// #### Example:
/// ```objc
/// [self.client whereNowUUID:@"Steve" withCompletion:^(PNPresenceWhereNowResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded presence `where now` information using: `result.data.channels`
///     } else {
///         // Handle presence audit error. Check `category` property to find out possible issue because of which
///         // request did fail.
///         //
///         // Request can be resent using: `[status retry];`.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - uuid: UUID for which request should be performed.
///   - block: Where now fetch completion block.
- (void)whereNowUUID:(NSString *)uuid withCompletion:(PNWhereNowCompletionBlock)block
    NS_SWIFT_NAME(whereNowUUID(_:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-whereNowWithRequest:completion:' method instead.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
