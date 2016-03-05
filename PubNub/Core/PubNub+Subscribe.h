#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


#pragma mark Class forward

@class PNSubscribeStatus;


#pragma mark - Protocols

@protocol PNObjectEventListener;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      \b PubNub client core class extension to provide access to 'publish' API group.
 @discussion Set of API which allow to push data to \b PubNub service. Data pusched to remote data objects 
             called 'channels' and then delivered on their live feeds to all subscribers.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
@interface PubNub (Subscribe)


///------------------------------------------------
/// @name Subscription state information
///------------------------------------------------

/**
 @brief  List of channels on which client subscribed now.
 
 @return \a NSArray of channel names on which client subscribed at this moment.
 
 @since 4.0
 */
- (NSArray<NSString *> *)channels;

/**
 @brief  List of channels group on which client subscribed now.
 
 @return \a NSArray of channel group names on which client subscribed at this moment.
 
 @since 4.0
 */
- (NSArray<NSString *> *)channelGroups;

/**
 @brief  List of channels for which presence events observation has been enabled.
 
 @return \a NSArray of presence channel names on which client subscribed at this moment.
 
 @since 4.0
 */
- (NSArray<NSString *> *)presenceChannels;

/**
 @brief  Check whether \b PubNub client currently subscribed on specified data object or not.
 
 @param name Reference on name of data object against which check should be performed.
 
 @return \c YES in case if client currently subscribed to specified data object.
 
 @since 4.0
 */
- (BOOL)isSubscribedOn:(NSString *)name;


///------------------------------------------------
/// @name Listeners
///------------------------------------------------

/**
 @brief      Add observer which conform to \b PNObjectEventListener protocol and would like to receive updates
             based on live feed events and status change.
 @discussion Listener can implement only required callbacks from \b PNObjectEventListener protocol and called
             only when desired type of event arrive.
 
 @param listener Listener which would like to receive updates.
 
 @since 4.0
 */
- (void)addListener:(id <PNObjectEventListener>)listener;

/**
 @brief      Remove listener from list for callback calls.
 @discussion When listener not interested in live feed updates it can remove itself from updates list using
             this method.
 
 @param listener Listener which doesn't want to receive updates anymore.
 
 @since 4.0
 */
- (void)removeListener:(id <PNObjectEventListener>)listener;


///------------------------------------------------
/// @name Filtering
///------------------------------------------------

/**
 @brief   Stores reference on string representation of filtering expression which should be applied to decide
          which updates should reach client.
 @warning If your filter expression is malformed, \b PNObjectEventListener won't receive any messages and 
          presence events from service (only error status).
 */
@property (nonatomic, nullable, copy) NSString *filterExpression;


///------------------------------------------------
/// @name Subscription
///------------------------------------------------

/**
 @brief      Try subscribe on specified set of channels.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and listen for 
             new events from them.
 @discussion \b Example:
 
 @code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client subscribeToChannels:@[@"swift"] withPresence:YES];
 @endcode
 
 @param channels              List of channel names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c channels or not.
 
 @since 4.0
 */
- (void)subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence;

/**
 @brief      Try subscribe on specified set of channels.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and listen for 
             new events from them.
 @discussion Extension to \c -subscribeToChannels:withPresence: and allow to specify arbitrarily which should 
             be used during subscription.
 @discussion \b Example:
 
 @code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
NSNumber *timeToken = @([[NSDate dateWithTimeIntervalSinceNow:-2.0] timeIntervalSince1970]);
[self.client subscribeToChannels:@[@"swift"] withPresence:YES usingTimeToken:timeToken];
 @endcode
 
 @param channels              List of channel names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c channels or not.
 @param timeToken             Time from which client should try to catch up on messages.
 
 @since 4.2.0
 */
- (void)subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(nullable NSNumber *)timeToken;

/**
 @brief      Try subscribe on specified set of channels.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and listen for 
             new events from them.
 @discussion Extension to \c -subscribeToChannels:withPresence: and allow to specify client state information 
             which should be passed to \b PubNub service along with subscription.
 @discussion \b Example:
 
 @code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client subscribeToChannels:@[@"swift"] withPresence:YES
                     clientState:@{@"swift": @{@"Type": @"Developer"}}];
 @endcode
 
 @param channels              List of channel names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c channels or not.
 @param state                 Reference on dictionary which stores key-value pairs based on channel name and 
                              value which should be assigned to it.
 
 @since 4.0
 */
- (void)subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence
                clientState:(nullable NSDictionary<NSString *, id> *)state;

/**
 @brief      Try subscribe on specified set of channels.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and listen for 
             new events from them.
 @discussion Extension to \c -subscribeToChannels:withPresence:usingTimeToken: and allow to specify client 
             state information which should be passed to \b PubNub service along with subscription.
 @discussion \b Example:
 
 @code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
NSNumber *timeToken = @([[NSDate dateWithTimeIntervalSinceNow:-2.0] timeIntervalSince1970]);
[self.client subscribeToChannels:@[@"swift"] withPresence:YES usingTimeToken:timeToken
                     clientState:@{@"swift": @{@"Type": @"Developer"}}];
 @endcode
 
 @param channels              List of channel names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c channels or not.
 @param timeToken             Time from which client should try to catch up on messages.
 @param state                 Reference on dictionary which stores key-value pairs based on channel name and 
                              value which should be assigned to it.
 
 @since 4.2.0
 */
- (void)subscribeToChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence
             usingTimeToken:(nullable NSNumber *)timeToken 
                clientState:(nullable NSDictionary<NSString *, id> *)state;

