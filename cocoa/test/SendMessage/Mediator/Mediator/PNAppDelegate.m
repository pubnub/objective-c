//
//  PNAppDelegate.m
//  Mediator
//
//  Created by Valentin Tuller on 4/4/14.
//  Copyright (c) 2014 Valentin Tuller. All rights reserved.
//

#import "PNAppDelegate.h"

@implementation PNAppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	NSLog(@"applicationWillFinishLaunching %@", notification);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self addMessageToLog: @"start Mediator"];
	NSLog(@"applicationDidFinishLaunching %@", aNotification);
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
//    NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	NSURL *url = [NSURL URLWithString: [[event paramDescriptorForKeyword:keyDirectObject] stringValue] ];
	NSArray *components = [url pathComponents];
//	[self addMessageToLog: [NSString stringWithFormat: @"handleURLEvent %@", url]];
//    NSLog(@"handleURLEvent %@", url);

	for( int i=0; i<components.count; i++)
	{
		NSArray *args = [components[i] componentsSeparatedByString: @" "];
		NSLog(@"args %@", args);
		[self addMessageToLog: [NSString stringWithFormat: @"args %@", components[i]]];
		[self proccessArgs: args];
	}
}

-(void)addMessageToLog:(NSString*)message {
	[self.tbxLog moveToEndOfDocument:nil];
	[self.tbxLog insertText: [NSString stringWithFormat: @"%@%@ %@", @"\n", [NSDate date], message]];
}


-(void)proccessArgs:(NSArray *)args
{
	if( args.count == 0 )
		return;

	if( [args[0] isEqualToString: @"connect"] == YES && args.count >= 2)
		[self connectToChannel: args[1]];
	if( [args[0] isEqualToString: @"sendMessage"] == YES && args.count >= 3)
		[PubNub sendMessage: args[2] toChannel: [PNChannel channelWithName: args[1]] compressed: NO withCompletionBlock:^(PNMessageState messageSendingState, id data) {
			[self addMessageToLog: [NSString stringWithFormat: @"sendMessage state %lu", messageSendingState]];
		}];
	if( [args[0] isEqualToString: @"subscribe"] == YES && args.count >= 2)
		[PubNub subscribeOnChannel: [PNChannel channelWithName: args[1]] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
			 [self addMessageToLog: [NSString stringWithFormat: @"subscribeOnChannels state %lu", state]];
		 }];
}

- (void)connectToChannel:(NSString*)ch
{
	PNConfiguration *configuration = [PNConfiguration defaultConfiguration];
	[PubNub setConfiguration: configuration];
	[PubNub connectWithSuccessBlock:^(NSString *origin) {
		PNChannel *pnChannel = [PNChannel channelWithName: ch];
		[PubNub subscribeOnChannels: @[pnChannel] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
		 }];
	}
	errorBlock:^(PNError *connectionError) {}];
}


@end
