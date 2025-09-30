#import <PubNub/PubNub+Core.h>

// Request
#import <PubNub/PNPresenceStateFetchRequest.h>
#import <PubNub/PNPresenceStateSetRequest.h>


// Response
#import <PubNub/PNChannelGroupClientStateResult.h>
#import <PubNub/PNPresenceStateFetchResult.h>
#import <PubNub/PNChannelClientStateResult.h>
#import <PubNub/PNClientStateUpdateStatus.h>
#import <PubNub/PNClientStateGetResult.h>

// Deprecated
#import <PubNub/PNStateModificationAPICallBuilder.h>
#import <PubNub/PNStateAuditAPICallBuilder.h>
#import <PubNub/PNStateAPICallBuilder.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// **PubNub** `Presence State` API.
///
/// A set of APIs which allow fetching and managing presence state associated with a specific user ID in channel(s).
@interface PubNub (State)


#pragma mark - Presence API builder interface (deprecated)

/// State API access builder.
@property (nonatomic, readonly, strong) PNStateAPICallBuilder * (^state)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");


#pragma mark - Client state information manipulation

/// Update presence state associated with user.
///
/// #### Example:
/// ```objc
/// PNPresenceStateSetRequest *request = [PNPresenceStateSetRequest requestWithUserId:self.client.userID];
/// request.state = @{ @"state": @"online" };
/// request.channels = @[@"chat"];
///
/// [self.client setPresenceStateWithRequest:request completion:^(PNClientStateUpdateStatus *status) {
///     if (!status.isError) {
///         // Client state successfully modified on specified channels. State returned here: `response.data.state`.
///     } else {
///         // Handle client state modification error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information required to update presence state associated with user.
///   - block: Presence state update request completion block.
- (void)setPresenceStateWithRequest:(PNPresenceStateSetRequest *)request
                         completion:(nullable PNSetStateCompletionBlock)block
    NS_SWIFT_NAME(setPresenceStateWithRequest(_:completion:));

/// Modify state information for `uuid` on specified remote data object (channel or channel group).
///
/// ### Example:
/// ```objc
/// [self.client setState:@{ @"state": @"online" } 
///               forUUID:self.client.userID
///             onChannel:@"chat"
///        withCompletion:^(PNClientStateUpdateStatus *status) {
///     if (!status.isError) {
///         // Client state successfully modified on specified channels. State returned here: `response.data.state`.
///     } else {
///         // Handle client state modification error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - state: `NSDictionary` with data which should be bound to `uuid` on channel.
///   - uuid: Unique user identifier for which state should be bound.
///   - channel: Name of the channel which will store provided state information for `uuid`.
///   - block: State modification for user on channel completion block.
- (void)setState:(nullable NSDictionary<NSString *, id> *)state
           forUUID:(NSString *)uuid
         onChannel:(NSString *)channel
    withCompletion:(nullable PNSetStateCompletionBlock)block
    NS_SWIFT_NAME(setState(_:forUUID:onChannel:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-setPresenceStateWithRequest:completion:' method instead.");

/// Modify state information for `uuid` on specified channel group.
///
/// #### Example:
/// ```objc
/// [self.client setState:@{ @"announcement": @"New red is blue" }
///               forUUID:self.client.userID
///        onChannelGroup:@"system"
///        withCompletion:^(PNClientStateUpdateStatus *status) {
///     if (!status.isError) {
///         // Client state successfully modified on specified channel group.
///         // State returned here: `response.data.state`.
///     } else {
///         // Handle client state modification error. Check `category` property to find out possible issue because of
///         // which request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - state: `NSDictionary` with data which should be bound to `uuid` on channel group.
///   - uuid: Unique user identifier for which state should be bound.
///   - group: Name of channel group which will store provided state information for `uuid`.
///   - block: State modification for user on channel completion block.
- (void)setState:(nullable NSDictionary<NSString *, id> *)state
           forUUID:(NSString *)uuid
    onChannelGroup:(NSString *)group
    withCompletion:(nullable PNSetStateCompletionBlock)block
    NS_SWIFT_NAME(setState(_:forUUID:onChannelGroup:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-setPresenceStateWithRequest:completion:' method instead.");


#pragma mark - Client state information audit

/// Update presence state associated with user.
///
/// #### Example:
/// ```objc
/// PNFetchPresenceStateRequest *request = [PNPresenceStateFetchRequest requestWithUserId:self.client.userID];
/// request.channels = @[@"chat"];
/// 
/// [self.client fetchPresenceStateWithRequest:request
///                                 completion:^(PNPresenceStateFetchResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle fetched presence state information:
///         // - for single channel: `result.data.state`
///         // - for multuple channels or channel groups: `result.data.channels`.
///     } else {
///         // Handle presence state fetch error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information required to fetch presence state associated with user.
///   - block: Presence state fetch request completion block.
- (void)fetchPresenceStateWithRequest:(PNPresenceStateFetchRequest *)request
                           completion:(PNPresenceStateFetchCompletionBlock)block
    NS_SWIFT_NAME(fetchPresenceStateWithRequest(_:completion:));

/// Retrieve state information for `uuid` on specified channel.
///
/// #### Example:
/// ```objc
/// [self.client stateForUUID:self.client.userID
///                 onChannel:@"chat"
///            withCompletion:^(PNChannelClientStateResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle fetched presence state information using: `result.data.state`.
///     } else {
///         // Handle presence state fetch error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - uuid: Unique user identifier for which state should be retrieved.
///   - channel: Name of channel from which state information for `uuid` will be pulled out.
///   - block: State audition for user on channel completion block.
- (void)stateForUUID:(NSString *)uuid
           onChannel:(NSString *)channel
      withCompletion:(PNChannelStateCompletionBlock)block
    NS_SWIFT_NAME(stateForUUID(_:onChannel:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-fetchPresenceStateWithRequest:completion:' method instead.");

/// Retrieve state information for `uuid` on specified channel group.
///
/// #### Example:
/// ```objc
/// [self.client stateForUUID:self.client.userID 
///            onChannelGroup:@"system"
///            withCompletion:^(PNChannelGroupClientStateResult *result, PNErrorStatus *status) {
///     if (!status.isError) {
///         // Handle downloaded state information using: `result.data.channels`.
///         // Each channel entry contain state as value.
///     } else {
///         // Handle presence state fetch error. Check `category` property to find out possible issue because of which
///         // request did fail.
///     }
/// }];
/// ```
///
/// - Parameters:
///   - uuid: Unique user identifier for which state should be retrieved.
///   - group: Name of channel group from which state information for `uuid` will be pulled out.
///   - block: State audition for user on channel group completion block.
- (void)stateForUUID:(NSString *)uuid
      onChannelGroup:(NSString *)group
      withCompletion:(PNChannelGroupStateCompletionBlock)block
    NS_SWIFT_NAME(stateForUUID(_:onChannelGroup:withCompletion:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since and will be removed with next major update. Please use "
                             "'-fetchPresenceStateWithRequest:completion:' method instead.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
