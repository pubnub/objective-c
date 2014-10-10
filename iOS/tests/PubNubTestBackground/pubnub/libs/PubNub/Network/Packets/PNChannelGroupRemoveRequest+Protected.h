//
//  PNChannelGroupRemoveRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/21/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelGroupRemoveRequest.h"
#import "PNChannelGroup.h"


#pragma mark Private interface declaration

@interface PNChannelGroupRemoveRequest ()


#pragma mark - Properties

/**
 Stores reference on channel group which should be removed.
 */
@property (nonatomic, strong) PNChannelGroup *group;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;

#pragma mark -


@end
