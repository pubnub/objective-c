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
	int pNClientDidReceivePresenceEventLeaveNotification;
	int pNClientDidReceiveMessageNotification;
	int pNClientDidReceiveMessageDelegate;
	int countExpectMessage;
	NSMutableArray *expectedMessageObjectsNotification;
	NSMutableArray *expectedMessageObjectsDelegate;
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
	expectedMessageObjectsNotification = [NSMutableArray array];
	expectedMessageObjectsDelegate = [NSMutableArray array];
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
	[PubNub setDelegate: self];
	[PubNub connectWithSuccessBlock:^(NSString *origin) {
		[self startSendCommand];
	}
	errorBlock:^(PNError *connectionError) {}];
}

-(void)sendCommand:(NSString*)command
{
	[self addMessageToLog: [NSString stringWithFormat: @"send command: %@", command]];
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: [NSString stringWithFormat: @"mediator:///%@", [command stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]]]];
}
///////////////////////////////////////////////////////////
-(void)addMessageToLog:(NSString*)message {
	NSAttributedString *string = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat: @"%@%@ %@", @"\n", [NSDate date], message]];
	[self addAttributedStringToLog: string];
	NSLog(@"log %@", message);
}

-(void)addErrorToLog:(NSString*)message {
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"%@%@ %@", @"\n", [NSDate date], message]];
	NSRange boldedRange = NSMakeRange(0, string.length);
	[string addAttribute: NSFontAttributeName value:[NSFont boldSystemFontOfSize: 15] range:boldedRange];

	[self addAttributedStringToLog: string];
	NSLog(@"log %@", message);
}

-(void)addAttributedStringToLog:(NSAttributedString*)message {

	NSTextStorage *storage = [self.tbxLog textStorage];
	[storage beginEditing];

	[storage appendAttributedString: message];
	[storage endEditing];

	if( self.btnAutoscroll.state == NSOnState )
		[self.tbxLog moveToEndOfDocument: nil];
}
//////////////////////////////////////////////////////////
-(void)startSendCommand
{
	[self.btnReload setEnabled: NO];
	int delay = 0;
	[self sendCommand: @"start"];
	delay += 3;

	[self connectAfter: delay];
	delay += 5;

	[self subscribeToChannelWithName: @"chWithMessageMac" after: delay];
	delay += 5;

	[self checkPresenceAfter: delay];
	delay += 1;

	[self sendMessage: @[@"test1", @"test1"]  after: delay toChannelWithName:@"chWithMessageMac" andCheckAfter: 5];
	delay += 6;

	[self sendMessage: @{@"key": @"value"}  after: delay toChannelWithName:@"chWithMessageMac" andCheckAfter: 5];
	delay += 6;

	[self sendMessages: 10 after: delay toChannelWithName: @"chWithMessageMac" andCheckAfter: 10];
	delay += 11;

	[self subscribeToChannelWithName: @"ch1" after: delay];
	delay += 5;
	[self checkPresenceAfter: delay];
	delay += 1;

//	[self sendMessages: 100 after: delay toChannelWithName: @"chWithMessageMac" andCheckAfter: 30];

//	delay += 31;
//	[self sendMessages: 100 after: delay toChannelWithName: @"chWithMessageMac" andCheckAfter: 30];
//
//	delay += 31;
//	[self sendMessages: 100 after: delay toChannelWithName: @"chWithMessageMac" andCheckAfter: 30];
//	delay += 21;

//	delay += 5;
	[self unsubscribeFromAllChannelsAfter: delay];
	delay += 5;

	[self logFinishAfter: delay];
}

-(void)logFinishAfter:(int)after {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[self addMessageToLog:@"finish"];
		[self.btnReload setEnabled: YES];
	});
}

-(void)connectAfter:(int)delay {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[self sendCommand: @"connect"];
	});
}

