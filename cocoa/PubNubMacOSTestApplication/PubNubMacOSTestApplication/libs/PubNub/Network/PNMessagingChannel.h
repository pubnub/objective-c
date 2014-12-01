//
//  PNMessagingChannel.h
//  pubnub
//
//  This channel instance is required for messages exchange between client and PubNub service:
//    - channels messages (subscribe)
//    - channels presence events
//    - leave
//
//  Notice: don't try to create more than one messaging channel on MacOS
//
//
//  Created by Sergey Mamontov on 12/12/12.
//
//

#import "PNConnectionChannel.h"
#import "PNMessageChannelDelegate.h"
#import "PNMacro.h"


#pragma mark Class forward

@class PNChannel;


#pragma mark - Public interface declaration

@interface PNMessagingChannel : PNConnectionChannel


#pragma mark - Properties

// Stores reference on delegate which is interested in messaging channel events
@property (nonatomic, pn_desired_weak) id<PNMessageChannelDelegate> messagingDelegate;


#pragma mark - Class methods

/**
 Return reference on configured messages communication channel with specified delegate.

 @param configuration
 Reference on \b PNConfiguration instance which should be used by connection channel and accompany classes.

 @param delegate
 Reference on delegate which will accept all general callbacks from underlay connection channel class.

 @return Reference on fully configured and ready to use instance.
 */
+ (PNMessagingChannel *)messageChannelWithConfiguration:(PNConfiguration *)configuration
                                            andDelegate:(id<PNConnectionChannelDelegate>)delegate;


#pragma mark - Instance methods

#pragma mark - Connection management

/**
 * This method allow to disconnect communication channel from remote PubNub services and perform channel
 * reset if required
 */
- (void)disconnectWithReset:(BOOL)shouldResetCommunicationChannel;


#pragma mark - Channels management

- (NSArray *)subscribedChannels;
- (NSArray *)fullSubscribedChannelsList;

- (BOOL)isSubscribedForChannel:(PNChannel *)channel;

/**
 Check whether channel is able and will restore subscription on set of channels.
 */
- (void)checkWillRestoreSubscription:(void (^)(BOOL willRestore))checkCompletionBlock;

/**
 Method will initiate subscription on specified set of channels. This request will add provided channels set to the
 list of channels on which client already subscribed.

 @param channels
 List of \b PNChannel instances on which it should subscribe.

 @note By default this method will generate presence event on channels on which client already subscribed.
 */
- (void)subscribeOnChannels:(NSArray *)channels;

/**
 Method will initiate subscription on specified set of channels. This request will add provided channels set to the
 list of channels on which client already subscribed.

 @code
 @endcode
 This method extends \a -subscribeOnChannels: and allow to specify whether presence event should be generated or not.

 @param channels
 List of \b PNChannel instances on which it should subscribe.

 @param shouldCatchUp
 Specify whether client should forcibly use last time token or use configuration value.

 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.
 */
- (void)subscribeOnChannels:(NSArray *)channels
                withCatchUp:(BOOL)shouldCatchUp
             andClientState:(NSDictionary *)clientState;

/**
 * Will unsubscribe client from set of channels. Specified set of channels will be removed from the list of
 * subscribed channels. Leave event will be sent on provided list of channels.
 */
- (void)unsubscribeFromChannels:(NSArray *)channels;


#pragma mark - Presence observation management

- (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel;

/**
 Method will retrieve list of channels for which presence observation has been enabled at this moment.
 
 @return List may contain channels at which client not subscribed at this moment (it is not required it to be subscribed
 on those channels, but presence can be enabled on them).
 */
- (NSArray *)presenceEnabledChannels;

- (void)enablePresenceObservationForChannels:(NSArray *)channels;
- (void)disablePresenceObservationForChannels:(NSArray *)channels;

#pragma mark -


@end
