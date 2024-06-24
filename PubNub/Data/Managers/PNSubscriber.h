#import <Foundation/Foundation.h>
#import "PubNub+Subscribe.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PubNub;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Types

/// Subscriber operation completion block.
///
/// - Parameter status: Reference on subscribe/unsubscribe operation request service processing result.
typedef void(^PNSubscriberCompletionBlock)(PNSubscribeStatus * _Nullable status);


/// Class which allow to manage subscribe loop.
///
/// Track subscription and time token information. Subscriber manage recovery as well.
@interface PNSubscriber : NSObject


#pragma mark - State Information and Manipulation

/// Retrieve list of all remote data objects names to which client subscriber at this moment.
- (NSArray<NSString *> *)allObjects;

/// List of channels on which client subscribed at this moment.
- (NSArray<NSString *> *)channels;

/// List of channel groups on which client subscribed at this moment.
- (NSArray<NSString *> *)channelGroups;

/// List of presence channels for which client observing for presence events.
- (NSArray<NSString *> *)presenceChannels;


#pragma mark - Initialization and Configuration

/// Construct subscribe loop manager for concrete **PubNub** client.
///
/// - Parameter client: Client which will be weakly stored in subscriber.
/// - Returns: Configured and ready to use subscribe manager instance.
+ (instancetype)subscriberForClient:(PubNub *)client;

/// Copy specified subscriber's state information.
///
/// - Parameters subscriber: Subscriber whose information should be copied into receiver's state objects.
- (void)inheritStateFromSubscriber:(PNSubscriber *)subscriber;


#pragma mark - Subscription information modification

/// Add new channels to the list at which client subscribed.
///
/// - Parameter channels: List of channels which should be added to the list.
- (void)addChannels:(NSArray<NSString *> *)channels;

/// Remove channels from the list on which client subscribed.
///
/// - Parameter channels: List of channels which should be removed from the list.
- (void)removeChannels:(NSArray<NSString *> *)channels;

/// Add new channel groups to the list at which client subscribed.
///
/// - Parameter groups: List of channel groups which should be added to the list.
- (void)addChannelGroups:(NSArray<NSString *> *)groups;

/// Remove channel groups from the list on which client subscribed.
///
/// - Parameter groups: List of channel groups which should be removed from the list.
- (void)removeChannelGroups:(NSArray<NSString *> *)groups;

/// Add new presence channels to the list at which client subscribed.
///
/// - Parameter presenceChannels: List of presence channels which should be added to the list.
- (void)addPresenceChannels:(NSArray<NSString *> *)presenceChannels;

/// Remove presence channels from the list on which client subscribed.
///
/// - Parameter presenceChannels: List of presence channels which should be removed from the list.
- (void)removePresenceChannels:(NSArray<NSString *> *)presenceChannels;


#pragma mark - Subscription


/// Perform initial subscription with **0** timetoken.
///
/// Subscription with **0** timetoken "register" client in **PubNub** network and allow to receive live updates from
/// remote data objects live feed.
///
/// - Parameter request: Request with information about resources from which client will receive real-time updates.
- (void)subscribeWithRequest:(PNSubscribeRequest *)request;

/// Try restore subscription cycle by using **0** time token and if required try to catch up on previous subscribe time
/// token (basing on user configuration).
///
/// - Parameter block: Subscription completion block which is used to notify code.
- (void)restoreSubscriptionCycleIfRequiredWithCompletion:(nullable PNSubscriberCompletionBlock)block;

/// Continue subscription cycle using `currentTimeToken` value and channels, stored in cache.
///
/// - Parameter block: Subscription completion block which is used to notify code.
- (void)continueSubscriptionCycleIfRequiredWithCompletion:(nullable PNSubscriberCompletionBlock)block;


#pragma mark - Unsubscription

/// Unsubscribe from specified resources.
///
/// #### Example:
/// ```objc
/// // This request will unsubscribe from presence events on `group-a-pnpres` group.
/// PNPresenceLeaveRequest *request = [PNPresenceLeaveRequest requestWithPresenceChannels:nil
///                                                                         channelGroups:@[@"group-a"]];
/// [self unsubscribeWithRequest:request completion:^(PNSubscribeStatus *status) {
///     // Handle leave completion.
/// }];
/// ```
///
/// - Parameters
///   - request: Request with information about resources from which client should stop receiving real-time updates.
///   - block: Unsubscribe request completion block
- (void)unsubscribeWithRequest:(PNPresenceLeaveRequest *)request completion:(nullable PNSubscriberCompletionBlock)block;

/// Perform unsubscription operation.
///
/// Client will as **PubNub** presence service to trigger `leave` for all channels and groups (except presence) on which
/// client was subscribed earlier.
///
/// - Parameters:
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: Unsubscription completion block which is used to notify code.
- (void)unsubscribeFromAllWithQueryParameters:(NSDictionary *)queryParameters
                                   completion:(PNSubscriberCompletionBlock)block;

/// Perform unsubscription operation.
///
/// If suitable objects has been passed, then client will ask **PubNub** presence service to trigger `leave` presence
/// events on passed objects.
///
/// - Parameters:
///   - channels: List of channels from which client should unsubscribe.
///   - groups: List of channel groups from which client should unsubscribe.
///   - shouldInformListener: Whether listener should be informed at the end of operation or not.
///   - queryParameters: List arbitrary query parameters which should be sent along with original API call.
///   - block: Unsubscription completion block which is used to notify code.
- (void)unsubscribeFromChannels:(nullable NSArray<NSString *> *)channels
                         groups:(nullable NSArray<NSString *> *)groups
            withQueryParameters:(nullable NSDictionary *)queryParameters
          listenersNotification:(BOOL)shouldInformListener
                     completion:(nullable PNSubscriberCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
