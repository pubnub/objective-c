//
//  PNObservationCenter.h
//  pubnub
//
//  Observation center will allow to subscribe
//  for particular events with handle block
//  (block will be provided by subscriber)
//
//
//  Created by Sergey Mamontov.
//
//

#import <Foundation/Foundation.h>
#import "PNStructures.h"


@interface PNObservationCenter : NSObject


#pragma mark Class methods

/**
 * Returns reference on shared observer center instance
 * which manage all observers and notify them by request
 * or notification.
 */
+ (PNObservationCenter *)defaultCenter;


#pragma mark - Instance methods

#pragma mark - Client connection state observation

/**
 * Add/remove observer which would like to know when PubNub client 
 * is connected/disconnected to/from PubNub services at specified
 * origin.
 */
- (void)addClientConnectionStateObserver:(id)observer
                       withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock;
- (void)removeClientConnectionStateObserver:(id)observer;


#pragma mark - Client channels action/event observation

/**
 * Add/remove observer which would like to know when PubNub client
 * subscribes/unsubscribe on/from channel
 */
- (void)addClientChannelSubscriptionStateObserver:(id)observer
                                withCallbackBlock:(PNClientChannelSubscriptionHandlerBlock)callbackBlock;
- (void)removeClientChannelSubscriptionStateObserver:(id)observer;
- (void)addClientChannelUnsubscriptionObserver:(id)observer
                             withCallbackBlock:(PNClientChannelUnsubscriptionHandlerBlock)callbackBlock;
- (void)removeClientChannelUnsubscriptionObserver:(id)observer;


#pragma mark - APNS interaction observation

/**
 * Add/remove observer for push notification enabling on specified list of channels
 * (this action will be performed only once per enabling).
 * After event will be fired, this observation request will be removed from
 * queue.
 */
- (void)addClientPushNotificationsEnableObserver:(id)observer
                               withCallbackBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;
- (void)removeClientPushNotificationsEnableObserver:(id)observer;

/**
 * Add/remove observer for push notification disabling on specified list of channels
 * (this action will be performed only once per disabling).
 * After event will be fired, this observation request will be removed from
 * queue.
 */
- (void)addClientPushNotificationsDisableObserver:(id)observer
                                withCallbackBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;
- (void)removeClientPushNotificationsDisableObserver:(id)observer;

/**
 * Add/remove observer for push notification enabled channels retrieval process
 * change observation.
 * (this action will be performed only once per list request).
 * After event will be fired, this observation request will be removed from
 * queue.
 */
- (void)addClientPushNotificationsEnabledChannelsObserver:(id)observer
                                        withCallbackBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock;
- (void)removeClientPushNotificationsEnabledChannelsObserver:(id)observer;

/**
 * Add/remove observer for push notification removal from all channels process.
 * (this action will be performed only once per removal request).
 * After event will be fired, this observation request will be removed from
 * queue.
 */
- (void)addClientPushNotificationsRemoveObserver:(id)observer
                               withCallbackBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock;
- (void)removeClientPushNotificationsRemoveObserver:(id)observer;


#pragma mark - Time token observation

/**
 * Add/remove observers which would like to know when PubNub service
 * will return requested time token
 */
- (void)addTimeTokenReceivingObserver:(id)observer
                    withCallbackBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock;
- (void)removeTimeTokenReceivingObserver:(id)observer;


#pragma mark - Message processing observers

/**
 * Add/remove observers for message sending process (completion
 * or error).
 */
- (void)addMessageProcessingObserver:(id)observer withBlock:(PNClientMessageProcessingBlock)handleBlock;
- (void)removeMessageProcessingObserver:(id)observer;

/**
 * Add/remove observers for message arrival (messages arrived from
 * PubNub service on subscribed channels)
 */
- (void)addMessageReceiveObserver:(id)observer withBlock:(PNClientMessageHandlingBlock)handleBlock;
- (void)removeMessageReceiveObserver:(id)observer;


#pragma mark - Presence observing

/**
 * Add/remove channels presence event observing
 */
- (void)addPresenceEventObserver:(id)observer withBlock:(PNClientPresenceEventHandlingBlock)handleBlock;
- (void)removePresenceEventObserver:(id)observer;


#pragma mark - History observing

/**
 * Add/remove channel history processing event observing
 */
- (void)addMessageHistoryProcessingObserver:(id)observer withBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;
- (void)removeMessageHistoryProcessingObserver:(id)observer;


#pragma mark - Participants observing

/**
 * Add/remove channel participants processing event observing
 */
- (void)addChannelParticipantsListProcessingObserver:(id)observer
                                           withBlock:(PNClientParticipantsHandlingBlock)handleBlock;
- (void)removeChannelParticipantsListProcessingObserver:(id)observer;

#pragma mark -


@end
