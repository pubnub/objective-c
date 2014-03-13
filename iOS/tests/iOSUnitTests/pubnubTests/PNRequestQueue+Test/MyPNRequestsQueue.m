//
//  MyPNRequestsQueue.m
//  pubnub
//
//  Created by Valentin Tuller on 2/28/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "MyPNRequestsQueue.h"

@implementation MyPNRequestsQueue

- (void)connection:(PNConnection *)connection didSendRequestWithIdentifier:(NSString *)requestIdentifier {

    PNBaseRequest *processedRequest = [self dequeRequestWithIdentifier:requestIdentifier];
	[[NSNotificationCenter defaultCenter] postNotificationName: @"didSendRequest" object: processedRequest];

	[super connection: connection didSendRequestWithIdentifier: requestIdentifier];
}

@end
