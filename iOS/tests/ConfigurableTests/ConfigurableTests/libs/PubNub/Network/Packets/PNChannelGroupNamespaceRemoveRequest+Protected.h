//
//  PNChannelGroupNamespaceRemoveRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/21/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNChannelGroupNamespaceRemoveRequest.h"


#pragma mark Private interface declaration

@interface PNChannelGroupNamespaceRemoveRequest ()


#pragma mark - Properties

/**
 Stores reference on namespace which should be removed.
 */
@property (nonatomic, copy) NSString *namespaceName;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;

#pragma mark -


@end
