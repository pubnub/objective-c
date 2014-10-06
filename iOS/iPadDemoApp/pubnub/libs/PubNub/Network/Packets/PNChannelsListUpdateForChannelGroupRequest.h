//
//  PNChannelsListUpdateForChannelGroupRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/18/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNChannelGroup;


#pragma mark - Public interface declaration

@interface PNChannelsListUpdateForChannelGroupRequest : PNBaseRequest


#pragma mark - Class methods

/**
 Construct request for channels list addition inside channel group.
 
 @param channels
 List of \b PNChannel instances which should be added to channel group.
 
 @param group
 Channel group information instance.
 
 @return Ready to use \b PNChannelsListUpdateForChannelGroupRequest request.
 */
+ (PNChannelsListUpdateForChannelGroupRequest *)channelsListAddition:(NSArray *)channels
                                                     forChannelGroup:(PNChannelGroup *)group;

/**
 Construct request for channels list removal inside channel group.
 
 @param channels
 List of \b PNChannel instances which should be removed from channel group.
 
 @param group
 Channel group information instance.
 
 @return Ready to use \b PNChannelsListUpdateForChannelGroupRequest request.
 */
+ (PNChannelsListUpdateForChannelGroupRequest *)channelsListRemoval:(NSArray *)channels forChannelGroup:(PNChannelGroup *)group;


#pragma mark - Instance methods

/**
 Checking whether request has been created for channels addition into channel group or not.
 
 @return \c NO in case if request has been created to remove set of channels from channel group.
 */
- (BOOL)isChannelAdditionRequest;

#pragma mark -


@end
