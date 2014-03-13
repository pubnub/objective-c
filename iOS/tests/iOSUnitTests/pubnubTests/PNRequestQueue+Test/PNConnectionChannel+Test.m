//
//  PNConnectionChannel+Test.m
//  pubnub
//
//  Created by Valentin Tuller on 2/28/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNConnectionChannel+Test.h"
#import "PNPrivateMacro.h"
#import "MyPNRequestsQueue.h"

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

//struct PNConnectionIdentifiersStruct PNConnectionIdentifiers = {
//
//    .messagingConnection = @"PNMessagingConnectionIdentifier",
//    .serviceConnection = @"PNServiceConnectionIdentifier"
//};


@implementation PNConnectionChannel (Test)

- (id)initWithType:(PNConnectionChannelType)connectionChannelType andDelegate:(id<PNConnectionChannelDelegate>)delegate {

    // Check whether initialization was successful or not
    if((self = [super init])) {

        self.delegate = delegate;
		unsigned long _state = 0;
        PNBitClear(&_state);
        self.observedRequests = [NSMutableDictionary dictionary];
        self.storedRequests = [NSMutableDictionary dictionary];
        self.storedRequestsList = [NSMutableArray array];


        // Retrieve connection identifier based on connection channel type
//        self.name = PNConnectionIdentifiers.messagingConnection;
		self.name = @"PNMessagingConnectionIdentifier";
        if (connectionChannelType == PNConnectionChannelService) {

//            self.name = PNConnectionIdentifiers.serviceConnection;
			self.name = @"PNServiceConnectionIdentifier";
        }

        // Set initial connection channel state
        PNBitOff(&_state, PNConnectionChannelDisconnected);


        // Initialize connection to the PubNub services
        self.requestsQueue = [MyPNRequestsQueue new];
        self.requestsQueue.delegate = self;
        [self connect];
    }


    return self;
}

@end
