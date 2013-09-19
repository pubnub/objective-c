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

/**
 * Sent to the delegate when messaging channel would like to know on whether it should restore subscription or not
 */
- (BOOL)shouldMessagingChannelRestoreSubscription:(PNMessagingChannel *)messagingChannel;

/**
 * Sent to the delegate when messaging channel would like to know on whether it should use last time token for
 * subscription or not
 */
- (BOOL)shouldMessagingChannelRestoreWithLastTimeToken:(PNMessagingChannel *)messagingChannel;

/**
 * Sent to the delegate when client did reset it's state
 */
- (void)messagingChannelDidReset:(PNMessagingChannel *)messagingChannel;

/**
 * Sent to the delegate when client is about to subscribe on specified set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willSubscribeOnChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client successfully subscribed on specified set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didSubscribeOnChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client is about to launch subscription restore process
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willRestoreSubscriptionOnChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client successfully restored subscription on previous set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didRestoreSubscriptionOnChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client failed to subscribe on channels because of error
 */
- (void)  messagingChannel:(PNMessagingChannel *)messagingChannel
didFailSubscribeOnChannels:(NSArray *)channels
                 withError:(PNError *)error;

/**
 * Sent to the delegate when client is about to unsubscribe from specified list of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willUnsubscribeFromChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client unsubscribed from specified set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didUnsubscribeFromChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client failed to unsubscribe from channels because of error
 */
- (void)    messagingChannel:(PNMessagingChannel *)messagingChannel
didFailUnsubscribeOnChannels:(NSArray *)channels
                   withError:(PNError *)error;

/**
 * Sent to the delegate when client is about to enable presence observation on specified set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willEnablePresenceObservationOnChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client successfully enabled presence observation on set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didEnablePresenceObservationOnChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client failed to enable presence on channels because of error
 */
- (void)         messagingChannel:(PNMessagingChannel *)messagingChannel
didFailPresenceEnablingOnChannels:(NSArray *)channels
                        withError:(PNError *)error;

/**
 * Sent to the delegate when client is about to disable presence observation on set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel willDisablePresenceObservationOnChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client successfully disabled presence observation on set of channels
 */
- (void)messagingChannel:(PNMessagingChannel *)messagingChannel didDisablePresenceObservationOnChannels:(NSArray *)channels;

/**
 * Sent to the delegate when client failed to disable presence on channels because of error
 */
- (void)          messagingChannel:(PNMessagingChannel *)messagingChannel
didFailPresenceDisablingOnChannels:(NSArray *)channels
                         withError:(PNError *)error;

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