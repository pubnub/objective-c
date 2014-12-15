//
//  PNClientStateRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 1/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNChannel;


#pragma mark - Public interface declaration

@interface PNClientStateRequest : PNBaseRequest


#pragma mark - Class methods

/**
 Construct and initialize request which will allow to pull out state for client.

 @param clientIdentifier
 Client identifier which should be used for state retrieval request.

 @param channel
 \b PNChannel instance of the channel from which state for \c clientIdentifier should be pulled out.

 @return Ready to use \b PNClientStateRequest instance.
 */
+ (PNClientStateRequest *)clientStateRequestForIdentifier:(NSString *)clientIdentifier andChannel:(PNChannel *)channel;


#pragma mark - Instance methods

/**
 Initialize request with specific client identifier.

 @param clientIdentifier
 Client identifier which should be used for state retrieval request.

 @param channel
 \b PNChannel instance of the channel from which state for \c clientIdentifier should be pulled out.
 @return Initialized \b PNClientStateRequest instance.
 */
- (id)initWithIdentifier:(NSString *)clientIdentifier andChannel:(PNChannel *)channel;

#pragma mark -


@end
