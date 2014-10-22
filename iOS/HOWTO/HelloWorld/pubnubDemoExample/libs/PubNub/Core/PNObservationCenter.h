#import <Foundation/Foundation.h>
#import "PNStructures.h"

/**
 Observation center will allow to subscribe for particular events with handle block (block will be provided by subscriber).
 
 @author Sergey Mamontov
 @version 3.4.0
 @copyright © 2009-13 PubNub Inc.
 */
@interface PNObservationCenter : NSObject


#pragma mark - Class (singleton) methods

/**
 Returns reference on shared observer center instance which manage all observers and notify them by request or notification.
 
 @return \b PNObservationCenter singleton.
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


#pragma mark - Client state retrieval / update observation

/**
 Add/remove observer which would like to know when \b PubNub client retrieve metadata.

 @warning Methods will be completely removed before feature release.
 */
- (void)addClientMetadataRequestObserver:(id)observer withBlock:(PNClientStateRetrieveHandlingBlock)handleBlock DEPRECATED_MSG_ATTRIBUTE("Use '-addClientStateRequestObserver:withBlock:' instead.");
- (void)removeClientMetadataRequestObserver:(id)observer DEPRECATED_MSG_ATTRIBUTE("Use '-removeClientStateRequestObserver:' instead.");

/**
 Add/remove observer which would like to know when \b PubNub client retrieve state.
 */
- (void)addClientStateRequestObserver:(id)observer withBlock:(PNClientStateRetrieveHandlingBlock)handleBlock;
- (void)removeClientStateRequestObserver:(id)observer;

/**
 Add/remove observer which would like to know when \b PubNub client update metadata.

 @warning Methods will be completely removed before feature release.
 */
- (void)addClientMetadataUpdateObserver:(id)observer withBlock:(PNClientStateUpdateHandlingBlock)handleBlock DEPRECATED_MSG_ATTRIBUTE("Use '-addClientStateUpdateObserver:withBlock:' instead.");
- (void)removeClientMetadataUpdateObserver:(id)observer DEPRECATED_MSG_ATTRIBUTE("Use '-removeClientStateUpdateObserver:withBlock:' instead.");

/**
 Add/remove observer which would like to know when \b PubNub client update state.

 @warning Methods will be completely removed before feature release.
 */
- (void)addClientStateUpdateObserver:(id)observer withBlock:(PNClientStateUpdateHandlingBlock)handleBlock;
- (void)removeClientStateUpdateObserver:(id)observer;


#pragma mark - Client channel groups observation

/**
 Add/remove observer which would like to know when PubNub client will receive channel groups.
 */
- (void)addChannelGroupsRequestObserver:(id)observer
                      withCallbackBlock:(PNClientChannelGroupsRequestHandlingBlock)callbackBlock;
- (void)removeChannelGroupsRequestObserver:(id)observer;

/**
 Add/remove observer which would like to know when PubNub client will receive channel group namespaces.
 */
- (void)addChannelGroupNamespacesRequestObserver:(id)observer
                               withCallbackBlock:(PNClientChannelGroupNamespacesRequestHandlingBlock)callbackBlock;
- (void)removeChannelGroupNamespacesRequestObserver:(id)observer;

/**
 Add/remove observer which would like to know when PubNub client will remove namespace.
 */
- (void)addChannelGroupNamespaceRemovalObserver:(id)observer
                              withCallbackBlock:(PNClientChannelGroupNamespaceRemoveHandlingBlock)callbackBlock;
- (void)removeChannelGroupNamespaceRemovalObserver:(id)observer;

/**
 Add/remove observer which would like to know when PubNub client will remove channel group.
 */
- (void)addChannelGroupRemovalObserver:(id)observer
                     withCallbackBlock:(PNClientChannelGroupRemoveHandlingBlock)callbackBlock;
- (void)removeChannelGroupRemovalObserver:(id)observer;

/**
 Add/remove observer which would like to know when PubNub client will receive channels for concrete channel group.
 */
- (void)addChannelsForGroupRequestObserver:(id)observer
                         withCallbackBlock:(PNClientChannelsForGroupRequestHandlingBlock)callbackBlock;
- (void)removeChannelsForGroupRequestObserver:(id)observer;

/**
 Add/remove observer which would like to know when PubNub client will modify channels list for concrete channel group.
 */
- (void)addChannelsAdditionToGroupObserver:(id)observer
                         withCallbackBlock:(PNClientChannelsAdditionToGroupHandlingBlock)callbackBlock;
- (void)removeChannelsAdditionToGroupObserver:(id)observer;
- (void)addChannelsRemovalFromGroupObserver:(id)observer
                         withCallbackBlock:(PNClientChannelsRemovalFromGroupHandlingBlock)callbackBlock;
- (void)removeChannelsRemovalFromGroupObserver:(id)observer;


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


#pragma mark - Channels presence enable/disable observers

/**
 * Add/remove observer which would like to know when PubNub client
 * presence enabling/disabling on channel
 */
- (void)addClientPresenceEnablingObserver:(id)observer withCallbackBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock;
- (void)removeClientPresenceEnablingObserver:(id)observer;
- (void)addClientPresenceDisablingObserver:(id)observer withCallbackBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock;
- (void)removeClientPresenceDisablingObserver:(id)observer;


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


#pragma mark - PAM observer

/**
 * Add/remove observer for PAM manipulation and audit.
 * After event will be fired this observation request will be removed from queue.
 */
- (void)addAccessRightsChangeObserver:(id)observer withBlock:(PNClientChannelAccessRightsChangeBlock)handlerBlock;
- (void)removeAccessRightsObserver:(id)observer;
- (void)addAccessRightsAuditObserver:(id)observer withBlock:(PNClientChannelAccessRightsAuditBlock)handlerBlock;
- (void)removeAccessRightsAuditObserver:(id)observer;


#pragma mark - Participants observing

/**
 * Add/remove channel participants processing event observing
 */
- (void)addChannelParticipantsListProcessingObserver:(id)observer
                                           withBlock:(PNClientParticipantsHandlingBlock)handleBlock;
- (void)removeChannelParticipantsListProcessingObserver:(id)observer;

- (void)addClientParticipantChannelsListDownloadObserver:(id)observer
                                                 withBlock:(PNClientParticipantChannelsHandlingBlock)handleBlock;
- (void)removeClientParticipantChannelsListDownloadObserver:(id)observer;

#pragma mark -


@end
