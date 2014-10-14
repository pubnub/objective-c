//
//  PNChannelGroupRemoveRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/21/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNChannelGroup;


#pragma mark - Public interface declaration

@interface PNChannelGroupRemoveRequest : PNBaseRequest


#pragma mark - Class methods

/**
 Construct request for channel group removal from \b PubNub channel registry.
 
 @param nspace
 Name of the namespace which should be removed.
 
 @return Ready to use \b PNChannelGroupRemoveRequest instance.
 */
+ (PNChannelGroupRemoveRequest *)requestToRemoveGroup:(PNChannelGroup *)group;


#pragma mark - Instance methods

/**
 Initialize request for channel group removal from \b PubNub channel registry.
 
 @param nspace
 Name of the namespace which should be removed.
 
 @return Ready to use \b PNChannelGroupRemoveRequest instance.
 */
- (id)initWithGroup:(PNChannelGroup *)group;

#pragma mark -


@end
