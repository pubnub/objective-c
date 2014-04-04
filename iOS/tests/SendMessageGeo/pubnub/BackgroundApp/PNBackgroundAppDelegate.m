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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationDidEnterBackgroundState:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    // Configure application window and its content
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];

	locationManager = [[CLLocationManager alloc] init];

    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;

    // Set a movement threshold for new events.
    locationManager.distanceFilter = 1; // meters

    [locationManager startUpdatingLocation];
//    [locationManager startMonitoringSignificantLocationChanges];

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

	[[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://google.com"]];
	if( numberConfiguration == 0 )
		[self connect];
	if( numberConfiguration == 1 )
		[self connect1];

    return YES;
}

- (BOOL)shouldRunClientInBackground {
	return YES;
}

-(void)handleApplicationDidEnterBackgroundState:(NSNotification*)notification {
	[self addMessageToLog: @"handleApplicationDidEnterBackgroundState"];
	NSLog(@"handleApplicationDidEnterBackgroundState %@", notification);
	isInBackground = YES;
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
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

	[notificationCenter addObserver:self
						   selector:@selector(handleClientConnectionStateChange:)
							   name:kPNClientDidConnectToOriginNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientConnectionStateChange:)
							   name:kPNClientDidDisconnectFromOriginNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientConnectionStateChange:)
							   name:kPNClientConnectionDidFailWithErrorNotification
							 object:nil];

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

		numberConfiguration++;
		if( numberConfiguration == 1 )
		{
			[self addMessageToLog: @"!!!!!!!!!!!!!!!!!!!! Start zip config"];
			[self connect1];
		}
		if( numberConfiguration > 1 )
		{
			[self addMessageToLog: @"finish!!!!!!!!!!!!!!!!!!!!"];
		}
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
			 NSLog(@"PNMessageSendingError");
//			 [self performSelector: @selector(errorSelectorMessage)];
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
		NSLog(@"sended != received\n");
		[self performSelector: @selector(errorSelectorReceived)];
	}
	[self addMessageToLog: [NSString stringWithFormat: @"didReceiveMessage №%d", numberMessage]];

	numberMessage++;
	[self sendMessage];
}
/////////////////////////////////////////////
- (void)handleClientConnectionStateChange:(NSNotification *)notification {
	if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
		isInBackground = YES;
	NSLog(@"handleClientConnectionStateChange, background %d, %@", isInBackground, notification);
}

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	//    BOOL isInBackground = NO;
	//    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
	//    {
	//        isInBackground = YES;
	//    }
	//
	//    // Handle location updates as normal, code omitted for brevity.
	//    // The omitted code should determine whether to reject the location update for being too
	//    // old, too close to the previous one, too inaccurate and so forth according to your own
	//    // application design.

	NSLog(@"didUpdateToLocation, background %d, %@", isInBackground, newLocation);
	//    if (isInBackground)
	//    {
	////        [self sendBackgroundLocationToServer:newLocation];
	//    }
	//    else
	//    {
	//        // ...
	//    }
}


@end
