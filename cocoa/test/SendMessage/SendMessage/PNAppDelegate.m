//
//  PNAppDelegate.m
//  SendMessage
//
//  Created by Valentin Tuller on 4/4/14.
//  Copyright (c) 2014 Valentin Tuller. All rights reserved.
//

#import "PNAppDelegate.h"

@interface PNAppDelegate ()
{
	int pNClientDidReceivePresenceEventNotification;
	int pNClientDidReceiveMessageNotification;
	int countExpectMessage;
}

@end

@implementation PNAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(kPNClientDidReceivePresenceEventNotification:)
							   name:kPNClientDidReceivePresenceEventNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(kPNClientDidReceiveMessageNotification:)
										 name:kPNClientDidReceiveMessageNotification object:nil];

	NSLog(@"applicationDidFinishLaunching %@", aNotification);
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
	[self connect];
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSLog(@"handleURLEvent %@", url);
}

- (void)connect
{
	PNConfiguration *configuration = [PNConfiguration defaultConfiguration];
	[PubNub setConfiguration: configuration];
	[PubNub connectWithSuccessBlock:^(NSString *origin) {
		PNChannel *pnChannel = [PNChannel channelWithName: [NSString stringWithFormat: @"chWithMessageMac"] shouldObservePresence: YES];
		[PubNub subscribeOnChannels: @[pnChannel] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
			 {
				 [self startSendCommand];
			 }];
	}
	errorBlock:^(PNError *connectionError) {}];
}

-(void)sendCommand:(NSString*)command
{
	[self addMessageToLog: [NSString stringWithFormat: @"send command: %@", command]];
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: [NSString stringWithFormat: @"mediator:///%@", [command stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]]];
}

-(void)addMessageToLog:(NSString*)message {
	[self.tbxLog moveToEndOfDocument:nil];
	[self.tbxLog insertText: [NSString stringWithFormat: @"%@%@ %@", @"\n", [NSDate date], message]];
}


-(void)startSendCommand
{
	int delay = 0;
	[self sendCommand: @"start"];

	delay += 3;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		pNClientDidReceivePresenceEventNotification = 0;
		[self sendCommand: @"connect chWithMessageMac"];
	});

	delay += 5;
	[self checkPresenceAfter: delay];

	[self send: 10 after: delay toChannelWithName: @"chWithMessageMac" andCheckAfter: delay+10];
	delay += 11;

	[self subscribeToChannelWithName: @"ch1" after: delay];

	[self send: 100 after: delay toChannelWithName: @"chWithMessageMac" andCheckAfter: delay+20];

	delay += 21;
	[self send: 100 after: delay toChannelWithName: @"chWithMessageMac" andCheckAfter: delay+20];

	delay += 30;
	[self send: 100 after: delay toChannelWithName: @"chWithMessageMac" andCheckAfter: delay+20];

	delay += 30;
	[self subscribeToChannelWithName:@"chWithMessageMac1" after: delay];

	delay += 5;
	[self checkPresenceAfter: delay];
}

-(void)send:(int)countMessage after:(int)after toChannelWithName:(NSString*)name andCheckAfter:(int)checkAfter {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		countExpectMessage = countMessage;
		pNClientDidReceiveMessageNotification = 0;
		for( int i=0; i<countMessage; i++ )
			[self sendCommand: [NSString stringWithFormat: @"sendMessage %@ message_%d", name, i+1]];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, checkAfter * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if( pNClientDidReceiveMessageNotification != countExpectMessage )
			[self addMessageToLog: [NSString stringWithFormat: @"invalid message count %d/%d", pNClientDidReceiveMessageNotification, countExpectMessage]];
		else
			[self addMessageToLog: [NSString stringWithFormat: @"received all (%d) message", countExpectMessage]];
	});
}

-(void)checkPresenceAfter:(int)after
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if( pNClientDidReceivePresenceEventNotification == 0 )
			[self addMessageToLog: @"kPNClientDidReceivePresenceEventNotification not called"];
		else
			[self addMessageToLog: @"kPNClientDidReceivePresenceEventNotification called"];
	});
}

-(void)subscribeToChannelWithName:(NSString*)name after:(int)after
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		PNChannel *pnChannel = [PNChannel channelWithName: name shouldObservePresence: YES];
		[PubNub subscribeOnChannels: @[pnChannel] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
			 [self addMessageToLog: [NSString stringWithFormat: @"subscribeOnChannels %@ %lu", name, state]];
		 }];

		pNClientDidReceiveMessageNotification = 0;
		[self sendCommand: [NSString stringWithFormat: @"subscribe %@", name]];
	});
}

- (void)kPNClientDidReceivePresenceEventNotification:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientDidReceivePresenceEvent: %@", notification);
	[self addMessageToLog: @"kPNClientDidReceivePresenceEventNotification"];
	pNClientDidReceivePresenceEventNotification = YES;
}

- (void)kPNClientDidReceiveMessageNotification:(NSNotification *)notification {
    NSLog(@"kPNClientDidReceiveMessageNotification %@", notification);
	[self addMessageToLog: @"kPNClientDidReceiveMessageNotification"];
	pNClientDidReceiveMessageNotification++;
}

@end
