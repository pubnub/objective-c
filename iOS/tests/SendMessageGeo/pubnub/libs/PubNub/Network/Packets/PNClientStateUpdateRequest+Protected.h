//
//  PNClientStateUpdateRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 1/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNClientStateUpdateRequest.h"


#pragma mark Private interface declaration

@interface PNClientStateUpdateRequest ()


#pragma mark - Properties

/**
 Store reference on client identifier for which state will be updated.
 */
@property (nonatomic, copy) NSString *clientIdentifier;

/**
 Stores reference on channel which will hold updated state for concrete client identifier.
 */
@property (nonatomic, strong) PNChannel *channel;

/**
 Stores reference on state dictionary which will be pushed to the channel in bound to client identifier,
 */
@property (nonatomic, strong) NSDictionary *state;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;

#pragma mark -


@end