/**
 @brief      Try subscribe on specified set of channel groups.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and listen for 
             new events from them.
 @discussion \b Example:
 
 @code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client subscribeToChannelGroups:@[@"developers"] withPresence:YES];
 @endcode
 
 @param groups                List of channel group names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c groups or not.
 
 @since 4.0
 */
- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence;

/**
 @brief      Try subscribe on specified set of channel groups.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and listen for 
             new events from them.
 @discussion Extension to \c -subscribeToChannelGroups:withPresence: and allow to specify arbitrarily which 
             should be used during subscription.
 @discussion \b Example:
 
 @code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
NSNumber *timeToken = @([[NSDate dateWithTimeIntervalSinceNow:-2.0] timeIntervalSince1970]);
[self.client subscribeToChannelGroups:@[@"developers"] withPresence:YES usingTimeToken:timeToken];
 @endcode

 @param groups                List of channel group names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c groups or not.
 @param timeToken             Time from which client should try to catch up on messages.
 
 @since 4.2.0
 */
- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence
                  usingTimeToken:(nullable NSNumber *)timeToken;

/**
 @brief      Try subscribe on specified set of channel groups.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and listen for 
             new events from them.
 @discussion Extension to \c -subscribeToChannelGroups:withPresence: and allow to specify client state 
             information which should be passed to \b PubNub service along with subscription.
 @discussion \b Example:
 
 @code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client subscribeToChannelGroups:@[@"developers"] withPresence:YES
                          clientState:@{@"developers": @{@"Name": @"Bob"}}];
 @endcode
 
 @param groups                List of channel group names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c groups or not.
 @param state                 Reference on dictionary which stores key-value pairs based on channel group name
                              and value which should be assigned to it.
 
 @since 4.0
 */
- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence
                     clientState:(nullable NSDictionary<NSString *, id> *)state;

/**
 @brief      Try subscribe on specified set of channel groups.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and listen for 
             new events from them.
 @discussion Extension to \c -subscribeToChannelGroups:withPresence:usingTimeToken: and allow to specify 
             client state information which should be passed to \b PubNub service along with subscription.
 @discussion \b Example:
 
 @code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
NSNumber *timeToken = @([[NSDate dateWithTimeIntervalSinceNow:-2.0] timeIntervalSince1970]);
[self.client subscribeToChannelGroups:@[@"developers"] withPresence:YES usingTimeToken:timeToken
                          clientState:@{@"developers": @{@"Name": @"Bob"}}];
 @endcode
 
 @param groups                List of channel group names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c groups or not.
 @param timeToken             Time from which client should try to catch up on messages.
 @param state                 Reference on dictionary which stores key-value pairs based on channel
                              group name and value which should be assigned to it.
 
 @since 4.2.0
 */
- (void)subscribeToChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence
                  usingTimeToken:(nullable NSNumber *)timeToken 
                     clientState:(nullable NSDictionary<NSString *, id> *)state;

/**
 @brief      Enable presence observation on specified \c channels.
 @discussion Using this API client will be able to observe for presence events which is pushed to remote data
             objects.
 @discussion \b Example:
 
 @code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client subscribeToPresenceChannels:@[@"swift"]];
 @endcode
 
 @param channels List of channel names for which client should try to subscribe on presence observing 
                 channels.
 
 @since 4.0
 */
- (void)subscribeToPresenceChannels:(NSArray<NSString *> *)channels;


///------------------------------------------------
/// @name Unsubscription
///------------------------------------------------

/**
 @brief      Unsubscribe/leave from specified set of channels.
 @discussion Using this API client will push leave presence event on specified \c channels and if it will be 
             required it will re-subscribe on rest of the channels.
 @discussion \b Example:
 
 @code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client unsubscribeFromChannels:@[@"objc"] withPresence:YES];
 @endcode
 
 @param channels              List of channel names from which client should try to unsubscribe.
 @param shouldObservePresence Whether client should disable presence observation on specified channels or keep
                              listening for presence event on them.
 
 @since 4.0
 */
- (void)unsubscribeFromChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)shouldObservePresence;

/**
 @brief      Unsubscribe/leave from specified set of channel groups.
 @discussion Using this API client will push leave presence event on specified \c groups. In this case leave
             event will be pushed to all channels which is part of \c groups. If it will be required it will 
             re-subscribe on rest of the channels.
 @discussion \b Example:
 
 @code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client unsubscribeFromChannelGroups:@[@"developers"] withPresence:YES];
 @endcode
 
 @param groups                List of channel group names from which client should try to unsubscribe.
 @param shouldObservePresence Whether client should disable presence observation on specified channel groups 
                              or keep listening for presence event on them.
 
 @since 4.0
 */
- (void)unsubscribeFromChannelGroups:(NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence;

/**
 @brief      Disable presence events observation on specified channels.
 @discussion This API allow to stop presence observation on specified set of channels.
 @discussion \b Example:
 
 @code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client unsubscribeFromPresenceChannels:@[@"swifty"]];
 @endcode
 
 @param channels List of channel names for which client should try to unsubscribe from presence observing 
                 channels.
 
 @since 4.0
 */
- (void)unsubscribeFromPresenceChannels:(NSArray<NSString *> *)channels;

/**
 @brief      Unsubscribe from all channels and groups on which client has been subscrbed so far.
 @discussion This API will remove all channels, presence channels and channel groups from subscribe cycle and 
             as result will stop it.
 @discussion \b Example:
 
 @code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                 subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
[self.client unsubscribeFromAll];
 @endcode
 
 @since 4.2.0
 */
- (void)unsubscribeFromAll;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
