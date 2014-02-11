//
//  PNClientStateRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 1/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNClientStateRequest.h"


#pragma mark Private interface declaration

@interface PNClientStateRequest ()


#pragma mark - Properties

/**
 Store reference on client identifier for which state requested.
 */
@property (nonatomic, copy) NSString *clientIdentifier;

/**
 Stores reference on channel from which state for concrete client identifier should be pulled out.
 */
@property (nonatomic, strong) PNChannel *channel;

#pragma mark -


@end
