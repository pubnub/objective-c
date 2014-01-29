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

- (void)connectionChannelDidSuspend1:(PNConnectionChannel *)channel {
    if ([[PubNub subscribedChannels] count] > 0) {
		PNBackgroundAppDelegate *delegate = (PNBackgroundAppDelegate *)[[UIApplication sharedApplication] delegate];
		delegate.lastTimeToken = [[[PubNub subscribedChannels] lastObject] updateTimeToken];
    }
}

@end
