//
//  PNClientMetadataRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 1/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNBaseRequest.h"


#pragma mark Public interface declaration

@interface PNClientMetadataRequest : PNBaseRequest


#pragma mark - Class methods

/**
 Construct and initialize request which will allow to pull out metadata for client.

 @param clientIdentifier
 Client identifier which should be used for metadata retrieval request.

 @param channel
 \b PNChannel instance of the channel from which metadata for \c clientIdentifier should be pulled out.

 @return Ready to use \b PNClientMetadataRequest instance.
 */
+ (PNClientMetadataRequest *)clientMetadataRequestForIdentifier:(NSString *)clientIdentifier andChannel:(PNChannel *)channel;


#pragma mark - Instance methods

/**
 Initialize request with specific client identifier.

 @param clientIdentifier
 Client identifier which should be used for metadata retrieval request.

 @param channel
 \b PNChannel instance of the channel from which metadata for \c clientIdentifier should be pulled out.
 @return Initialized \b PNClientMetadataRequest instance.
 */
- (id)initWithIdentifier:(NSString *)clientIdentifier andChannel:(PNChannel *)channel;

#pragma mark -


@end
