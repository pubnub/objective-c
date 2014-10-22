//
//  PNChannelGroupsRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNBaseRequest.h"


#pragma mark Public interface declaration

@interface PNChannelGroupsRequest : PNBaseRequest


#pragma mark - Class methods

/**
 Construct channel groups request for specific namespace.
 
 @param nspace
 Name of namespace from which channel groups should be retrieved.
 
 @return Ready to use \b PNChannelGroupsRequest request.
 */
+ (PNChannelGroupsRequest *)channelGroupsRequestForNamespace:(NSString *)nspace;


#pragma mark - Instance methods

/**
 Initialize channel groups request for specific namespace.
 
 @param nspace
 Name of namespace from which channel groups should be retrieved.
 
 @return Ready to use \b PNChannelGroupsRequest request.
 */
- (id)initWithNamespace:(NSString *)nspace;

#pragma mark -


@end
