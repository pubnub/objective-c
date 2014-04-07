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

-(void)proccessArgs:(NSArray *)args
{
	if( args.count == 0 )
		return;

	if( [args[0] isEqualToString: @"connect"] == YES )
		[self connect];
	if( [args[0] isEqualToString: @"sendMessage"] == YES && args.count >= 3) {
		NSString *message = [args[2] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
		[self addMessageToLog: [NSString stringWithFormat: @"send message %@", message]];
		[PubNub sendMessage: message toChannel: [PNChannel channelWithName: args[1]] compressed: NO withCompletionBlock:^(PNMessageState messageSendingState, id data) {
			[self addMessageToLog: [NSString stringWithFormat: @"sendMessage state %lu %@", messageSendingState,
									([data isKindOfClass: [PNMessage class]] == YES) ? ((PNMessage*)data).message : data]];
		}];
	}
	if( [args[0] isEqualToString: @"subscribe"] == YES && args.count >= 2)
		[PubNub subscribeOnChannel: [PNChannel channelWithName: args[1]] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
			 [self addMessageToLog: [NSString stringWithFormat: @"subscribeOnChannels state %lu", state]];
		 }];
	if( [args[0] isEqualToString: @"unsubscribe"] == YES && args.count >= 2)
		[PubNub unsubscribeFromChannel: [PNChannel channelWithName: args[1]] withCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError)
		 {
			 [self addMessageToLog: [NSString stringWithFormat: @"unsubscribeFromChannel %@ ", unsubscribeError]];
		 }];
	if( [args[0] isEqualToString: @"unsubscribeAll"] == YES )
		[PubNub unsubscribeFromChannels: [PubNub subscribedChannels] withCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError)
		 {
			 [self addMessageToLog: [NSString stringWithFormat: @"unsubscribeAll"]];
		 }];

}

- (void)connect {
	[PubNub resetClient];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[PubNub setDelegate: self];
		PNConfiguration *configuration = [PNConfiguration defaultConfiguration];
		[PubNub setConfiguration: configuration];
		[PubNub connectWithSuccessBlock:^(NSString *origin) {
//			PNChannel *pnChannel = [PNChannel channelWithName: ch];
//			[PubNub subscribeOnChannels: @[pnChannel] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
//			 {
//			 }];
		}
		 errorBlock:^(PNError *connectionError) {}];
	});
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
	[self addMessageToLog: [NSString stringWithFormat: @"didReceiveMessage %@", message.message]];
}

-(IBAction)clearClick:(id)sender {
	[self.tbxLog setString:[NSString string]];
}


@end
