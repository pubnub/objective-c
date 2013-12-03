//
//  PubNub+Suspend.m
//  pubnubTestBackground
//
//  Created by Valentin Tuller on 10/18/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PubNub+Suspend.h"
#import "PubNub.h"
#import "ConnectionIssuesAppDelegate.h"

@implementation PubNub (Suspend)


- (void)connectionChannelDidResume1:(PNConnectionChannel *)channel {

    [self warmUpConnection:channel];

    // Check whether on resume there is no async locking operation is running
    if (![self isAsyncLockingOperationInProgress]) {

        [self handleLockingOperationComplete:YES];
    }

	ConnectionIssuesAppDelegate *delegate = (ConnectionIssuesAppDelegate *)[[UIApplication sharedApplication] delegate];
	[delegate startTest];
}


@end
