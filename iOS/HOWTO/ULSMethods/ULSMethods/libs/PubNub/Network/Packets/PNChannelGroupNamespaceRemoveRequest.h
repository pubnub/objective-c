//
//  PNChannelGroupNamespaceRemoveRequest.h
//  pubnub
//
//  Created by Sergey Mamontov on 9/21/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNBaseRequest.h"


#pragma mark Public interface declaration

@interface PNChannelGroupNamespaceRemoveRequest : PNBaseRequest


#pragma mark - Class methods

/**
 Construct request for namespace removal from \b PubNub channel registry.
 
 @param nspace
 Name of the namespace which should be removed.
 
 @return Ready to use \b PNChannelGroupNamespaceRemoveRequest instance.
 */
+ (PNChannelGroupNamespaceRemoveRequest *)requestToRemoveNamespace:(NSString *)nspace;


#pragma mark - Instance methods

/**
 Initialize request for namespace removal from \b PubNub channel registry.
 
 @param nspace
 Name of the namespace which should be removed.
 
 @return Ready to use \b PNChannelGroupNamespaceRemoveRequest instance.
 */
- (id)initWithNamespace:(NSString *)nspace;

#pragma mark -


@end
