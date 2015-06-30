/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2015 PubNub, Inc.
 */
#import "PubNub+Subscribe.h"


#pragma mark Private interface declaration

@interface PubNub (SubscribePrivate)


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
 @param block                 Reference on subscription completion block which is used to notify 
                              code.
 
 @since 4.0
 */
- (void)unsubscribeFromChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
                     completion:(PNSubscriberCompletionBlock)block;

/**
 @brief      Unsubscribe/leave from specified set of channel groups.
 @discussion Using this API client will push leave presence event on specified \c groups. In this
             case leave event will be pushed to all channels which is part of \c groups. If it
             will be required it will re-subscribe on rest of the channels.
 
 @param groups                List of channel group names from which client should try to 
                              unsubscribe.
 @param shouldObservePresence Whether client should disable presence observation on specified 
                              channel groups or keep listening for presence event on them.
 @param block                 Reference on subscription completion block which is used to notify 
                              code.
 
 @since 4.0
 */
- (void)unsubscribeFromChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
                     completion:(PNSubscriberCompletionBlock)block;

#pragma mark -


@end
