//
//  PNHeartbeatRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 1/7/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNChannel;


#pragma mark - Public interface declaration

@interface PNHeartbeatRequest : PNBaseRequest


#pragma mark - Properties

// Stores reference on channels list
@property (nonatomic, readonly, strong) NSArray *channels;


#pragma mark - Class methods

/**
 Create and initialize heartbeat request for single channel.

 @param channel
 \b PNChannel instance which identify target for which heartbeat should be sent.

 @param clientState
 \b NSDictionary instance which hold state information for concrete channel.

 @return Configured \b PNHeartbeatRequest request which can be used in lower layers.
 */
+ (PNHeartbeatRequest *)heartbeatRequestForChannel:(PNChannel *)channel withClientState:(NSDictionary *)clientState;

/**
 Create and initialize heartbeat request for set of channels.

 @param channels
 List of \b PNChannel instances which identify target for which heartbeat should be sent.

 @param clientState
 \b NSDictionary instance which hold list of state for all channels for which heartbeat request is preformed.

 @return Configured \b PNHeartbeatRequest request which can be used in lower layers.
 */
+ (PNHeartbeatRequest *)heartbeatRequestForChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState;


#pragma mark - Instance methods

/**
 Initialize heartbeat request for set of channels.

 @param channels
 List of \b PNChannel instances which identify target for which heartbeat should be sent.

 @param clientState
 \b NSDictionary instance which hold list of state for all channels for which heartbeat request is preformed.

 @return Initialized \b PNHeartbeatRequest request which can be used in lower layers.
 */
- (id)initWithChannels:(NSArray *)channels withClientState:(NSDictionary *)clientState;

#pragma mark -


@end
