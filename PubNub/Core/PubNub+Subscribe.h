#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


@protocol PNObjectEventListener;

#pragma mark API group protocols

/**
 @brief      Protocol which describe subscriber data object structure.
 @discussion Contain information about channel on which event happened and reference on channel for
             which client subscribed.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNSubscriberData <PNErrorStatusData>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Name of regular channel or channel group.
 
 @return Name of the object on which client subscribed.
 
 @since 4.0
 */
- (NSString *)subscribedChannel;

/**
 @brief  Name of channel in case if \c -subscribedChannel represent channel group.
 
 @return Name of channel from which event arrived.
 
 @since 4.0
 */
- (NSString *)actualChannel;

/**
 @brief  Time at which even arrived
 
 @return Number with unsigned long long timestamp.
 
 @since 4.0
 */
- (NSNumber *)timetoken;

@end


/**
 @brief      Protocol which describe message data object structure.
 @discussion Contain information about message which arrived on certain channel (information about 
             channel group to which channel belong).
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNMessageData <PNSubscriberData>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Message which has been delivered through data object live feed.
 
 @return De-serialized message object.
 
 @since 4.0
 */
- (id)message;

@end

/**
 @brief      Protocol which describe presence event details object structure.
 @discussion Contain information about presence event which arrived on certain channel.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNPresenceDetails


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Time when presence event has been tirggered.
 
 @return Number with unsugned long long timestamp.
 
 @since 4.0
 */
- (NSNumber *)timetoken;

/**
 @brief  Reference on unique user identifier for which event has been triggered.
 
 @return UUID string.
 
 @since 4.0
 */
- (NSString *)uuid;

/**
 @brief  Channel presence information.
 
 @return Number of subscribers which become after presence event has been triggered.
 
 @since 4.0
 */
- (NSNumber *)occupancy;

/**
 @brief  User changed client state.
 
 @return In case of state change presence event will contain actual client state infotmation for
         \c -uuid.
 
 @since 4.0
 */
- (NSDictionary *)state;

@end


/**
 @brief      Protocol which describe presence event data object structure.
 @discussion Contain information about presence event which arrived on certain channel.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNPresenceEventData <PNSubscriberData>


///------------------------------------------------
/// @name Informatino
///------------------------------------------------

/**
 @brief  Type of presence event.
 
 @return One of available presence event types.
 
 @since 4.0
 */
- (NSString *)presenceEvent;

/**
 @brief  Additional presence information.
 
 @return Object which has additional information about arrived presence event.
 
 @since 4.0
 */
- (NSObject<PNPresenceDetails> *)presence;

@end


/**
 @brief  Protocol which describe operation processing resulting object with typed with \c data field
         with corresponding data type.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNMessageResult <PNResult>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Reference on service response data casted to required type.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNMessageData> *data;

@end


/**
 @brief  Protocol which describe operation processing status object with typed with \c data field
         with corresponding data type.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNSubscriberStatus <PNStatus>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Time token which has been used to establish current subscription cycle.
 
 @return Number with unsigned long long as timestamp.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *currentTimetoken;

/**
 @brief  Stores reference on previous key which has been used in subscription cycle to receive
         \c currentTimetoken along with other events.
 
 @return Number with unsigned long long as timestamp.
 
 @since 4.0
 */
@property (nonatomic, readonly, strong) NSNumber *lastTimeToken;

/**
 @brief  List of channels on which client currently subscribed.
 
 @return List of channel names.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSArray *subscribedChannels;

/**
 @brief  List of channel group names on which client currently subscribed.
 
 @return List of channel group names.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSArray *subscribedChannelGroups;

/**
 @brief  Structured \b PNResult \c data field information.
 
 @return Reference on field which hold structured service response.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNSubscriberData> *data;

@end


/**
 @brief  Protocol which describe operation processing resulting object with typed with \c data field
         with corresponding data type.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
@protocol PNPresenceEventResult <PNResult>


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
 @brief  Reference on service response data casted to required type.
 
 @since 4.0
 */
@property (nonatomic, readonly, copy) NSObject<PNPresenceEventData> *data;

@end


#pragma mark - API group interface

/**
 @brief      \b PubNub client core class extension to provide access to 'publish' API group.
 @discussion Set of API which allow to push data to \b PubNub service. Data pusched to remote data
             objects called 'channels' and then delivered on their live feeds to all subscribers.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
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
- (NSArray *)channels;

/**
 @brief  List of channels group on which client subscribed now.
 
 @return \a NSArray of channel group names on which client subscribed at this moment.
 
 @since 4.0
 */
- (NSArray *)channelGroups;

/**
 @brief  List of channels for which presence events observation has been enabled.
 
 @return \a NSArray of presence channel names on which client subscribed at this moment.
 
 @since 4.0
 */
- (NSArray *)presenceChannels;

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
 @brief      Add observer which conform to \b PNObjectEventListener protocol and would like to 
             receive updates based on live feed events and status change.
 @discussion Listener can implement only required callbacks from \b PNObjectEventListener protocol
             and called only when desired type of event arrive.
 
 @param listener Listener which would like to receive updates.
 
 @since 4.0
 */
