//
//  PNSubscriptionHelper.h
//  pubnub
//
//  Created by Sergey Mamontov on 3/23/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark Public interface declaration

@interface PNSubscriptionHelper : NSObject


#pragma mark - Instance methods

/**
 Store provided channel in dictionary along with client't state which should be used for concrete channel.
 
 @param channel
 Reference on \b PNChannel on which client will subscribe.
 
 @param channelState
 Reference on valid \b NSDictionary instance which represent client's state.
 
 @param shouldObservePresence
 Whether channel is made to observer presence observation.
 */
- (void)addChannel:(PNChannel *)channel withState:(NSDictionary *)channelState andPresenceObservation:(BOOL)shouldObservePresence;

/**
 Remove concrete channel from the list which will be used for subscription.
 */
- (void)removeChannel:(PNChannel *)channel;

/**
 Method will compose list of channels (taking into account whether client already subscribed on them or not).
 
 @return List of channels on which client should subscribe (minus channels on which client already subscribed).
 */
- (NSArray *)channelsForSubscription;

/**
 Merge all individual channel states into single which will be used during subscription.
 
 @return Merged state for all channels on which client should subscribe.
 */
- (NSDictionary *)channelsState;

/**
 Retrieve reference on state which has been stored for concrete channel.
 
 @param channel
 \b PNChannel instance for which state should be retrieved.
 
 @return Valid state whhich has been stored for concrete channel.
 */
- (NSDictionary *)stateForChannel:(PNChannel *)channel;

/**
 Verify whether presence observation should be enabled for specified channel or not.
 
 @param channel
 \b PNChannel instance against which check should be performed.
 
 @return \c YES if channel is supposed to receive presence notifications.
 */
- (BOOL)shouldObserverPresenceForChannel:(PNChannel *)channel;

/**
 Reset client subscribe helper cached data.
 */
- (void)reset;

#pragma mark -


@end
