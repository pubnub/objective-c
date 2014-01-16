//
//  PNClientMetadataRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 1/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNClientMetadataRequest.h"


#pragma mark Private interface declaration

@interface PNClientMetadataRequest ()


#pragma mark - Properties

/**
 Store reference on client identifier for which metadata requested.
 */
@property (nonatomic, copy) NSString *clientIdentifier;

/**
 Stores reference on channel from which metadata for concrete client identifier should be pulled out.
 */
@property (nonatomic, strong) PNChannel *channel;

#pragma mark -


@end
