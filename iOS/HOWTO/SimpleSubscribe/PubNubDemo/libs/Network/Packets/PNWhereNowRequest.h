//
//  PNWhereNowRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 1/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//


#import "PNBaseRequest.h"


#pragma mark Private interface declaration

@interface PNWhereNowRequest : PNBaseRequest


#pragma mark - Class methods

/**
 Create and initialize request which will allow retrieve list of channels on which specified client subscribed.

 @param clientIdentifier
 Client identifier for which service should find channels on which it subscribed at this moment.

 @return Ready to use \b PNWhereNowRequest instance.
 */
+ (PNWhereNowRequest *)whereNowRequestForIdentifier:(NSString *)clientIdentifier;


#pragma mark - Instance methods

/**
 Initialize request with specific client identifier.

 @param clientIdentifier
 Client identifier for which service should find channels on which it subscribed at this moment.

 @return Initialized \b PNWhereNowRequest instance.
 */
- (id)initWithIdentifier:(NSString *)clientIdentifier;

#pragma mark -


@end
