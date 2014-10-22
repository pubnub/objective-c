//
//  PNChannelsForGroupRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/17/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNChannelGroup;


#pragma mark - Public interface declaration

@interface PNChannelsForGroupRequest : PNBaseRequest


#pragma mark - Class methods

/**
 Construct channels list for group request.
 
 @param group
 Channel group information instance.
 
 @return Ready to use \b PNChannelsForGroupRequest request.
 */
+ (PNChannelsForGroupRequest *)channelsRequestForGroup:(PNChannelGroup *)group;


#pragma mark - Instance methods

/**
 Initialize channel groups request for specific namespace.
 
 @param group
 Channel group information instance.
 
 @return Ready to use \b PNChannelsForGroupRequest request.
 */
- (id)initWithGroup:(PNChannelGroup *)group;

#pragma mark -


@end
