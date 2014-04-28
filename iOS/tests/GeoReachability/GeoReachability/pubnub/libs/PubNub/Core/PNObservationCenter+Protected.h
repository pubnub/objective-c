//
//  PNObservationCenter+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//
//  Created by Sergey Mamontov.
//
//

#import "PNObservationCenter.h"
#import "PNStructures.h"


@interface PNObservationCenter (Protected)


#pragma mark - Class methods

/**
 * Completely reset observation center by cleaning up
 * all subscribers and shared instance destroy
 */
+ (void)resetCenter;


#pragma mark - Instance methods

/**
 * Check whether observer is subscribed on PubNub state
 * change
 */
- (BOOL)isSubscribedOnClientStateChange:(id)observer;


#pragma mark - Client connection state observation

/**
 * Add/remove observer which would like to know when PubNub client
 * is connected/disconnected to/from PubNub services at specified
 * origin.
 * After event will be fired this observation request will be
 * removed from queue.
 */
- (void)addClientConnectionStateObserver:(id)observer
                            oneTimeEvent:(BOOL)isOneTimeEventObserver
                       withCallbackBlock:(PNClientConnectionStateChangeBlock)callbackBlock;
- (void)removeClientConnectionStateObserver:(id)observer oneTimeEvent:(BOOL)isOneTimeEventObserver;


#pragma mark - Client state retrieval / update observation

/**
 Observing for state retrieval process (this action will be performed only once per request).
 After event will be fired this observation request will be removed from queue.
 */
- (void)addClientAsStateRequestObserverWithBlock:(PNClientStateRetrieveHandlingBlock)handleBlock;
- (void)removeClientAsStateRequestObserver;

/**
 Observing for state update process (this action will be performed only once per request).
 After event will be fired this observation request will be removed from queue.
 */
- (void)addClientAsStateUpdateObserverWithBlock:(PNClientStateUpdateHandlingBlock)handleBlock;
- (void)removeClientAsStateUpdateObserver;


#pragma mark - Channels subscribe/leave observers

/**
 * Observing for subscription on list of channels (this action will be performed only once per subscription).
 * After event will be fired this observation request will be removed from queue.
 */
- (void)addClientAsSubscriptionObserverWithBlock:(PNClientChannelSubscriptionHandlerBlock)handleBlock;
- (void)removeClientAsSubscriptionObserver;

/**
 * Add/remove observer for unsubscribe completion from list
 * of channels (this action will be performed only
 * once per unsubscription request).
 * After event will be fired this observation request will be
 * removed from queue.
 */
- (void)addClientAsUnsubscribeObserverWithBlock:(PNClientChannelUnsubscriptionHandlerBlock)handleBlock;
- (void)removeClientAsUnsubscribeObserver;


#pragma mark - Channels presence enable/disable observers

/**
 * Observing for presence enabling event on specified channel
 * (this action will be performed only once per presence enabling).
 * After event will be fired this observation request will be
 * removed from queue.
 */
- (void)addClientAsPresenceEnablingObserverWithBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock;
- (void)removeClientAsPresenceEnabling;

/**
 * Add/remove observer for presence disabling event on specified
 * channel (this action will be performed only
 * once per presence disabling request).
 * After event will be fired this observation request will be
 * removed from queue.
 */
- (void)addClientAsPresenceDisablingObserverWithBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock;
- (void)removeClientAsPresenceDisabling;


#pragma mark - APNS interaction observation

/**
 * Add/remove observer for push notification enabling on specified list of channels
 * (this action will be performed only once per enabling).
 * After event will be fired, this observation request will be removed from
 * queue.
 */
- (void)addClientAsPushNotificationsEnableObserverWithBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;
- (void)removeClientAsPushNotificationsEnableObserver;

/**
 * Add/remove observer for push notification disabling on specified list of channels
 * (this action will be performed only once per disabling).
 * After event will be fired, this observation request will be removed from
 * queue.
 */
- (void)addClientAsPushNotificationsDisableObserverWithBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;
- (void)removeClientAsPushNotificationsDisableObserver;

/**
 * Add/remove observer for push notification enabled channels retrieval process
 * change observation.
 * (this action will be performed only once per list request).
 * After event will be fired, this observation request will be removed from
 * queue.
 */
- (void)addClientAsPushNotificationsEnabledChannelsObserverWithBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock;
- (void)removeClientAsPushNotificationsEnabledChannelsObserver;

/**
 * Add/remove observer for push notification removal from all channels process.
 * (this action will be performed only once per removal request).
 * After event will be fired, this observation request will be removed from
 * queue.
 */
- (void)addClientAsPushNotificationsRemoveObserverWithBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock;
- (void)removeClientAsPushNotificationsRemoveObserver;


#pragma mark - Time token observation

/**
 * Add PubNub client as observer for time token receiving
 * event till first event will arrive
 */
- (void)addClientAsTimeTokenReceivingObserverWithCallbackBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock;
- (void)removeClientAsTimeTokenReceivingObserver;


#pragma mark - Message sending observers

/**
 * Add/remove observers for message sending process (completion
 * or error).
 * After event will be fired this observation request will be
 * removed from queue.
 */
- (void)addClientAsMessageProcessingObserverWithBlock:(PNClientMessageProcessingBlock)handleBlock;
- (void)removeClientAsMessageProcessingObserver;
- (void)addMessageProcessingObserver:(id)observer
                           withBlock:(PNClientMessageProcessingBlock)handleBlock
                        oneTimeEvent:(BOOL)isOneTimeEventObserver;
- (void)removeMessageProcessingObserver:(id)observer oneTimeEvent:(BOOL)isOneTimeEventObserver;


#pragma mark - History observers

/**
 * Add/remove observers for history messages download
 * After event will be fired this observation request will be
 * removed from queue.
 */
- (void)addClientAsHistoryDownloadObserverWithBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;
- (void)removeClientAsHistoryDownloadObserver;


#pragma mark - PAM observer

/**
 * Add/remove observer for PAM manipulation and audit.
 * After event will be fired this observation request will be removed from queue.
 */
- (void)addClientAsAccessRightsChangeObserverWithBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
- (void)removeClientAsAccessRightsChangeObserver;
- (void)addClientAsAccessRightsAuditObserverWithBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;
- (void)removeClientAsAccessRightsAuditObserver;


#pragma mark - Participants observer

/**
 Add/remove observer for participants list download.
 After event will be fired this observation request will be removed from queue.
 */
- (void)addClientAsParticipantsListDownloadObserverWithBlock:(PNClientParticipantsHandlingBlock)handleBlock;
- (void)removeClientAsParticipantsListDownloadObserver;

/**
 Add/remove observer for participant channels list download.
 After event will be fired this observation request will be removed from queue.
 */
- (void)addClientAsParticipantChannelsListDownloadObserverWithBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock;
- (void)removeClientAsParticipantChannelsListDownloadObserver;

#pragma mark -


@end
