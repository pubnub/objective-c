//
//  PNPrivateStructures.h
//  pubnub
//
//  Created by Sergey Mamontov on 8/27/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#ifndef PNPrivateStructures_h
#define PNPrivateStructures_h

// This enum represent possible stream
// states
typedef enum _PNSocketStreamState {

    // Stream not configured
    PNSocketStreamNotConfigured,

    // Stream configured by connection manager
    PNSocketStreamReady,

    // Stream is connecting at this moment
    PNSocketStreamConnecting,

    // Stream connected to the origin server
    // over socket (secure if configured)
    PNSocketStreamConnected,

    // Stream failure (not connected) because
    // of error
    PNSocketStreamError
} PNSocketStreamState;

#endif // PNPrivateStructures_h
