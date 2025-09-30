#import <PubNub/PubNub+Core.h>

#import <PubNub/PNPresenceLeaveRequest.h>
#import <PubNub/PNPresenceEventResult.h>
#import <PubNub/PNMessageActionResult.h>
#import <PubNub/PNObjectEventResult.h>
#import <PubNub/PNSubscribeRequest.h>
#import <PubNub/PNSubscribeStatus.h>
#import <PubNub/PNFileEventResult.h>
#import <PubNub/PNEventsListener.h>
#import <PubNub/PNMessageResult.h>
#import <PubNub/PNSignalResult.h>

// Deprecated
#import <PubNub/PNUnsubscribeChannelsOrGroupsAPICallBuilder.h>
#import <PubNub/PNSubscribeChannelsOrGroupsAPIBuilder.h>
#import <PubNub/PNUnsubscribeAPICallBuilder.h>
#import <PubNub/PNSubscribeAPIBuilder.h>


#pragma mark Class forward

@class PNSubscribeStatus;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Interface implementation

/// **PubNub** `Subscribe` APIs.
///
/// Set of API which allow to push data to **PubNub** service. Data pushed to remote data objects  called `channels` and
/// then delivered on their live feeds to all subscribers.
@interface PubNub (Subscribe)


#pragma mark - Information

/// Retrieve list of channels on which client subscribed now.
///
///- Returns: `NSArray` of channel names on which client subscribed at this moment.
- (NSArray<NSString *> *)channels;

/// Retrieve list of channel groups on which client subscribed now.
/// 
/// - Returns: `NSArray` of channel group names on which client subscribed at this moment.
- (NSArray<NSString *> *)channelGroups;

/// List of channels for which presence events observation has been enabled.
///
/// - Returns: `NSArray` of presence channel names on which client subscribed at this moment.
- (NSArray<NSString *> *)presenceChannels;

/// Check whether **PubNub** client currently subscribed on specified data object or not.
///
/// - Parameter name: Name of data object against which check should be performed.
/// - Returns: Whether subscribed on specified data object or not.
- (BOOL)isSubscribedOn:(NSString *)name;


#pragma mark - Listeners

/// Add observer which conform to ``PNEventsListener`` protocol and would like to receive updates based on live feed
/// events and status change.
///
/// Listener can implement only required callbacks from ``PNEventsListener`` protocol and called only when desired type
/// of event arrive.
///
/// - Parameter listener: Listener which would like to receive updates.
- (void)addListener:(id<PNEventsListener>)listener NS_SWIFT_NAME(addListener(_:));

/// Remove listener from list for callback calls.
///
/// When listener not interested in live feed updates it can remove itself from updates list using this method.
///
/// - Parameter listener: Listener which doesn't want to receive updates anymore.
- (void)removeListener:(id<PNEventsListener>)listener NS_SWIFT_NAME(removeListener(_:));


#pragma mark - Filtering

/// String representation of filtering expression which should be applied to decide which updates should reach client.
///
/// > Warning: If your filter expression is malformed, ``PNEventsListener`` won't receive any messages and presence
/// events from service (only error status).
@property (nonatomic, nullable, copy) NSString *filterExpression;


#pragma mark - API Builder support

/// Subscribe API access builder.
///
/// > Note: Since **4.8.0** if `managePresenceListManually` client configuration property is set to `YES` this API won't
/// add channels and / or channel groups to presence heartbeat list.
@property (nonatomic, readonly, strong) PNSubscribeAPIBuilder * (^subscribe)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");

/// Unsubscribe API access builder.
@property (nonatomic, readonly, strong) PNUnsubscribeAPICallBuilder * (^unsubscribe)(void)
    DEPRECATED_MSG_ATTRIBUTE("Builder-based interface deprecated. Please use corresponding request-based interfaces.");


#pragma mark - Subscription

/// Subscribe to specified resources.
///
/// #### Examples:
/// ##### Subscribe on regular channels and groups:
/// ```objc
/// PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[@"channel-a"] channelGroups:nil];
/// request.observePresence = YES;
/// request.timetoken = @(1234567890);
///
/// [self.client subscribeWithRequest:request];
/// ```
///
/// ##### Subscribe on presence channels and groups:
/// ```objc
/// // This request will subscribe on presence events from `group-a-pnpres` group.
/// PNSubscribeRequest *request = [PNSubscribeRequest requestWithPresenceChannels:nil channelGroups:@[@"group-a"]];
/// request.timetoken = @(1234567890);
///
/// [self.client subscribeWithRequest:request];
/// ```
///
/// - Parameter request: Request with information about resources from which client will receive real-time updates.
- (void)subscribeWithRequest:(PNSubscribeRequest *)request NS_SWIFT_NAME(subscribeWithRequest(_:));

