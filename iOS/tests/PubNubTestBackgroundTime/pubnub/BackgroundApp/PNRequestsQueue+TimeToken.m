//
//  PNRequestsQueue+TimeToken.m
//  pubnubTestBackground
//
//  Created by Valentin Tuller on 10/24/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNRequestsQueue+TimeToken.h"
#import "PNSubscribeRequest.h"
#import "PNBackgroundAppDelegate.h"

@implementation PNRequestsQueue (TimeToken)


- (void)connection:(PNConnection *)connection processingRequestWithIdentifier:(NSString *)requestIdentifier {

    // Mark request as in processing state
    PNBaseRequest *currentRequest = [self performSelector: @selector(dequeRequestWithIdentifier:) withObject: requestIdentifier];

	if( [currentRequest isKindOfClass: [PNSubscribeRequest class]] == YES ) {
		PNBackgroundAppDelegate *delegate = (PNBackgroundAppDelegate *)[[UIApplication sharedApplication] delegate];
		PNSubscribeRequest *subscribeRequest = (PNSubscribeRequest*)currentRequest;
		NSString *newTimeToken = [subscribeRequest performSelector:@selector(updateTimeToken)];

		if( delegate.lastClientIdentifier != nil && [delegate.lastClientIdentifier isEqualToString:[PubNub clientIdentifier]] == NO )
			[delegate performSelector: @selector(errorSelectorDifferentClientId) withObject: nil];
		NSLog(@"\nclient id old %@ \nclient id new %@", delegate.lastClientIdentifier, [PubNub clientIdentifier]);
		if( delegate.lastTimeToken == nil || [delegate.lastTimeToken isEqualToString: @"0"] == YES )
			delegate.lastTimeToken = nil;
		else {
			NSLog(@"tokens \n%@\n%@", newTimeToken, delegate.lastTimeToken);
			if( [delegate.lastTimeToken isEqualToString: newTimeToken] == YES ) {
				[PubNub sendMessage:@"Hello PubNub" toChannel: [[PubNub subscribedChannels] lastObject]
				withCompletionBlock:^(PNMessageState messageSendingState, id data)
				 {
					 [delegate performSelector: @selector(openUrl) withObject: nil afterDelay: 5.0];
				 }];
			}
			else
				[delegate performSelector: @selector(errorSelectorDifferentTimeToken) withObject: nil];

			delegate.lastTimeToken = nil;
		}
	}

    if (currentRequest != nil) {

        /// Forward request processing start to the delegate
        [self.delegate requestsQueue:self willSendRequest:currentRequest];
    }
}

@end
