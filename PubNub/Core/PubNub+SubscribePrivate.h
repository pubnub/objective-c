#import "PubNub+Subscribe.h"
#import "PNSubscriber.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

/// **PubNub** `Subscribe` APIs private extension.
@interface PubNub (SubscribePrivate)


#pragma mark - Subscription

/// Subscribe to specified resources.
///
/// > Important: Method used by ``PNSubscriber`` manager to make actual network calls.
///
/// #### Examples:
/// ##### Subscribe on regular channels and groups:
/// ```objc
/// PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[@"channel-a"] channelGroups:nil];
/// request.timetoken = @(1234567890);
/// [self.client subscribeWithRequest:request completion:^(PNSubscribeStatus *status) {
///     if (!status.isError) {
///         // Handle successful subscription completion.
///     } else {
///         // Handle subscription error. Check 'category' property to find out possible issue because of which request
///         // did fail.
///
///     }
/// }];
/// ```
///
/// - Parameters:
///   - request: Request with information about resources from which client will receive real-time updates.
///   - block: Subscribe request completion block
- (void)subscribeWithRequest:(PNSubscribeRequest *)request completion:(nullable PNSubscriberCompletionBlock)block;


#pragma mark - Un-subscription

/// Unsubscribe from specified resources.
///
/// > Important: Method used by ``PNSubscriber`` manager to make actual network calls.
///
/// #### Examples:
/// ##### Unsubscribe from regular channels and groups:
/// ```objc
/// PNPresenceLeaveRequest *request = [PNPresenceLeaveRequest requestWithChannels:@[@"channel-a"] channelGroups:nil];
/// request.observePresence = YES;
///
/// [self.client unsubscribeWithRequest:request];
/// ```
///
/// ##### Unsubscribe from presence channels and groups:
/// ```objc
/// // This request will unsubscribe from presence events on `group-a-pnpres` group.
/// PNPresenceLeaveRequest *request = [PNPresenceLeaveRequest requestWithPresenceChannels:nil
///                                                                         channelGroups:@[@"group-a"]];
/// [self.client unsubscribeWithRequest:request completion:^(PNSubscriberCompletionBlock *status) {
///     // Handle leave completion.
/// }];
/// ```
///
/// - Parameters
///   - request: Request with information about resources from which client should stop receiving real-time updates.
///   - block: Unsubscribe request completion block
- (void)unsubscribeWithRequest:(PNPresenceLeaveRequest *)request completion:(PNSubscriberCompletionBlock)block;

/// Unsubscribe / leave from specified set of channels / groups.
///
/// Using this API client will push leave presence event on specified `channels` and / or `groups`. If it will be
/// required it will re-subscribe on rest of the channels.
///
/// - Parameters:
///   - channels: List of channel names from which client should try to unsubscribe.
///   - groups: List of channel group names from which client should try to unsubscribe.
///   - shouldObservePresence: Whether client should disable presence observation on specified channel groups or keep
///   listening for presence event on them.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: Subscription completion block.
- (void)unsubscribeFromChannels:(nullable NSArray<NSString *> *)channels 
                         groups:(nullable NSArray<NSString *> *)groups
                   withPresence:(BOOL)shouldObservePresence
                queryParameters:(nullable NSDictionary *)queryParameters
                     completion:(nullable PNSubscriberCompletionBlock)block;


#pragma mark - Misc

/// Cancel any active long-polling subscribe operations scheduled for processing.
- (void)cancelSubscribeOperations;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
