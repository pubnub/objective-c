//
//  PNClientStateUpdateRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 1/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNBaseRequest.h"


#pragma mark Class forward

@class PNChannel;


#pragma mark - Public interface declaration

@interface PNClientStateUpdateRequest : PNBaseRequest


#pragma mark - Class methods

/**
 Construct and initialize request which will allow to update client state on concrete channel.

 @param clientIdentifier
 Stores reference on client identifier for which state should be updated.

 @param channel
 Stores reference on \b PNChannel instance at which state should be updated.

 @param clientState
 Valid dictionary with keys which will be added to the client state on specified channel.

 @return Ready to use \b PNClientStateUpdateRequest instance,
 */
+ (PNClientStateUpdateRequest *)clientStateUpdateRequestWithIdentifier:(NSString *)clientIdentifier
                                                               channel:(PNChannel *)channel
                                                        andClientState:(NSDictionary *)clientState;


#pragma mark - Instance methods

/**
 Initialize request which will allow to update client state on concrete channel.

 @param clientIdentifier
 Stores reference on client identifier for which state should be updated.

 @param channel
 Stores reference on \b PNChannel instance at which state should be updated.

 @param clientState
 Valid dictionary with keys which will be added to the client state on specified channel.

 @return Initialized \b PNClientStateUpdateRequest instance,
 */
- (id)initWithIdentifier:(NSString *)clientIdentifier channel:(PNChannel *)channel andClientState:(NSDictionary *)clientState;

#pragma mark -


@end
