//
//  PNMessagingChannel+Test.m
//  pubnub
//
//  Created by Valentin Tuller on 3/21/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNMessagingChannel+Test.h"
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"
#import "PNMessagePostRequest.h"
#import "PNMessagePostRequest+Protected.h"
#import "PNServiceChannelDelegate.h"

@implementation PNMessagingChannel (Test)

- (void)requestsQueue:(PNRequestsQueue *)queue willSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue willSendRequest:request];


    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @"[CHANNEL::%@] WILL START REQUEST PROCESSING: %@ [BODY: %@](STATE: %d)",
          self, request, request.debugResourcePath, self.messagingState);

    // Check whether connection should be closed for resubscribe
    // or not
    if (request.shouldCloseConnection) {

        // Mark that we don't need to close connection after next time
        // this request will be scheduled for processing
        // (this will happen right after connection will be restored)
        request.closeConnection = NO;


        // Reconnect communication channel
        [self reconnect];
    }
	[[NSNotificationCenter defaultCenter] postNotificationName: @"PNMessagingChannelWillSendRequest" object: request];
}


@end
