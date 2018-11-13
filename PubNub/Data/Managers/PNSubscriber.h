#import <Foundation/Foundation.h>
#import "PubNub+Subscribe.h"
#import "PNStructures.h"


#pragma mark Class forward

@class PubNub;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Types

/**
 @brief  Subscriber operation completion block.
 
 @param status Reference on subscribe/unsubscribe operation request service processing result.
 
 @since 4.0
 */
typedef void(^PNSubscriberCompletionBlock)(PNSubscribeStatus * _Nullable status);


/**
 @brief      Class which allow to manage subscribe loop.
 @discussion Track subscription and time token information. Subscriber manage recovery as well.
 
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2010-2018 PubNub, Inc.
 */
@interface PNSubscriber : NSObject


///------------------------------------------------
/// @name State Information and Manipulation
///------------------------------------------------

/**
 @brief  Retrieve list of all remote data objects names to which client subscriber at this moment.
 
 @return Object names list.
 
 @since 4.0
 */
- (NSArray<NSString *> *)allObjects;

/**
 @brief  List of channels.
 
 @return Return list of channels on which client subscribed at this moment.
 
 @since 4.0
 */
- (NSArray<NSString *> *)channels;

/**
 @brief  List of channel groups.
 
 @return Return list of channel groups on which client subscribed at this moment.
 
 @since 4.0
 */
- (NSArray<NSString *> *)channelGroups;

/**
 @brief  List of presence channels.
 
 @return Return list of presence channels for which client observing for presence events.
 
 @since 4.0
 */
- (NSArray<NSString *> *)presenceChannels;


///------------------------------------------------
/// @name Initialization and Configuration
///------------------------------------------------

/**
 @brief  Construct subscribe loop manager for concrete \b PubNub client.
 
 @param client Reference on client which will be weakly stored in subscriber.
 
 @return Configured and ready to use subscribe manager instance.
 
 @since 4.0
 */
+ (instancetype)subscriberForClient:(PubNub *)client;

/**
 @brief  Copy specified subscriber's state information.
 
 @param subscriber Reference on subscriber whose information should be copied into receiver's state objects.
 
 @since 4.0
 */
- (void)inheritStateFromSubscriber:(PNSubscriber *)subscriber;


///------------------------------------------------
/// @name Subscription information modification
///------------------------------------------------

/**
 @brief  Add new channels to the list at which client subscribed.
 
 @param channels List of channels which should be added to the list.
 
 @since 4.0
 */
- (void)addChannels:(NSArray<NSString *> *)channels;

/**
 @brief  Remove channels from the list on which client subscribed.
 
 @param channels List of channels which should be removed from the list.
 
 @since 4.0
 */
- (void)removeChannels:(NSArray<NSString *> *)channels;

/**
 @brief  Add new channel groups to the list at which client subscribed.
 
 @param groups List of channel groups which should be added to the list.
 
 @since 4.0
 */
- (void)addChannelGroups:(NSArray<NSString *> *)groups;

/**
 @brief  Remove channel groups from the list on which client subscribed.
 
 @param groups List of channel groups which should be removed from the list.
 
 @since 4.0
 */
- (void)removeChannelGroups:(NSArray<NSString *> *)groups;

/**
 @brief  Add new presence channels to the list at which client subscribed.
 
 @param presenceChannels List of presence channels which should be added to the list.
 
 @since 4.0
 */
- (void)addPresenceChannels:(NSArray<NSString *> *)presenceChannels;

/**
 @brief  Remove presence channels from the list on which client subscribed.
 
 @param presenceChannels List of presence channels which should be removed from the list.
 
 @since 4.0
 */
- (void)removePresenceChannels:(NSArray<NSString *> *)presenceChannels;


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
 * @brief Perform initial subscription with \b 0 timetoken.
 *
 * @discussion Subscription with \b 0 timetoken "register" client in \b PubNub network and allow to
 * receive live updates from remote data objects live feed.
 *
 * @param timeToken Time from which client should try to catch up on messages.
 * @param state Reference on client state which should be bound to channels on which client has been
 *     subscribed or will subscribe now.
 * @param queryParameters List arbitrary query paramters which should be sent along with original
 *     API call.
 * @param block Reference on subscription completion block which is used to notify code.
 *
 * @since 4.8.2
 */
- (void)subscribeUsingTimeToken:(nullable NSNumber *)timeToken 
                      withState:(nullable NSDictionary<NSString *, id> *)state
                queryParameters:(nullable NSDictionary *)queryParameters
                     completion:(nullable PNSubscriberCompletionBlock)block;

/**
 @brief  Try restore subscription cycle by using \b 0 time token and if required try to catch up on
         previous subscribe time token (basing on user configuration).
 
 @param block Reference on unsubscription completion block which is used to notify code.
 
 @since 4.0
 */
- (void)restoreSubscriptionCycleIfRequiredWithCompletion:(nullable PNSubscriberCompletionBlock)block;

/**
 @brief  Continue subscription cycle using \c currentTimeToken value and channels, stored in cache.
 
 @param block Reference on unsubscription completion block which is used to notify code.
 
 @since 4.0
 */
- (void)continueSubscriptionCycleIfRequiredWithCompletion:(nullable PNSubscriberCompletionBlock)block;


///------------------------------------------------
/// @name Unsubscription
///------------------------------------------------

/**
 * @brief      Perform unsubscription operation.
 * @discussion Client will as \b PubNub presence service to trigger \c 'leave' for all channels and groups
 *             (except presence) on which client was subscribed earlier.
 *
 * @param queryParameters List arbitrary query parameters which should be sent along with original
 *     API call.
 * @param block Reference on unsubscription completion block which is used to notify code.
 *
 * @since 4.7.2
 */
- (void)unsubscribeFromAllWithQueryParameters:(NSDictionary *)queryParameters completion:(void (^)(PNStatus *status))block;

/**
 * @brief Perform unsubscription operation.
 *
 * @discussion If suitable objects has been passed, then client will ask \b PubNub presence service
 * to trigger \c 'leave' presence events on passed objects.
 *
 * @param channels List of channels from which client should unsubscribe.
 * @param groups List of channel groups from which client should unsubscribe.
 * @param shouldInformListener Whether listener should be informed at the end of operation or not.
 * @param queryParameters List arbitrary query paramters which should be sent along with original
 *     API call.
 * @param block Reference on unsubscription completion block which is used to notify code.
 *
 * @since 4.8.2
 */
- (void)unsubscribeFromChannels:(nullable NSArray<NSString *> *)channels
                         groups:(nullable NSArray<NSString *> *)groups
            withQueryParameters:(nullable NSDictionary *)queryParameters
          listenersNotification:(BOOL)shouldInformListener
                     completion:(nullable PNSubscriberCompletionBlock)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
