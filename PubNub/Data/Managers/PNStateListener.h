#import <Foundation/Foundation.h>
#import "PubNub+Subscribe.h"


#pragma mark Class forward

@class PNMembershipEventResult, PNPresenceEventResult, PNSpaceEventResult, PNUserEventResult;
@class PNMessageActionResult, PNMessageResult, PNSignalResult, PNErrorStatus, PubNub;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Subscriber state listeners manager.
 *
 * @discussion Subscriber manager work in pair with state listener manager. Using manager's ability
 * user able to add multiple listeners for state events which is triggered on subscriber. Listeners
 * may receive events about new message / signal or presence event on one of remote data objects
 * live feed. Also listeners will receive subscriber state change (connected, disconnected,
 * unexpected disconnect and etc).
 *
 * @author Serhii Mamontov
 * @version 4.10.0
 * @since 4.0.0
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface PNStateListener : NSObject


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure state listener manager for concrete \b PubNub client instance.
 *
 * @param client Client for which manager should operate and use data.
 *
 * @return Configured and ready to use state listener manager.
 */
+ (instancetype)stateListenerForClient:(PubNub *)client;

/**
 * @brief Copy specified listener's state information.
 *
 * @param listener State listener manager whose information should be copied into receiver's state
 * objects.
 */
- (void)inheritStateFromListener:(PNStateListener *)listener;


#pragma mark - Listeners list modification

/**
 * @brief Add observer which conform to \b PNObjectEventListener protocol and would like to receive
 * updates based on live feed events and status change.
 *
 * @discussion Listener can implement only required callbacks from \b PNObjectEventListener protocol
 * and called only when desired type of event arrive.
 *
 * @param listener Listener which would like to receive updates.
 */
- (void)addListener:(id <PNObjectEventListener>)listener;

/**
 * @brief Remove listener from list for callback calls.
 *
 * @discussion When listener not interested in live feed updates it can remove itself from updates
 * list using this method.
 *
 * @param listener Listener which doesn't want to receive updates anymore.
 */
- (void)removeListener:(id <PNObjectEventListener>)listener;

/**
 * @brief Remove all registered listeners (for message, presence event and client state change).
 */
- (void)removeAllListeners;


#pragma mark - Listeners notification

/**
 * @brief This method allow to shift execution context temporary to private protected queue which
 * will serialize access to list of listeners.
 *
 * @param block Block which will be called on private queue.
 */
- (void)notifyWithBlock:(dispatch_block_t)block;

/**
 * @brief Notify all message listeners about new message.
 *
 * @warning Method should be called within \b -notifyWithBlock: block to shift execution to private
 * protected queue.
 *
 * @param message Event object which provide information about operation type and service response
 * for it.
 */
- (void)notifyMessage:(PNMessageResult *)message;

/**
 * @brief Notify all \c signal listeners about new signal.
 *
 * @warning Method should be called within \b -notifyWithBlock: block to shift execution to private
 * protected queue.
 *
 * @param signal Event object which provide information about operation type and service response
 * for it.
 */
- (void)notifySignal:(PNSignalResult *)signal;

/**
 * @brief Notify all \c message \c actions listeners about new signal.
 *
 * @warning Method should be called within \b -notifyWithBlock: block to shift execution to private
 * protected queue.
 *
 * @param action Event object which provide information about operation type and service response
 * for it.
 */
- (void)notifyMessageAction:(PNMessageActionResult *)action;

/**
 * @brief Notify all presence event listeners about new event.
 *
 * @warning Method should be called within \b -notifyWithBlock: block to shift execution to private
 * protected queue.
 *
 * @param event Event object which provide information about operation type and service response for
 * it.
 */
- (void)notifyPresenceEvent:(PNPresenceEventResult *)event;

/**
 * @brief Notify all \c membership listeners about new signal.
 *
 * @warning Method should be called within \b -notifyWithBlock: block to shift execution to private
 * protected queue.
 *
 * @param event Event object which provide information about operation type and service response
 * for it.
 */
- (void)notifyMembershipEvent:(PNMembershipEventResult *)event;

/**
 * @brief Notify all \c space listeners about new signal.
 *
 * @warning Method should be called within \b -notifyWithBlock: block to shift execution to private
 * protected queue.
 *
 * @param event Event object which provide information about operation type and service response
 * for it.
 */
- (void)notifySpaceEvent:(PNSpaceEventResult *)event;

/**
 * @brief Notify all \c user listeners about new signal.
 *
 * @warning Method should be called within \b -notifyWithBlock: block to shift execution to private
 * protected queue.
 *
 * @param event Event object which provide information about operation type and service response
 * for it.
 */
- (void)notifyUserEvent:(PNUserEventResult *)event;

/**
 * @brief Notify all state change listeners about changes in subscriber state.
 *
 * @warning Method should be called within \b -notifyWithBlock: block to shift execution to private
 * protected queue.
 *
 * @param status State object which describe operation and category.
 */
- (void)notifyStatusChange:(PNSubscribeStatus *)status;

/**
 * @brief Notify all state change listeners about hearbeat processing results.
 *
 * @warning Method should be called within \b -notifyWithBlock: block to shift execution to private
 * protected queue.
 *
 * @param status State object which describe operation and category.
 */
- (void)notifyHeartbeatStatus:(PNStatus *)status;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
