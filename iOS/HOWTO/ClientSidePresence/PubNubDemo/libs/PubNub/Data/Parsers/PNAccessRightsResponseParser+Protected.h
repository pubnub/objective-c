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


// Stores reference on key under which access level is stored in response
static NSString * const kPNAccessLevelKey = @"level";

// Stores reference on key under which application identifier is stored (\a 'subscribe' key).
static NSString * const kPNApplicationIdentifierKey = @"subscribe_key";

// Stores reference on key under which channel name is stored in response
static NSString * const kPNAccessChannelKey = @"channel";

// Stores reference on key under which stored information about how long granted access rights will be valid.
static NSString * const kPNAccessRightsPeriodKey = @"ttl";

// Stores reference on key under which affected channel groups list is stored in response
static NSString * const kPNAccessChannelGroupsKey = @"channel-groups";

// Stores reference on key under which affected channels list is stored in response
static NSString * const kPNAccessChannelsKey = @"channels";

/**
 Stores reference on key under which stored list of authentication keys for which access rights has been
 changed / retrieved.
 */
static NSString * const kPNAccessChannelsAuthorizationKey = @"auths";

/**
 Stores reference on key under which stored list of client authorization keys for which access rights has been
 changed / retrieved.
 */
static NSString * const kPNAccessClientAuthorizationKey = @"auths";

// Stores reference on key under which \a 'read' rights state is stored.
static NSString * const kPNReadAccessRightStateKey = @"r";

// Stores reference on key under which \a 'management' rights state is stored.
static NSString * const kPNManagementAccessRightStateKey = @"m";

// Stores reference on key under which \a 'write' rights state is stored.
static NSString * const kPNWriteAccessRightStateKey = @"w";

// Stores reference on responsible service
static NSString * const kPNAccessServiceName = @"Access Manager";


#endif // _PNAccessRightsResponseParser_Protected
