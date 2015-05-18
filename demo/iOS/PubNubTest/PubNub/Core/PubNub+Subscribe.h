#import <Foundation/Foundation.h>
#import "PubNub+Core.h"


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
/// @name Subscription
///------------------------------------------------

/**
 @brief      Try subscribe on specified set of channels.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and 
             listen for new events from them.
 
 @param channels              List of channel names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c channels or not.
 @param block                 Subscription process completion block which pass two arguments:
                              \c result - in case of successful request processing \c data field 
                              will contain results of subscription operation; \c status - in case if
                              error occurred during request processing.
 
 @since 4.0
 */
- (void)subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
              andCompletion:(PNCompletionBlock)block;

/**
 @brief      Try subscribe on specified set of channels.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and 
             listen for new events from them.
 @code
 @endcode
 Extension to \c -subscribeToChannels:withPresence:andCompletion: and allow to specify client state
 information which should be passed to \b PubNub service along with subscription.
 
 @param channels              List of channel names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c channels or not.
 @param state                 Reference on dictionary which stores key-value pairs based on channel
                              name and value which should be assigned to it.
 @param block                 Subscription process completion block which pass two arguments:
                              \c result - in case of successful request processing \c data field 
                              will contain results of subscription operation; \c status - in case if
                              error occurred during request processing.
 
 @since 4.0
 */
- (void)subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
                clientState:(NSDictionary *)state andCompletion:(PNCompletionBlock)block;

/**
 @brief      Try subscribe on specified set of channel groups.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and 
             listen for new events from them.
 
 @param groups                List of channel group names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c groups or not.
 @param block                 Subscription process completion block which pass two arguments:
                              \c result - in case of successful request processing \c data field 
                              will contain results of subscription operation; \c status - in case if
                              error occurred during request processing.
 
 @since 4.0
 */
- (void)subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
                   andCompletion:(PNCompletionBlock)block;

/**
 @brief      Try subscribe on specified set of channel groups.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and 
             listen for new events from them.
 
 @param groups                List of channel group names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c groups or not.
 @param state                 Reference on dictionary which stores key-value pairs based on channel
                              group name and value which should be assigned to it.
 @param block                 Subscription process completion block which pass two arguments:
                              \c result - in case of successful request processing \c data field 
                              will contain results of subscription operation; \c status - in case if
                              error occurred during request processing.
 
 @since 4.0
 */
- (void)subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
                     clientState:(NSDictionary *)state andCompletion:(PNCompletionBlock)block;

/**
 @brief      Enable presence observation on specified \c channels.
 @discussion Using this API client will be able to observe for presence events which is pushed to
             remote data objects.
 
 @param channels              List of channel names for which client should try to subscribe on
                              presence observing channels.
 @param block                 Subscription process completion block which pass two arguments:
                              \c result - in case of successful request processing \c data field 
                              will contain results of subscription operation; \c status - in case if
                              error occurred during request processing.
 
 @since 4.0
 */
- (void)subscribeToPresenceChannels:(NSArray *)channels withCompletion:(PNCompletionBlock)block;


///------------------------------------------------
/// @name Unsubscription
///------------------------------------------------

/**
 @brief      Unsubscribe/leave from specified set of channels.
 @discussion Using this API client will push leave presence event on specified \c channels and if it
             will be required it will re-subscribe on rest of the channels.
 
 @param channels              List of channel names from which client should try to unsubscribe.
 @param shouldObservePresence Whether client should disable presence observation on specified 
                              channels or keep listening for presence event on them.
 @param block                 Unsubscription process completion block which pass two arguments:
                              \c result - in case of successful request processing \c data field 
                              will contain results of unsubscription operation; \c status - in case
                              if error occurred during request processing.
 
 @since 4.0
 */
- (void)unsubscribeFromChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
                  andCompletion:(PNCompletionBlock)block;

/**
 @brief      Unsubscribe/leave from specified set of channel groups.
 @discussion Using this API client will push leave presence event on specified \c groups. In this
             case leave event will be pushed to all channels which is part of \c groups. If it
             will be required it will re-subscribe on rest of the channels.
 
 @param groups                List of channel group names from which client should try to 
                              unsubscribe.
 @param shouldObservePresence Whether client should disable presence observation on specified 
                              channel groups or keep listening for presence event on them.
 @param block                 Unsubscription process completion block which pass two arguments:
                              \c result - in case of successful request processing \c data field 
                              will contain results of unsubscription operation; \c status - in case
                              if error occurred during request processing.
 
 @since 4.0
 */
- (void)unsubscribeFromChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
                       andCompletion:(PNCompletionBlock)block;

/**
 @brief      Disable presence events observation on specified channels.
 @discussion This API allow to stop presence observation on specified set of channels.
 
 @param channels              List of channel names for which client should try to unsubscribe from
                              presence observing channels
 @param block                 Unsubscription process completion block which pass two arguments:
                              \c result - in case of successful request processing \c data field 
                              will contain results of unsubscription operation; \c status - in case
                              if error occurred during request processing.
 
 @since 4.0
 */
- (void)unsubscribeFromPresenceChannels:(NSArray *)channels andCompletion:(PNCompletionBlock)block;

#pragma mark -


@end
