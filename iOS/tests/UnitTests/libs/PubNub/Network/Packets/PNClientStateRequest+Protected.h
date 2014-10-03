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
 Stores reference on channel from which state for concrete client identifier should be pulled out.
 */
@property (nonatomic, strong) PNChannel *channel;

/**
 Storing configuration dependant parameters
 */
@property (nonatomic, copy) NSString *subscriptionKey;

#pragma mark -


@end
