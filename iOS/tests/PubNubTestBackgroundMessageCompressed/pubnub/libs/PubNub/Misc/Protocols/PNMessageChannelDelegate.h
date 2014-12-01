//
//  PNMessageChannelDelegate.h
//  pubnub
//
//  Describes interface which is used to organize
//  communication between message communication
//  channel and PubNub client
//
//
//  Created by Sergey Mamontov on 12/5/12.
//
//


#pragma mark Class forward

@class PNMessagingChannel, PNMessage;
@class PNPresenceEvent;


@protocol PNMessageChannelDelegate <NSObject>


@optional // @required in corresponding categories for PubNub main class.

/**
 Sent to the delegate when messaging channel would like to change channels set and it need to know whether it should
 proceed with last time token or request new one from server.
 */
- (void)checkShouldKeepTimeTokenOnChannelsListChange:(PNMessagingChannel *)messagingChannel
                                           withBlock:(void (^)(BOOL shouldKeepTimeToken))checkCompletionBlock;

/**
 * Sent to the delegate when messaging channel would like to know on whether it should restore subscription or not
 */
- (void)checkShouldMessagingChannelRestoreSubscription:(PNMessagingChannel *)messagingChannel
                                             withBlock:(void (^)(BOOL restoreSubscription))checkCompletionBlock;

/**
 * Sent to the delegate when messaging channel would like to know on whether it should use last time token for
 * subscription or not
 */
- (void)checkShouldMessagingChannelRestoreWithLastTimeToken:(PNMessagingChannel *)messagingChannel
                                                  withBlock:(void (^)(BOOL restoreWithLastTimeToken))checkCompletionBlock;

/**
 Retrieve client state informatino for set of channels.
 
 @param channels
 List of \b PNChannel instances for which state information should be fetched.
 
 @return Cached information for channels from list,
 */
- (void)clientStateInformationForChannels:(NSArray *)channels
                                withBlock:(void (^)(NSDictionary *stateOnChannel))stateFetchCompletionBlock;

/**
 Retrieve reference on composed client state which should be used to update client information inside \b PubNub network.
 
 @param updatedState
 \b NSDictionary instance which should be merged with main client state information.
 
 @return Full client state information with latest changes from provided data.
 */
- (void)clientStateMergedWith:(NSDictionary *)updatedState
                     andBlock:(void (^)(NSDictionary *mergedState))mergeCompletionBlock;

/**
 Retrieve full client state information.
 
 @param Completed client's state information which is stored in cache.
 */
- (void)clientStateInformation:(void (^)(NSDictionary *clientState))stateFetchCompletionBlock;

/**
 Store updated client's state on specified channels in local cache.
 
 @param state
 Updated state which should be stored for provided channels.
 
 @param channels
 List of \b PNChannel instances for which client state updated in local cache.
 */
- (void)updateClientStateInformationWith:(NSDictionary *)state forChannels:(NSArray *)channels
                               withBlock:(dispatch_block_t)updateCompletionBlock;

/**
 * Sent to the delegate when client did reset it's state
 */
- (void)messagingChannelDidReset:(PNMessagingChannel *)messagingChannel;

/**
 Sent to the delegate when client is about to subscribe on specified set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willSubscribeOnChannels:(NSArray *)channels
               sequenced:(BOOL)isSequenced;

/**
 * Sent to the delegate when client successfully subscribed on specified set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didSubscribeOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced withClientState:(NSDictionary *)clientState;

/**
 * Sent to the delegate when client is about to launch subscription restore process
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willRestoreSubscriptionOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced;

/**
 * Sent to the delegate when client successfully restored subscription on previous set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didRestoreSubscriptionOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced;

/**
 * Sent to the delegate when client failed to subscribe on channels because of error
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didFailSubscribeOn:(NSArray *)channelObjects
               withError:(PNError *)error sequenced:(BOOL)isSequenced;

/**
 * Sent to the delegate when client is about to unsubscribe from specified list of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willUnsubscribeFrom:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced;

/**
 * Sent to the delegate when client unsubscribed from specified set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didUnsubscribeFrom:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced;

/**
 * Sent to the delegate when client failed to unsubscribe from channels because of error
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didFailUnsubscribeFrom:(NSArray *)channelObjects
               withError:(PNError *)error sequenced:(BOOL)isSequenced;

/**
 * Sent to the delegate when client is about to enable presence observation on specified set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willEnablePresenceObservationOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced;

/**
 * Sent to the delegate when client successfully enabled presence observation on set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didEnablePresenceObservationOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced;

/**
 * Sent to the delegate when client failed to enable presence on channels because of error
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didFailPresenceEnablingOn:(NSArray *)channelObjects
               withError:(PNError *)error sequenced:(BOOL)isSequenced;

/**
 * Sent to the delegate when client is about to disable presence observation on set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willDisablePresenceObservationOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced;

/**
 * Sent to the delegate when client successfully disabled presence observation on set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didDisablePresenceObservationOn:(NSArray *)channelObjects
               sequenced:(BOOL)isSequenced;

/**
 * Sent to the delegate when client failed to disable presence on channels because of error
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didFailPresenceDisablingOn:(NSArray *)channelObjects
               withError:(PNError *)error sequenced:(BOOL)isSequenced;

/**
 * Sent to delegate when client received message from channel on which it subscribed
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didReceiveMessage:(PNMessage *)message;

/**
 * Sent to delegate when client received presence event from channel on which it subscribed
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didReceiveEvent:(PNPresenceEvent *)event;

#pragma mark -


@end
