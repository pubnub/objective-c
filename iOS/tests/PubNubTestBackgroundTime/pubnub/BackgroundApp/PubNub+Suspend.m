//
//  PubNub+Suspend.m
//  pubnubTestBackground
//
//  Created by Valentin Tuller on 10/18/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PubNub+Suspend.h"
#import "PubNub.h"
#import "PNBackgroundAppDelegate.h"

@implementation PubNub (Suspend)

- (void)connectionChannelDidSuspend:(PNConnectionChannel *)channel {
    if ([[PubNub subscribedChannels] count] > 0) {
		PNBackgroundAppDelegate *delegate = (PNBackgroundAppDelegate *)[[UIApplication sharedApplication] delegate];
		delegate.lastTimeToken = [[[PubNub subscribedChannels] lastObject] updateTimeToken];
    }
}

- (void)connectionChannelWillResume:(PNConnectionChannel *)channel {

    //
}

- (void)connectionChannelDidResume1:(PNConnectionChannel *)channel {

    [self warmUpConnection:channel];

    // Check whether on resume there is no async locking operation is running
    if (![self isAsyncLockingOperationInProgress]) {

        [self handleLockingOperationComplete:YES];
    }

	PNBackgroundAppDelegate *delegate = (PNBackgroundAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([[PubNub subscribedChannels] count] > 0) {
		NSString *newToken = [[[PubNub subscribedChannels] lastObject] updateTimeToken];
		NSLog(@"tokens \n%@\n%@", newToken, delegate.lastTimeToken);

		if( [delegate.lastTimeToken isEqualToString: newToken] == YES ) {
			[PubNub sendMessage:@"Hello PubNub" toChannel: [[PubNub subscribedChannels] lastObject]
			withCompletionBlock:^(PNMessageState messageSendingState, id data)
			 {
				 [delegate performSelector: @selector(openUrl) withObject: nil afterDelay: 5.0];
			 }];
		}
		else
			[delegate performSelector: @selector(errorSelector) withObject: nil];
	}
}


@end
