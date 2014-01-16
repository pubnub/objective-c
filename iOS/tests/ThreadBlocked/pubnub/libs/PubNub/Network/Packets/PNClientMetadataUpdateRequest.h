//
//  PNClientMetadataUpdateRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 1/13/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNBaseRequest.h"


#pragma mark Public interface declaration

@interface PNClientMetadataUpdateRequest : PNBaseRequest


#pragma mark - Class methods

/**
 Construct and initialize request which will allow to update client metadata on concrete channel.

 @param clientIdentifier
 Stores reference on client identifier for which metadata should be updated.

 @param channel
 Stores reference on \b PNChannel instance at which metadata should be updated.

 @param metadata
 Valid dictionary with keys which will be added to the client metadata on specified channel.

 @return Ready to use \b PNClientMetadataUpdateRequest instance,
 */
+ (PNClientMetadataUpdateRequest *)clientMetadataUpdateRequestWithIdentifier:(NSString *)clientIdentifier
                                                                     channel:(PNChannel *)channel
                                                                 andMetadata:(NSDictionary *)metadata;


#pragma mark - Instance methods

/**
 Initialize request which will allow to update client metadata on concrete channel.

 @param clientIdentifier
 Stores reference on client identifier for which metadata should be updated.

 @param channel
 Stores reference on \b PNChannel instance at which metadata should be updated.

 @param metadata
 Valid dictionary with keys which will be added to the client metadata on specified channel.

 @return Initialized \b PNClientMetadataUpdateRequest instance,
 */
- (id)initWithIdentifier:(NSString *)clientIdentifier channel:(PNChannel *)channel andMetadata:(NSDictionary *)metadata;

#pragma mark -


@end
