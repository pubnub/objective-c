//
//  PNAppDelegate.h
//  SendMessageMac
//
//  Created by Valentin Tuller on 4/3/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PNAppDelegate : NSObject <NSApplicationDelegate, PNDelegate>
{
	PNChannel *pnChannel;
	NSArray *messages;
	int numberMessage;
	NSTimer *timerReset;

	int numberConfiguration;
	int timeout;
}

@property (assign) IBOutlet NSWindow *window;
@property IBOutlet NSTextView *tbxLog;

@end
