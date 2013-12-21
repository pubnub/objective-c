//
//  PNDelegate.h
//  pubnub
//
//  Describes interface which is used to organize
//  communication between user code and PubNub
//  client instance.
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//


#pragma mark Class forward

@class PNPresenceEvent, PNMessage, PubNub, PNError, PNDate;


@protocol PNDelegate <NSObject>

@optional

/**
 * Called on delegate when some client runtime error occurred
 * (mostly because of configuration/connection when connected)
 */
- (void)pubnubClient:(PubNub *)client error:(PNError *)error;

/**
 * Called on delegate when client is about to initiate connection
 * to the origin
 */
- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin;

/**
 * Called on delegate when client successfully connected to the
 * origin and performed initial calls (time token requests to make
 * connection keep-alive)
 */
- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin;

/**
 * Called on delegate when client disconnected from PubNub services
 * and ready for new session
 */
- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin;

/**
 * Called on delegate when client disconnected from PubNub services
 * because of error
 */
- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error;

/**
 * Called on delegate when come error occurred during PubNub client
 * connection session and it will be closed
 */
- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error;

/**
 * Called on delegate when occurred error while tried to connect
 * to PubNub services
 * error - returned error will contain information about origin
 *         host name and error code which caused this error
 */
- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error;

/**
 * Called on delegate when client successfully subscribed to specified
 * set of channels
 */
- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels;

/**
 * Called on delegate when client is about to init resubscribe on
 * previous set of channels
 */
- (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels;

/**
 * Called on delegate when client successfully restored subscription on
 * previous set of channels
 */
- (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels;

/**
 * Called on delegate when some kind of error occurred during 
 * subscription creation
 * error - returned error will contain information about channel
 *         on which this error occurred and possible reason of error
 */
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(PNError *)error;

/**
 * Called on delegate when client successfully unsubscribed from specified
 * set of channels
 */
- (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels;

/**
 * Called on delegate when some kind of error occurred during
 * unsubscribe
 * error - returned error will contain information about channel
 *         on which this error occurred and possible reason of error
 */
- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error;

/**
 * Called on delegate when client successfully enabled presence observation on
 * set of channels
 */
- (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOnChannels:(NSArray *)channels;

/**
 * Called on delegate when some kind of error occurred during
 * presence observation enabling
 * error - returned error will contain information about channel
 *         on which this error occurred and possible reason of error
 */
- (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error;

/**
 * Called on delegate when client successfully disabled presence observation on
 * set of channels
 */
- (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOnChannels:(NSArray *)channels;

/**
 * Called on delegate when some kind of error occurred during
 * presence observation disabling
 * error - returned error will contain information about channel
 *         on which this error occurred and possible reason of error
 */
- (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error;

/**
 * Called on delegate when client successfully enabled push notifications on
 * specified list of channels
 */
- (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels;

/**
 * Called on delegate when some kind of error occurred during
 * push notification enabling process
 * error - returned error will contain information about channel(s)
 *         on which this error occurred and possible reason of error
 */
- (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error;

/**
 * Called on delegate when client successfully disabled push notifications on
 * specified list of channels
 */
- (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels;

/**
 * Called on delegate when some kind of error occurred during
 * push notification disabling process
 * error - returned error will contain information about channel(s)
 *         on which this error occurred and possible reason of error
 */
- (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error;

/**
 * Called on delegate when PubNub client was able to remove
 * push notification from all channels
 */
- (void)pubnubClientDidRemovePushNotifications:(PubNub *)client;

/**
 * Called on delegate when some kind of error occurred during
 * push notifications removal process
 */
- (void)pubnubClient:(PubNub *)client pushNotificationsRemoveFromChannelsDidFailWithError:(PNError *)error;

/**
 * Called on delegate when PubNub client was able to retrieve all
 * channels on which push notifications has been enabled
 */
- (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels;

/**
 * Called on delegate when some kind of error occurred during
 * push notifications enabled channels list retrieval process
 */
- (void)pubnubClient:(PubNub *)client pushNotificationEnabledChannelsReceiveDidFailWithError:(PNError *)error;

/**
 * Called on delegate when PubNub client retrieved time
 * token from PubNub service
 */
- (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken;
/**
 * Called on delegate when PubNub client failed to
 * retrieve time token from PubNub service because
 * of some error
 */
- (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error;

/**
 * Called on delegate when PubNub client is about to send
 * message to remote server
 */
- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message;

/**
 * Called on delegate when some kind of error occurred while
 * tried to send message to PubNub services
 */
- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error;

/**
 * Called on delegate when message was successfully set to
 * the PubNub service
 */
- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message;

/**
 * Called on delegate when client received message from remote
 * PubNub service
 */
- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message;

/**
 * Called on delegate when client received presence event from remote
 * PubNub service
 */
- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event;

/**
 * Called on delegate when client completed message history download
 * for specific channel
 */
- (void)    pubnubClient:(PubNub *)client
didReceiveMessageHistory:(NSArray *)messages
              forChannel:(PNChannel *)channel
            startingFrom:(PNDate *)startDate
                      to:(PNDate *)endDate;

/**
 * Called on delegate when client failed to download messages history
 */
- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error;

/**
 * Called on delegate when client retrieved participants list
 * for specific channel
 */
- (void)      pubnubClient:(PubNub *)client
didReceiveParticipantsList:(NSArray *)participantsList
                forChannel:(PNChannel *)channel;

/**
 * Called on delegate when client failed to download participants
 * list
 */
- (void)                     pubnubClient:(PubNub *)client
didFailParticipantsListDownloadForChannel:(PNChannel *)channel
                                withError:(PNError *)error;


#pragma mark - Misc methods

/**
 * This method is pulled by PubNub client when checking whether it should run in background mode when
 * application is pushed into background context.
 * If this method not implemented by delegate, than client will check whether there is background mode
 * keys in application information Property List and whether they is supported for persistent background
 * execution or not.
 */
- (BOOL)shouldRunClientInBackground;


#pragma mark - Configuration override delegate methods

/**
 * This method allow to override value passed in configuration
 * during client initialization.
 * This method called when service reachabilty reported that
 * service are available and previous session is failed because
 * of network error or even not launched.
 * We can change client configuration, but it will trigger 
 * client hard reset (if connected)
 */
- (NSNumber *)shouldReconnectPubNubClient:(PubNub *)client;

/**
 * This method allow to override value passed in configuration
 * during client initialization.
 * This method called when service reachabilty reported that
 * service are available and previous session is failed because
 * of network error or even not launched.
 * It allow to specify whether client should restore subscription
 * or previously subscribed channels or not
 */
- (NSNumber *)shouldResubscribeOnConnectionRestore;

/**
 * This method allow to override value passed in configuration
 * during client initialization.
 * This method is called by library right after connection has been
 * restored and client was configured to restore subscription on channels.
 */
- (NSNumber *)shouldRestoreSubscriptionFromLastTimeToken;

#pragma mark -


@end
