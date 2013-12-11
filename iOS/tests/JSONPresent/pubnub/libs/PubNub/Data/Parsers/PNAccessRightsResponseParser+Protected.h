//
//  PNChannelAccessRightsChangeParser_Protected.h
//  pubnub
//
//  Created by Sergey Mamontov on 10/28/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//


#import "PNAccessRightsResponseParser.h"


#ifndef _PNAccessRightsResponseParser_Protected
#define _PNAccessRightsResponseParser_Protected


// Stores reference on key which is used to store operation status in response
static NSString * const kPNResponseStatusKey = @"status";

// Stores reference on key which is used to store operation status message in response
static NSString * const kPNResponseMessageKey = @"message";

// Stores reference on key which is used to store access information payload in response
static NSString * const kPNResponsePayloadKey = @"payload";

// Stores reference on key under which access level is stored in response
static NSString * const kPNAccessLevelKeyPath = @"payload.level";

// Stores reference on key under which application identifier is stored (\a 'subscribe' key).
static NSString * const kPNApplicationIdentifierKeyPath = @"payload.subscribe_key";

// Stores reference on key under which channel name is stored in response
static NSString * const kPNAccessChannelKeyPath = @"payload.channel";

// Stores reference on key under which stored information about how long granted access rights will be valid.
static NSString * const kPNAccessRightsPeriodKeyPath = @"payload.ttl";
static NSString * const kPNAccessRightsPeriodKey = @"ttl";

// Stores reference on key under which affected channels list is stored in response
static NSString * const kPNAccessChannelsKeyPath = @"payload.channels";

/**
 Stores reference on key under which stored list of authentication keys for which access rights has been
 changed / retrieved.
 */
static NSString * const kPNAccessChannelsAuthorizationKey = @"auths";

/**
 Stores reference on key under which stored list of client authorization keys for which access rights has been
 changed / retrieved.
 */
static NSString * const kPNAccessClientAuthorizationKeyPath = @"payload.auths";

// Stores reference on key under which \a 'read' rights state is stored.
static NSString * const kPNReadAccessRightStateKey = @"r";

// Stores reference on key under which \a 'write' rights state is stored.
static NSString * const kPNWriteAccessRightStateKey = @"w";

// Stores reference on responsible service
static NSString * const kPNAccessServiceName = @"Access Manager";


#endif // _PNAccessRightsResponseParser_Protected
