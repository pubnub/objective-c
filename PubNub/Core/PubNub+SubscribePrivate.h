/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2017 PubNub, Inc.
 */
#import "PubNub+Subscribe.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PubNub (SubscribePrivate)


/**
 @brief      Try subscribe on specified set of channels and/or groups.
 @discussion Using subscribe API client is able to subscribe of remote data objects live feed and listen for 
             new events from them.
 
 @param channels              List of channel names on which client should try to subscribe.
 @param groups                List of channel group names on which client should try to subscribe.
 @param shouldObservePresence Whether presence observation should be enabled for \c channels and \c groups or 
                              not.
 @param timeToken             Time from which client should try to catch up on messages.
 @param state                 Reference on dictionary which stores key-value pairs based on channel /
                              group names and value which should be assigned to it.
 
 @since 4.5.6
 */
- (void)subscribeToChannels:(nullable NSArray<NSString *> *)channels
                     groups:(nullable NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence 
             usingTimeToken:(nullable NSNumber *)timeToken 
                clientState:(nullable NSDictionary<NSString *, id> *)state;


///------------------------------------------------
/// @name Unsubscription
///------------------------------------------------

/**
 @brief      Unsubscribe/leave from specified set of channels / groups.
 @discussion Using this API client will push leave presence event on specified \c channels and/or \c groups. 
             If it will be required it will re-subscribe on rest of the channels.
 
 @param channels              List of channel names from which client should try to unsubscribe.
 @param groups                List of channel group names from which client should try to 
                              unsubscribe.
 @param shouldObservePresence Whether client should disable presence observation on specified 
                              channel groups or keep listening for presence event on them.
 @param block                 Reference on subscription completion block which is used to notify 
                              code.
 
 @since 4.0
 */
- (void)unsubscribeFromChannels:(nullable NSArray<NSString *> *)channels 
                         groups:(nullable NSArray<NSString *> *)groups withPresence:(BOOL)shouldObservePresence
                     completion:(nullable PNSubscriberCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