/// Try subscribe on specified set of channels.
///
/// Client is able to subscribe of remote data objects live feed and listen for new events from them.
///
/// > Note: Since **4.8.0** if `managePresenceListManually` client configuration property is set to `YES` this API won't
/// add channels to presence heartbeat list.
///
/// #### Example:
/// ```objc
/// [self.client subscribeToChannels:@[@"swift"] withPresence:YES];
/// ```
///
/// - Parameters:
///   - channels: List of channel names on which client should try to subscribe.
///   - shouldObservePresence: Whether presence observation should be enabled for `channels` or not.
- (void)subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence
    NS_SWIFT_NAME(subscribeToChannels(_:withPresence:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-subscribeWithRequest:' method instead.");

/// Try subscribe on specified set of channels.
///
/// Client is able to subscribe of remote data objects live feed and listen for new events from them.
///
/// > Note: Since **4.8.0** if `managePresenceListManually` client configuration property is set to `YES` this API won't
/// add channels to presence heartbeat list.
///
/// #### Example:
/// ```
/// NSNumber *timeToken = @([[NSDate dateWithTimeIntervalSinceNow:-2.0] timeIntervalSince1970]);
///
/// [self.client subscribeToChannels:@[@"swift"] withPresence:YES usingTimeToken:timeToken];
/// ```
///
/// - Parameters:
///   - channels: List of channel names on which client should try to subscribe.
///   - shouldObservePresence: Whether presence observation should be enabled for `channels` or not.
///   - timeToken: Time from which client should try to catch up on messages.
- (void)subscribeToChannels:(NSArray<NSString *> *)channels
               withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(nullable NSNumber *)timeToken
    NS_SWIFT_NAME(subscribeToChannels(_:withPresence:usingTimeToken:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-subscribeWithRequest:' method instead.");

/// Try subscribe on specified set of channels.
///
/// Client is able to subscribe of remote data objects live feed and listen for new events from them.
///
/// > Note: Since **4.8.0** if `managePresenceListManually` client configuration property is set to `YES` this API won't
/// add channels to presence heartbeat list.
///
/// #### Example:
/// ```
/// [self.client subscribeToChannels:@[@"swift"] withPresence:YES clientState:@{ @"swift": @{ @"Type": @"Developer" }}];
/// ```
///
/// - Parameters:
///   - channels: List of channel names on which client should try to subscribe.
///   - shouldObservePresence: Whether presence observation should be enabled for `channels` or not.
///   - state: `NSDictionary` with key-value pairs based on channel group name and value which should be assigned to it.
- (void)subscribeToChannels:(NSArray<NSString *> *)channels
               withPresence:(BOOL)shouldObservePresence
                clientState:(nullable NSDictionary<NSString *, id> *)state
    NS_SWIFT_NAME(subscribeToChannels(_:withPresence:clientState:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-subscribeWithRequest:' method instead.");

/// Try subscribe on specified set of channels.
///
/// Client is able to subscribe of remote data objects live feed and listen for new events from them.
///
/// > Note: Since **4.8.0** if `managePresenceListManually` client configuration property is set to `YES` this API won't
/// add channels to presence heartbeat list.
///
/// #### Example:
/// ```objc
/// NSNumber *timeToken = @([[NSDate dateWithTimeIntervalSinceNow:-2.0] timeIntervalSince1970]);
///
/// [self.client subscribeToChannels:@[@"swift"] 
///                     withPresence:YES
///                   usingTimeToken:timeToken
///                      clientState:@{ @"swift": @{ @"Type": @"Developer" }}];
/// ```
///
/// - Parameters:
///   - channels: List of channel names on which client should try to subscribe.
///   - shouldObservePresence: Whether presence observation should be enabled for `channels` or not.
///   - timeToken: Time from which client should try to catch up on messages.
///   - state: `NSDictionary` with key-value pairs based on channel group name and value which should be assigned to it.
- (void)subscribeToChannels:(NSArray<NSString *> *)channels
               withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(nullable NSNumber *)timeToken 
                clientState:(nullable NSDictionary<NSString *, id> *)state
    NS_SWIFT_NAME(subscribeToChannels(_:withPresence:usingTimeToken:clientState:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-subscribeWithRequest:' method instead.");

/// Try subscribe on specified set of channel groups.
///
/// Client is able to subscribe of remote data objects live feed and listen for new events from them.
///
/// > Note: Since **4.8.0** if `managePresenceListManually` client configuration property is set to `YES` this API won't
/// add channel groups to presence heartbeat list.
///
/// #### Example:
/// ```objc
/// [self.client subscribeToChannelGroups:@[@"developers"] withPresence:YES];
/// ```
///
/// - Parameters:
///   - groups: List of channel group names on which client should try to subscribe.
///   - shouldObservePresence: Whether presence observation should be enabled for `groups` or not.
- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence
    NS_SWIFT_NAME(subscribeToChannelGroups(_:withPresence:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-subscribeWithRequest:' method instead.");

/// Try subscribe on specified set of channel groups.
///
/// Client is able to subscribe of remote data objects live feed and listen for new events from them.
///
/// > Note: Since **4.8.0** if `managePresenceListManually` client configuration property is set to `YES` this API won't
/// add channel groups to presence heartbeat list.
///
/// #### Example:
/// ```objc
/// NSNumber *timeToken = @([[NSDate dateWithTimeIntervalSinceNow:-2.0] timeIntervalSince1970]);
///
/// [self.client subscribeToChannelGroups:@[@"developers"] withPresence:YES usingTimeToken:timeToken];
/// ```
///
/// - Parameters:
///   - groups: List of channel group names on which client should try to subscribe.
///   - shouldObservePresence: Whether presence observation should be enabled for `groups` or not.
///   - timeToken: Time from which client should try to catch up on messages.
- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups
                    withPresence:(BOOL)shouldObservePresence
                  usingTimeToken:(nullable NSNumber *)timeToken
    NS_SWIFT_NAME(subscribeToChannelGroups(_:withPresence:usingTimeToken:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-subscribeWithRequest:' method instead.");

/// Try subscribe on specified set of channel groups.
///
/// Client is able to subscribe of remote data objects live feed and listen for new events from them.
///
/// > Note: Since **4.8.0** if `managePresenceListManually` client configuration property is set to `YES` this API won't
/// add channel groups to presence heartbeat list.
///
/// #### Example:
/// ```objc
/// [self.client subscribeToChannelGroups:@[@"developers"]
///                          withPresence:YES
///                           clientState:@{ @"developers": @{ @"Name": @"Bob" }}];
/// ```
///
/// - Parameters:
///   - groups: List of channel group names on which client should try to subscribe.
///   - shouldObservePresence: Whether presence observation should be enabled for `groups` or not.
///   - state: `NSDictionary` with key-value pairs based on channel group name and value which should be assigned to it.
- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups
                    withPresence:(BOOL)shouldObservePresence
                     clientState:(nullable NSDictionary<NSString *, id> *)state
    NS_SWIFT_NAME(subscribeToChannelGroups(_:withPresence:clientState:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-subscribeWithRequest:' method instead.");

/// Try subscribe on specified set of channel groups.
///
/// Client is able to subscribe of remote data objects live feed and listen for new events from them.
///
/// > Note: Since **4.8.0** if `managePresenceListManually` client configuration property is set to `YES` this API won't
/// add channel groups to presence heartbeat list.
///
/// #### Example:
/// ```objc
/// NSNumber *timeToken = @([[NSDate dateWithTimeIntervalSinceNow:-2.0] timeIntervalSince1970]);
///
/// [self.client subscribeToChannelGroups:@[@"developers"] 
///                          withPresence:YES
///                        usingTimeToken:timeToken
///                           clientState:@{ @"developers": @{ @"Name": @"Bob" }}];
/// ```
///
/// - Parameters:
///   - groups: List of channel group names on which client should try to subscribe.
///   - shouldObservePresence: Whether presence observation should be enabled for `groups` or not.
///   - timeToken: Time from which client should try to catch up on messages.
///   - state: `NSDictionary` with key-value pairs based on channel group name and value which should be assigned to it.
- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups
                    withPresence:(BOOL)shouldObservePresence
                  usingTimeToken:(nullable NSNumber *)timeToken 
                     clientState:(nullable NSDictionary<NSString *, id> *)state
    NS_SWIFT_NAME(subscribeToChannelGroups(_:withPresence:usingTimeToken:clientState:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-subscribeWithRequest:' method instead.");

/// Enable presence observation on specified `channels`.
///
/// Client will be able to observe for presence events which is pushed to remote data objects.
///
/// #### Example:
/// ```objc
/// [self.client subscribeToPresenceChannels:@[@"swift"]];
/// ```
///
/// - Parameter channels: List of channel names for which client should try to subscribe on presence observing channels.
- (void)subscribeToPresenceChannels:(NSArray<NSString *> *)channels
    NS_SWIFT_NAME(subscribeToPresenceChannels(_:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-subscribeWithRequest:' method instead.");


#pragma mark - Un-subscription

/// Unsubscribe from specified resources.
///
/// #### Examples:
/// ##### Unsubscribe from regular channels and groups:
/// ```objc
/// PNPresenceLeaveRequest *request = [PNPresenceLeaveRequest requestWithChannels:@[@"channel-a"] channelGroups:nil];
/// [self.client unsubscribWithRequest:request];
/// ```
///
/// ##### Unsubscribe from presence channels and groups:
/// ```objc
/// // This request will unsubscribe from presence events on `group-a-pnpres` group.
/// PNPresenceLeaveRequest *request = [PNPresenceLeaveRequest requestWithPresenceChannels:nil
///                                                                         channelGroups:@[@"group-a"]];
/// request.observePresence = YES;
/// [self.client unsubscribeWithRequest:request];
/// ```
///
/// - Parameter request: Request with information about resources from which client should stop receiving real-time
/// updates.
- (void)unsubscribeWithRequest:(PNPresenceLeaveRequest *)request
    NS_SWIFT_NAME(unsubscribWithRequest(_:));

/// Unsubscribe / leave from specified set of channels.
///
/// Client will push `leave` presence event on specified `channels`.
///
/// #### Example:
/// ```objc
/// [self.client unsubscribeFromChannels:@[@"objc"] withPresence:YES];
/// ```
///
/// - Parameters:
///   - channels: List of channel names from which client should try to unsubscribe.
///   - shouldObservePresence: Whether client should disable presence observation on specified channels or keep
///   listening for presence event on them.
- (void)unsubscribeFromChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence
    NS_SWIFT_NAME(unsubscribeFromChannels(_:withPresence:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-unsubscribWithRequest:' method instead.");

/// Unsubscribe / leave from specified set of channel groups.
///
/// Client will push `leave` presence event on specified `groups` and all channels which is part of `groups`.
///
/// #### Example:
/// ```objc
/// [self.client unsubscribeFromChannelGroups:@[@"developers"] withPresence:YES];
/// ```
///
/// - Parameters:
///   - groups: List of channel group names from which client should try to unsubscribe.
///   - shouldObservePresence: Whether client should disable presence observation on specified channel groups or keep
///   listening for presence event on them.
- (void)unsubscribeFromChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence
    NS_SWIFT_NAME(unsubscribeFromChannelGroups(_:withPresence:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-unsubscribWithRequest:' method instead.");

/// Disable presence events observation on specified channels.
///
/// #### Example:
/// ```objc
/// [self.client unsubscribeFromPresenceChannels:@[@"swifty"]];
/// ```
///
/// - Parameter channels: List of channel names for which client should try to unsubscribe from presence observing
/// channels.
- (void)unsubscribeFromPresenceChannels:(NSArray<NSString *> *)channels
    NS_SWIFT_NAME(unsubscribeFromPresenceChannels(_:))
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated and will be removed with next major update. Please use "
                             "'-unsubscribWithRequest:' method instead.");

/// Unsubscribe from all channels and groups on which client has been subscribed so far.
///
/// This API will remove all channels, presence channels and channel groups from
/// subscribe cycle and as result will stop it.
///
/// #### Example:
/// ```objc
/// [self.client unsubscribeFromAll];
/// ```
- (void)unsubscribeFromAll;

/// Unsubscribe from all channels and groups on which client has been subscribed so far.
///
/// #### Example:
/// ```objc
/// [self.client unsubscribeFromAllWithCompletion:^(PNAcknowledgmentStatus *status) {
///     // Handle unsubscription process completion.
/// }];
/// ```
///
/// - Parameter block: Un-subscription completion block.
- (void)unsubscribeFromAllWithCompletion:(nullable PNStatusBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
