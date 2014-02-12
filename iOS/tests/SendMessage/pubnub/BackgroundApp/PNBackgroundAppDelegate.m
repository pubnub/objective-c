//
//  PNBackgroundAppDelegate.m
//  pubnub
//
//  Created by Valentin Tuller on 9/24/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNBackgroundAppDelegate.h"
#import "PubNub.h"

@implementation PNBackgroundAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	timeout = 30;
	numberMessage = 0;
	numberConfiguration = 0;

    // Configure application window and its content
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];

	NSString *path = [[NSBundle mainBundle] bundlePath];
	NSString *finalPath = [path stringByAppendingPathComponent:@"messages.plist"];
	messages = [NSArray arrayWithContentsOfFile:finalPath];

	UIViewController *vc = [[UIViewController alloc] init];
	tbxLog = [[UITextView alloc] initWithFrame: vc.view.bounds];
	tbxLog.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tbxLog.editable = NO;
	[vc.view addSubview: tbxLog];

	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: vc];
	self.window.rootViewController = navController;
	navController.topViewController.title = @"SendMessage tests";

	if( numberConfiguration == 0 )
		[self connect];
	if( numberConfiguration == 1 )
		[self connect1];

    return YES;
}

-(void)addMessageToLog:(NSString*)message {
	tbxLog.text = [tbxLog.text stringByAppendingFormat: @"%@%@", (tbxLog.text.length>0)? @"\n":@"", message];
	NSRange range = NSMakeRange(tbxLog.text.length - 1, 1);
	[tbxLog scrollRangeToVisible:range];
}

-(void)resetMessage {
	[self addMessageToLog: [NSString stringWithFormat: @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! FAIL №%d", numberMessage]];
	NSLog( @"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! FAIL №%d", numberMessage);
	numberMessage++;
	[PubNub resetClient];
	[self connect];
}


- (void)connect {
    [PubNub setDelegate:self];
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
		pnChannel = [PNChannel channelWithName: [NSString stringWithFormat: @"channel"]];

		[PubNub subscribeOnChannels: @[pnChannel]
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
			 [self sendMessage];
		 }];

    }
                         errorBlock:^(PNError *connectionError) {
	 }];
}

- (void)connect1 {
	[PubNub resetClient];

    [PubNub setDelegate:self];
	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"post-devbuild.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil];
	[PubNub setConfiguration: configuration];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
		pnChannel = [PNChannel channelWithName: [NSString stringWithFormat: @"channel"]];

		[PubNub subscribeOnChannels: @[pnChannel]
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
			 [self sendMessage];
		 }];

    }
                         errorBlock:^(PNError *connectionError) {
						 }];
}


-(void)sendMessage {
	[timerReset invalidate];
	if( numberMessage >= messages.count ) {
//		[self performSelector: @selector(selectorFinish)];
		[self addMessageToLog: @"finish!!!!!!!!!!!!!!!!!!!! Start zip config"];

		numberConfiguration++;
		if( numberConfiguration == 1 )
			[self connect1];
		numberMessage = 0;
		return;
	}

	timerReset = [NSTimer scheduledTimerWithTimeInterval: timeout target:self selector:@selector(resetMessage) userInfo:nil repeats:NO];
	id message = messages[numberMessage];
	[PubNub sendMessage: message toChannel:pnChannel compressed: (numberConfiguration == 1) withCompletionBlock:^(PNMessageState messageSendingState, id data) {
		if( messageSendingState == PNMessageSending )
			NSLog(@"PNMessageSending #%d", numberMessage);
		if( messageSendingState == PNMessageSent ) {
			 NSLog(@"PNMessageSent #%d", numberMessage);
			[self addMessageToLog: [NSString stringWithFormat: @"sent №%d", numberMessage]];
		}
		if( messageSendingState == PNMessageSendingError ) {
			 NSLog(@"PNMessageSendingError %@", data);
			 [self performSelector: @selector(errorSelectorMessage)];
		}
	 }];
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
	if( numberConfiguration >= 2 )
		return;

	NSLog(@"didReceiveMessage #%d", numberMessage);
	id sended = messages[numberMessage];
	id received = message.message;
	if( [sended isEqual: received] == NO ) {
		NSLog(@"sended / received\n%@\n\n%@", sended, received);
		[self performSelector: @selector(errorSelectorReceived)];
	}
	[self addMessageToLog: [NSString stringWithFormat: @"didReceiveMessage №%d", numberMessage]];

	numberMessage++;
	[self sendMessage];
}



@end
