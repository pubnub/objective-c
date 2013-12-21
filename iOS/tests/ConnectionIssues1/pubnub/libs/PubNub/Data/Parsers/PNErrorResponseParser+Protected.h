//
//  PNErrorResponseParser+Protected.h
//  pubnub
//
//  This header file used by library internal
//  components which require to access to some
//  methods and properties which shouldn't be
//  visible to other application components
//
//  Created by Sergey Mamontov.
//
//

#ifndef _PNErrorResponseParser_Protected
#define _PNErrorResponseParser_Protected

// Stores reference on key which stores error description (and whether is error)
static NSString * const kPNResponseErrorMessageKey = @"error";

// Stores reference on key under which additional error information is stored
static NSString * const kPNResponseErrorPayloadKey = @"payload";

// Stores reference on key under which list of channels on which error occurred is stored
static NSString * const kPNResponseErrorChannelsKey = @"channels";

#endif
