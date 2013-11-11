//
//  PNConnectionChannel+Reconnect.m
//  pubnub
//
//  Created by Valentin Tuller on 11/11/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNConnectionChannel+Reconnect.h"
#import "PNAppDelegate.h"

@implementation PNConnectionChannel (Reconnect)

typedef NS_OPTIONS(NSUInteger, PNConnectionStateFlag)  {

    // Channel trying to establish connection to PubNub services
    PNConnectionChannelConnecting = 1 << 0,

    // Channel reconnecting with same settings which was used during initialization
    PNConnectionChannelReconnect = 1 << 1,

    // Channel is resuming it's operation state
    PNConnectionChannelResuming = 1 << 2,

    // Channel is ready for work (connections established and requests queue is ready)
    PNConnectionChannelConnected = 1 << 3,

    // Channel is transferring to suspended state
    PNConnectionChannelSuspending = 1 << 4,

    // Channel is in suspended state
    PNConnectionChannelSuspended = 1 << 5,

    // Channel is disconnecting on user request (for example: leave request for all channels)
    PNConnectionChannelDisconnecting = 1 << 6,

    // Channel is ready, but was disconnected and waiting command for connection (or was unable to connect during
    // initialization). All requests queue is alive (if they wasn't flushed by user)
    PNConnectionChannelDisconnected = 1 << 7
};

static void PNBitClear(unsigned long *flag);
void PNBitClear(unsigned long *flag) {

    *flag = 0;
}
static void PNBitOn(unsigned long *flag, unsigned long mask);
void PNBitOn(unsigned long *flag, unsigned long mask) {

    *flag |= mask;
}


- (void)reconnect {

    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] RECONNECTING BY REQUEST... (STATE: %d)",
          [self performSelector:@selector(name)], [self performSelector: @selector(state)]);

    BOOL isConnected = [self isConnected];
	unsigned long st = [self performSelector: @selector(state)];
    PNBitClear(&st);
    if (isConnected) {

        PNBitOn(&st, PNConnectionChannelConnected);
    }
    PNBitOn(&st, PNConnectionChannelReconnect);
	[self setState: st];

    [[self performSelector:@selector(connection)] reconnect];
	PNAppDelegate *delegate = (PNAppDelegate*)[[UIApplication sharedApplication] delegate];
	[delegate didConnectionReconnect];
}

@end
