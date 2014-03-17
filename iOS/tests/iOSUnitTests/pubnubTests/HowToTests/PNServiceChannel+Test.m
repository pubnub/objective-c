//
//  PNServiceChannel+Test.m
//  pubnub
//
//  Created by Valentin Tuller on 2/14/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNServiceChannel+Test.h"
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"
#import "PNMessagePostRequest.h"
#import "PNMessagePostRequest+Protected.h"
#import "PNServiceChannelDelegate.h"

@implementation PNServiceChannel (Test)


- (void)requestsQueue:(PNRequestsQueue *)queue willSendRequest:(PNBaseRequest *)request {

    // Forward to the super class
    [super requestsQueue:queue willSendRequest:request];


    PNLog(PNLogCommunicationChannelLayerInfoLevel, self, @" WILL START REQUEST PROCESSING: %@ [BODY: %@]",
          request,
          request.debugResourcePath);


    // Check whether this is 'Message post' request or not
    if ([request isKindOfClass:[PNMessagePostRequest class]]) {

        // Notify delegate about that message post request will be sent now
        [self.serviceDelegate serviceChannel:self willSendMessage:((PNMessagePostRequest *)request).message];
    }

	[[NSNotificationCenter defaultCenter] postNotificationName: @"PNServiceChannelWillSendRequest" object: request];
}

@end
