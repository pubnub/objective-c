//
//  PNHeartbeatRequest+Reset.m
//  pubnubTestBackground
//
//  Created by Valentin Tuller on 2/3/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNHeartbeatRequest+Reset.h"
#import "PNBackgroundAppDelegate.h"
#import "PNWriteBuffer.h"

@implementation PNHeartbeatRequest (Reset)

- (void)resetWithRetryCount:(BOOL)shouldResetRetryCountInformation {
	[self checkTimeInterval];

    if (shouldResetRetryCountInformation) {

        self.retryCount = 0;
    }
    self.processing = NO;
    self.processed = NO;
}

- (PNWriteBuffer *)buffer {
	[self checkTimeInterval];
    return [PNWriteBuffer writeBufferForRequest:self];
}

-(void)checkTimeInterval {
	PNBackgroundAppDelegate *delegate = (PNBackgroundAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSDate *date = [NSDate date];
	NSTimeInterval interval = [date timeIntervalSinceDate: delegate.lastResetCall];
	if( interval < 4.5 )
		[self performSelector: @selector(errorSelectorManyHeartbeat)];
	delegate.lastResetCall = date;
}

@end