- (void)addListener:(id <PNObjectEventListener>)listener;

/**
 @brief      Remove listener from list for callback calls.
 @discussion When listener not interested in live feed updates it can remove itself from updates 
             list using this method.
 
 @param listener Listener which doesn't want to receive updates anymore.
 
 @since 4.0
 */
- (void)removeListener:(id <PNObjectEventListener>)listener;


///------------------------------------------------
/// @name Subscription
///------------------------------------------------

/**
 @brief      Try subscribe on specified set of channels.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and 
             listen for new events from them.
 
 @code
 @endcode
 \b Example:
 
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
- (void)subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence;

/**
 @brief      Try subscribe on specified set of channels.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and 
             listen for new events from them.
 @code
 @endcode
 Extension to \c -subscribeToChannels:withPresence: and allow to specify client state information 
 which should be passed to \b PubNub service along with subscription.
 
 @code
 @endcode
 \b Example:
 
 @code
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client subscribeToChannels:@[@"swift"] withPresence:YES
                 clientState:@{@"swift": @{@"Type": @"Developer"}}];
 @endcode
 
 @param channels              List of channel names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c channels or not.
 @param state                 Reference on dictionary which stores key-value pairs based on channel
                              name and value which should be assigned to it.
 
 @since 4.0
 */
- (void)subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
                clientState:(NSDictionary *)state;

/**
 @brief      Try subscribe on specified set of channel groups.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and 
             listen for new events from them.
 
 @code
 @endcode
 \b Example:
 
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
- (void)subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence;

/**
 @brief      Try subscribe on specified set of channel groups.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and 
             listen for new events from them.
 @code
 @endcode
 Extension to \c -subscribeToChannelGroups:withPresence: and allow to specify client state 
 information which should be passed to \b PubNub service along with subscription.
 
 @code
 @endcode
 \b Example:
 
 @code
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client subscribeToChannelGroups:@[@"developers"] withPresence:YES
                      clientState:@{@"developers": @{@"Name": @"Bob"}}];
 @endcode
 
 @param groups                List of channel group names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c groups or not.
 @param state                 Reference on dictionary which stores key-value pairs based on channel
                              group name and value which should be assigned to it.
 
 @since 4.0
 */
- (void)subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
                     clientState:(NSDictionary *)state;

/**
 @brief      Enable presence observation on specified \c channels.
 @discussion Using this API client will be able to observe for presence events which is pushed to
             remote data objects.
 
 @code
 @endcode
 \b Example:
 
 @code
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client subscribeToPresenceChannels:@[@"swift-pnpres"]];
 @endcode
 
 @param channels List of channel names for which client should try to subscribe on presence 
                 observing channels.
 
 @since 4.0
 */
- (void)subscribeToPresenceChannels:(NSArray *)channels;


///------------------------------------------------
/// @name Unsubscription
///------------------------------------------------

/**
 @brief      Unsubscribe/leave from specified set of channels.
 @discussion Using this API client will push leave presence event on specified \c channels and if it
             will be required it will re-subscribe on rest of the channels.
 
 @code
 @endcode
 \b Example:
 
 @code
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client unsubscribeFromChannels:@[@"objc"] withPresence:YES];
 @endcode
 
 @param channels              List of channel names from which client should try to unsubscribe.
 @param shouldObservePresence Whether client should disable presence observation on specified 
                              channels or keep listening for presence event on them.
 
 @since 4.0
 */
- (void)unsubscribeFromChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence;

/**
 @brief      Unsubscribe/leave from specified set of channel groups.
 @discussion Using this API client will push leave presence event on specified \c groups. In this
             case leave event will be pushed to all channels which is part of \c groups. If it
             will be required it will re-subscribe on rest of the channels.
 
 @code
 @endcode
 \b Example:
 
 @code
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client unsubscribeFromChannelGroups:@[@"developers"] withPresence:YES];
 @endcode
 
 @param groups                List of channel group names from which client should try to 
                              unsubscribe.
 @param shouldObservePresence Whether client should disable presence observation on specified 
                              channel groups or keep listening for presence event on them.
 
 @since 4.0
 */
- (void)unsubscribeFromChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence;

/**
 @brief      Disable presence events observation on specified channels.
 @discussion This API allow to stop presence observation on specified set of channels.
 
 @code
 @endcode
 \b Example:
 
 @code
 PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo" 
                                                                  subscribeKey:@"demo"];
 self.client = [PubNub clientWithConfiguration:configuration];
 [self.client unsubscribeFromPresenceChannels:@[@"swifty-pnpres"]];
 @endcode
 
 @param channels List of channel names for which client should try to unsubscribe from presence 
                 observing channels
 
 @since 4.0
 */
- (void)unsubscribeFromPresenceChannels:(NSArray *)channels;

#pragma mark -


@end