-(void)sendMessages:(int)countMessage after:(int)after toChannelWithName:(NSString*)name andCheckAfter:(int)checkAfter {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		countExpectMessage = countMessage;
		pNClientDidReceiveMessageNotification = 0;
		pNClientDidReceiveMessageDelegate = 0;
	});
 	for( int i=0; i<countMessage; i++ )	{
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC + 1000 + 1000*i), dispatch_get_main_queue(), ^{
			NSString *message = [NSString stringWithFormat: @"message_%d", i+1];
			[self sendCommand: [NSString stringWithFormat: @"sendMessage %@ %@", name, message]];
			[expectedMessageObjectsNotification addObject: message];
			[expectedMessageObjectsDelegate addObject: message];
		});
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (after+checkAfter) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if( pNClientDidReceiveMessageNotification != countExpectMessage )
			[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! invalid message count %d/%d", pNClientDidReceiveMessageNotification, countExpectMessage]];
		else
			[self addMessageToLog: [NSString stringWithFormat: @"received all (%d) message (notification)", countExpectMessage]];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (after+checkAfter) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if( pNClientDidReceiveMessageDelegate != countExpectMessage )
			[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! invalid message count %d/%d", pNClientDidReceiveMessageDelegate, countExpectMessage]];
		else
			[self addMessageToLog: [NSString stringWithFormat: @"received all (%d) message (delegate)", countExpectMessage]];
	});
}

-(void)sendMessage:(id)message after:(int)after toChannelWithName:(NSString*)name andCheckAfter:(int)checkAfter {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		countExpectMessage = 1;
		pNClientDidReceiveMessageNotification = 0;
		pNClientDidReceiveMessageDelegate = 0;
	});
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC + 1000), dispatch_get_main_queue(), ^{
		id object = @"ERROR message";
		if( [message isKindOfClass: [NSString class]] == YES )
			object = [message stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		if( [message isKindOfClass: [NSDictionary class]] == YES || [message isKindOfClass: [NSArray class]] == YES ) {
			NSError *error;
			NSData *jsonData = [NSJSONSerialization dataWithJSONObject: message options: 0 error: &error];
			if( jsonData != nil) {
				object = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
				object = [object stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
			}
		}
		[self sendCommand: [NSString stringWithFormat: @"sendMessage %@ %@", name, object]];
		[expectedMessageObjectsNotification addObject: message];
		[expectedMessageObjectsDelegate addObject: message];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (after+checkAfter) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if( pNClientDidReceiveMessageNotification != countExpectMessage )
			[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! invalid message count %d/%d", pNClientDidReceiveMessageNotification, countExpectMessage]];
		else
			[self addMessageToLog: [NSString stringWithFormat: @"received all (%d) message (notification)", countExpectMessage]];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (after+checkAfter) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if( pNClientDidReceiveMessageDelegate != countExpectMessage )
			[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! invalid message count %d/%d", pNClientDidReceiveMessageDelegate, countExpectMessage]];
		else
			[self addMessageToLog: [NSString stringWithFormat: @"received all (%d) message (delegate)", countExpectMessage]];
	});
}
////////////////////////////////////////////////////////////////////////////////////////
-(void)subscribeToChannelWithName:(NSString*)name after:(int)after
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		pNClientDidReceivePresenceEventNotification = 0;
		PNChannel *pnChannel = [PNChannel channelWithName: name shouldObservePresence: YES];
		[PubNub subscribeOnChannels: @[pnChannel] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
			 [self addMessageToLog: [NSString stringWithFormat: @"subscribeOnChannels %@ %lu", name, state]];
		 }];

		[self sendCommand: [NSString stringWithFormat: @"subscribe %@", name]];
	});
}

-(void)checkPresenceAfter:(int)after
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if( pNClientDidReceivePresenceEventNotification == 0 )
			[self addErrorToLog: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! kPNClientDidReceivePresenceEventNotification not called"];
		else
			[self addMessageToLog: @"kPNClientDidReceivePresenceEventNotification called"];
	});
}

