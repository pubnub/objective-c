//
//  PNChannelGroupsRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/16/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelGroupsRequest.h"


#pragma mark Private interface declaration

@interface PNChannelGroupsRequest ()


#pragma mark - Properties

/**
 Stores reference on namespace from which channel groups should be pulled out.
 */
@property (nonatomic, copy) NSString *namespaceName;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;

#pragma mark -


@end
