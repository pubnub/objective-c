//
//  PNChannelsForGroupRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/17/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelsForGroupRequest.h"


#pragma mark Class forward

@class PNChannelGroup;


#pragma mark Private interface declaration

@interface PNChannelsForGroupRequest ()


#pragma mark - Properties

/**
 Stores reference on group for which channels list requested.
 */
@property (nonatomic, strong) PNChannelGroup *group;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;

#pragma mark -


@end
