#import "PNObservationCenter.h"
#import "PNStructures.h"

/**
 This header file used by library internal components which require to access to some methods and properties which
 shouldn't be visible to other application components.
 
 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PNObservationCenter (Protected)


#pragma mark - Class methods

/**
 Create observation instance which is attached to specified observer. This will allow to use simplified methods
 when API with completion block will be used.
 
 @param defaultObserver
 Reference on default observer which will be used along with simplified observation manipulation methods.
 */
+ (PNObservationCenter *)observationCenterWithDefaultObserver:(id)defaultObserver;

/**
 * Completely reset observation center by cleaning up
 * all subscribers and shared instance destroy
 */
+ (void)resetCenter;


#pragma mark - Instance methods

/**
 Initialize observation instance which is attached to specified observer. This will allow to use simplified methods
 when API with completion block will be used.
 
 @param defaultObserver
 Reference on default observer which will be used along with simplified observation manipulation methods.
 */
- (id)initWithDefaultObserver:(id)defaultObserver;

/**
 * Check whether observer is subscribed on PubNub state
 * change
 */
- (void)checkSubscribedOnClientStateChange:(id)observer
                                 withBlock:(void (^)(BOOL observing))checkCompletionBlock;

/**
 @brief Move callback stored under old token to new one.

 @discussion This operation required in case of methods reschedule, when block itself already stored
             inside of this observation center. Each time, when method rescheduled, it generate
             different callback tokens. This method allow to migrate callback stored during previous
             method call to new token (this will allow to call it at the end of request processing).

 @param oldCallbackToken Reference on callback token under which callback has been stored during
                         previous method call.
 @param callbackToken    Reference on callback token which has been generated on method reschedule
                         and under which callback from previous call session should be placed.

 @since 3.7.9
 */
- (void)changeClientCallbackToken:(NSString *)oldCallbackToken to:(NSString *)callbackToken;

/**
 @brief Ubsubscribe \b PubNub client instance which instantiated this observer from any
        notifications which may fire in future.

 @since 3.7.9
 */
- (void)removeClientAsObserver;


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
- (void)addClientAsStateRequestObserverWithToken:(NSString *)callbackToken
                                        andBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock;

/**
 Observing for state update process (this action will be performed only once per request).
 After event will be fired this observation request will be removed from queue.
 */
- (void)addClientAsStateUpdateObserverWithToken:(NSString *)callbackToken
                                       andBlock:(PNClientStateUpdateHandlingBlock)handlerBlock;


#pragma mark - Client channel groups observation

/**
 Add/remove observer which would like to know when PubNub client will receive channel groups.
 */
- (void)addClientAsChannelGroupsRequestObserverWithToken:(NSString *)callbackToken
                                                andBlock:(PNClientChannelGroupsRequestHandlingBlock)callbackBlock;

/**
 Add/remove observer which would like to know when PubNub client will receive channel group namespaces.
 */
- (void)addClientAsChannelGroupNamespacesRequestObserverWithToken:(NSString *)callbackToken
                                                         andBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)callbackBlock;

/**
 Add/remove observer which would like to know when PubNub client will remove namespace.
 */
- (void)addClientAsChannelGroupNamespaceRemovalObserverWithToken:(NSString *)callbackToken
                                                        andBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)callbackBlock;

/**
 Add/remove observer which would like to know when PubNub client will remove channel group.
 */
- (void)addClientAsChannelGroupRemovalObserverWithToken:(NSString *)callbackToken
                                               andBlock:(PNClientChannelGroupRemoveHandlingBlock)callbackBlock;

/**
 Add/remove observer which would like to know when PubNub client will receive channels for concrete channel group.
 */
- (void)addClientAsChannelsForGroupRequestObserverWithToken:(NSString *)callbackToken
                                                   andBlock:(PNClientChannelsForGroupRequestHandlingBlock)callbackBlock;

/**
 Add/remove observer which would like to know when PubNub client will modify channels list for concrete channel group.
 */
- (void)addClientAsChannelsAdditionToGroupObserverWithToken:(NSString *)callbackToken
                                                   andBlock:(PNClientChannelsAdditionToGroupHandlingBlock)callbackBlock;

- (void)addClientAsChannelsRemovalFromGroupObserverWithToken:(NSString *)callbackToken
                                                    andBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)callbackBlock;


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
- (void)addClientAsPushNotificationsEnableObserverWithToken:(NSString *)callbackToken
                                                   andBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock;

/**
 * Add/remove observer for push notification disabling on specified list of channels
 * (this action will be performed only once per disabling).
 * After event will be fired, this observation request will be removed from
 * queue.
 */
- (void)addClientAsPushNotificationsDisableObserverWithToken:(NSString *)callbackToken
                                                    andBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock;

/**
 * Add/remove observer for push notification enabled channels retrieval process
 * change observation.
 * (this action will be performed only once per list request).
 * After event will be fired, this observation request will be removed from
 * queue.
 */
- (void)addClientAsPushNotificationsEnabledChannelsObserverWithToken:(NSString *)callbackToken
                                                            andBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock;

/**
 * Add/remove observer for push notification removal from all channels process.
 * (this action will be performed only once per removal request).
 * After event will be fired, this observation request will be removed from
 * queue.
 */
- (void)addClientAsPushNotificationsRemoveObserverWithToken:(NSString *)callbackToken
                                                   andBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock;


#pragma mark - Time token observation

/**
 * Add PubNub client as observer for time token receiving
 * event till first event will arrive
 */
- (void)addClientAsTimeTokenReceivingObserverWithToken:(NSString *)callbackToken
                                              andBlock:(PNClientTimeTokenReceivingCompleteBlock)callbackBlock;


#pragma mark - Message sending observers

/**
 * Add/remove observers for message sending process (completion
 * or error).
 * After event will be fired this observation request will be
 * removed from queue.
 */
- (void)addClientAsMessageProcessingObserverWithToken:(NSString *)callbackToken
                                             andBlock:(PNClientMessageProcessingBlock)handleBlock;


#pragma mark - History observers

/**
 * Add/remove observers for history messages download
 * After event will be fired this observation request will be
 * removed from queue.
 */
- (void)addClientAsHistoryDownloadObserverWithToken:(NSString *)callbackToken
                                           andBlock:(PNClientHistoryLoadHandlingBlock)handleBlock;


#pragma mark - PAM observer

/**
 * Add/remove observer for PAM manipulation and audit.
 * After event will be fired this observation request will be removed from queue.
 */
- (void)addClientAsAccessRightsChangeObserverWithToken:(NSString *)callbackToken
                                              andBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;

- (void)addClientAsAccessRightsAuditObserverWithToken:(NSString *)callbackToken
                                             andBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;


#pragma mark - Participants observer

/**
 Add/remove observer for participants list download.
 After event will be fired this observation request will be removed from queue.
 */
- (void)addClientAsParticipantsListDownloadObserverWithToken:(NSString *)callbackToken
                                                    andBlock:(PNClientParticipantsHandlingBlock)handleBlock;

/**
 Add/remove observer for participant channels list download.
 After event will be fired this observation request will be removed from queue.
 */
- (void)addClientAsParticipantChannelsListDownloadObserverWithToken:(NSString *)callbackToken
                                                           andBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock;

#pragma mark -


@end