- (void)kPNClientDidReceivePresenceEventNotification:(NSNotification *)notification {
	PNPresenceEvent *event = (PNPresenceEvent*)notification.userInfo;
    PNLog(PNLogGeneralLevel, self, @"NSNotification kPNClientDidReceivePresenceEventNotification: %@", event);
	NSString *type = @"???";
	type = (event.type == PNPresenceEventChanged) ? @"changed" : type;
	type = (event.type == PNPresenceEventJoin) ? @"join" : type;
	type = (event.type == PNPresenceEventLeave) ? @"leave" : type;
	type = (event.type == PNPresenceEventTimeout) ? @"timeout" : type;
	[self addMessageToLog: [NSString stringWithFormat: @"kPNClientDidReceivePresenceEventNotification, %@, %@", type ,event.client.channel.name]];
	if( event.type == PNPresenceEventJoin )
		pNClientDidReceivePresenceEventNotification = YES;
	if( event.type == PNPresenceEventLeave )
		pNClientDidReceivePresenceEventLeaveNotification = YES;
}
/////////////
-(void)unsubscribeFromChannelWithName:(NSString*)name after:(int)after andCheckLeaveAfter:(int)checkAfter
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		pNClientDidReceivePresenceEventLeaveNotification = 0;
		[self sendCommand: [NSString stringWithFormat: @"unsubscribe %@", name]];
	});
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (after+checkAfter) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if( pNClientDidReceivePresenceEventLeaveNotification == 0 )
			[self addErrorToLog: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! pNClientDidReceivePresenceEventNotification leave not called"];
		else
			[self addMessageToLog: @"kPNClientDidReceivePresenceEventNotification leave called"];

		PNChannel *pnChannel = [PNChannel channelWithName: name];
		[PubNub unsubscribeFromChannel: pnChannel withCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError)
		 {
			 [self addMessageToLog: [NSString stringWithFormat: @"unsubscribeFromChannel %@", (unsubscribeError!=nil) ? unsubscribeError:@""]];
		 }];
	});
}

-(void)unsubscribeFromAllChannelsAfter:(int)after {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, after * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[self sendCommand: [NSString stringWithFormat: @"unsubscribeAll"]];
	});
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
	pNClientDidReceiveMessageDelegate++;
	[self addMessageToLog: [NSString stringWithFormat: @"didReceiveMessage %@", message.message]];
	if( expectedMessageObjectsDelegate.count == 0 ) {
		[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! unexpected message %@", message.message]];
		return;
	}
	if( [expectedMessageObjectsDelegate[0] isEqualTo:message.message] == NO ) {
		[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! invalid message \"%@\" != \"%@\"", expectedMessageObjectsDelegate[0], message.message]];
	}
	[expectedMessageObjectsDelegate removeObjectAtIndex: 0];
}


- (void)kPNClientDidReceiveMessageNotification:(NSNotification *)notification {
	pNClientDidReceiveMessageNotification++;

	PNMessage *message = (PNMessage*)(notification.userInfo);
	[self addMessageToLog: [NSString stringWithFormat: @"kPNClientDidReceiveMessageNotification %@", message.message]];
	if( expectedMessageObjectsNotification.count == 0 ) {
		[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! unexpected message %@", message.message]];
		return;
	}
//	[self addMessageToLog: [NSString stringWithFormat: @"equal %d", [expectedMessageObjects[0] isEqualTo:message.message]]];
	if( [expectedMessageObjectsNotification[0] isEqualTo:message.message] == NO ) {
		[self addErrorToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! invalid message \"%@\" != \"%@\"", expectedMessageObjectsNotification[0], message.message]];
	}
	[expectedMessageObjectsNotification removeObjectAtIndex: 0];
}

-(IBAction)reloadClick:(id)sender {
	[self.tbxLog setString:[NSString string]];
	[self startSendCommand];
}


@end
