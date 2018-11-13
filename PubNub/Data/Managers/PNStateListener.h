#import <Foundation/Foundation.h>
#import "PubNub+Subscribe.h"


#pragma mark Class forward

@class PNPresenceEventResult, PNMessageResult, PNErrorStatus, PubNub;


NS_ASSUME_NONNULL_BEGIN

/**
 @brief      Subscriber state listeners manager.
 @discussion Subscriber manager work in pair with state listener manager. Using manager's ability user able to
             add multiple listeners for state events which is triggered on subscriber. Listeners may receive 
             events about new message or presence event on one of remote data objects live feed. Also 
             listeners will receive subscriber state change (connected, disconnected, unexpected disconnect
             and etc).
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNStateListener : NSObject


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Construct state listener manager for concrete \b PubNub client instance.
 
 @param client Reference on client for which manager should operate and use data.
 
 @return Constructed and ready to use state listener manager.
 
 @since 4.0
 */
+ (instancetype)stateListenerForClient:(PubNub *)client;

/**
 @brief  Copy specified listener's state information.
 
 @param listener Reference on state listener manager whose information should be copied into receiver's state 
                 objects.
 
 @since 4.0
 */
- (void)inheritStateFromListener:(PNStateListener *)listener;


///------------------------------------------------
/// @name Listeners list modification
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

/**
 @brief  Remove all registered listeners (for message, presence event and client state change).
 
 @since 4.0
 */
- (void)removeAllListeners;


///------------------------------------------------
/// @name Listeners notification
///------------------------------------------------

/**
 @brief  This method allow to shift execution context temporary to private protected queue which  will 
         serialize access to list of listeners.
 
 @param block Reference on block which will be called on private queue.
 
 @since 4.0
 */
- (void)notifyWithBlock:(dispatch_block_t)block;

/**
 @brief   Notify all message listeners about new message.
 @warning Method should be called within \b -notifyWithBlock: block to shift execution to private protected 
          queue.
 
 @param message Reference on event object which provide information about operation type and service response 
                for it.
 
 @since 4.0
 */
- (void)notifyMessage:(PNMessageResult *)message;

/**
 @brief   Notify all presence event listeners about new event.
 @warning Method should be called within \b -notifyWithBlock: block to shift execution to private 
          protected queue.
 
 @param event Reference on event object which provide information about operation type and service
              response for it.
 
 @since 4.0
 */
- (void)notifyPresenceEvent:(PNPresenceEventResult *)event;

/**
 @brief   Notify all state change listeners about changes in subscriber state.
 @warning Method should be called within \b -notifyWithBlock: block to shift execution to private 
          protected queue.
 
 @param status Reference on state object which describe operation and category.
 
 @since 4.0
 */
- (void)notifyStatusChange:(PNSubscribeStatus *)status;

/**
 @brief   Notify all state change listeners about hearbeat processing results.
 @warning Method should be called within \b -notifyWithBlock: block to shift execution to private
          protected queue.
 
 @param status Reference on state object which describe operation and category.
 */
- (void)notifyHeartbeatStatus:(PNStatus *)status;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
