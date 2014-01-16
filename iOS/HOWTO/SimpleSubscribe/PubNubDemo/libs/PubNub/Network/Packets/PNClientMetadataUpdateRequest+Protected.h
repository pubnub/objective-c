//
//  PNClientMetadataUpdateRequest+Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 1/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNClientMetadataUpdateRequest.h"


#pragma mark Private interface declaration

@interface PNClientMetadataUpdateRequest ()


#pragma mark - Properties

/**
 Store reference on client identifier for which metadata will be updated.
 */
@property (nonatomic, copy) NSString *clientIdentifier;

/**
 Stores reference on channel which will hold updated metadata for concrete client identifier.
 */
@property (nonatomic, strong) PNChannel *channel;

/**
 Stores reference on metadata dictionary which will be pushed to the channel in bound to client identifier,
 */
@property (nonatomic, strong) NSDictionary *metadata;

#pragma mark -


@end
