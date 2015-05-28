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

#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Configure application window and its content
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];

	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: [[UITableViewController alloc] init]];
	self.window.rootViewController = navController;
	navController.topViewController.title = @"Pubnub";


	isWillRestoreSubscriptionOnChannelsDelegate = YES;
	isDidRestoreSubscriptionOnChannelsDelegate = YES;
    [self initializePubNubClient];

	currentInterval = 10;

	[PubNub clientIdentifier];
	countNewMessage = 1;
	countSession = 0;
	[self connect];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	NSLog(@"openURL %@, %@, %@", url, sourceApplication, annotation);
	[self performSelector:@selector(openUrl) withObject:nil afterDelay:15];
	return YES;
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"applicationWillEnterForeground");
}


-(void)openUrl {
	if( countNewMessage != 1 && countSession%2 == 0 )
		[self performSelector: @selector(errorSelectorCountNewMessage)];
	if( isWillRestoreSubscriptionOnChannelsDelegate == NO )
		[self performSelector: @selector(errorSelectorWillRestore)];
	if( isDidRestoreSubscriptionOnChannelsDelegate == NO )
		[self performSelector: @selector(errorSelectorDidRestore)];
	countNewMessage = 0;
	countSession++;
	isWillRestoreSubscriptionOnChannelsDelegate = NO;
	isDidRestoreSubscriptionOnChannelsDelegate = NO;

	NSString *url = [NSString stringWithFormat: @"mediatorWithMessage://"];
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocationCoordinate2D currentCoordinates = newLocation.coordinate;
    NSLog(@"Entered new Location with the coordinates Latitude: %f Longitude: %f", currentCoordinates.latitude, currentCoordinates.longitude);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Unable to start location manager. Error:%@", [error description]);
}


- (void)initializePubNubClient {

    [PubNub setDelegate:self];

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

    // Subscribe for client connection state change (observe when client will be disconnected)
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                            BOOL connected,
                                                                            PNError *error) {

															if (!connected && error) {

																NSLog(@"#2 PubNub client was unable to connect because of error: %@",
																	  [error localizedDescription],
																	  [error localizedFailureReason]);
															}
														}];


    // Subscribe application delegate on subscription updates (events when client subscribe on some channel)
    __pn_desired_weak __typeof__(self) weakSelf = self;
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:weakSelf
                                                                 withCallbackBlock:^(PNSubscriptionProcessState state,
                                                                                     NSArray *channels,
                                                                                     PNError *subscriptionError) {

																	 switch (state) {

																		 case PNSubscriptionProcessNotSubscribedState:

																			 NSLog(@"{BLOCK-P} PubNub client subscription failed with error: %@",
																				   subscriptionError);
																			 break;

																		 case PNSubscriptionProcessSubscribedState:

																			 NSLog(@"{BLOCK-P} PubNub client subscribed on channels: %@",
																				   channels);
																			 break;

																		 case PNSubscriptionProcessWillRestoreState:

																			 NSLog(@"{BLOCK-P} PubNub client will restore subscribed on channels: %@",
																				   channels);
																			 break;

																		 case PNSubscriptionProcessRestoredState:

																			 NSLog(@"{BLOCK-P} PubNub client restores subscribed on channels: %@",
																				   channels);
																			 break;
																	 }
																 }];

    // Subscribe on message arrival events with block
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:weakSelf
                                                         withBlock:^(PNMessage *message) {

															 NSLog(@"{BLOCK-P} PubNubc client received new message: %@",
																   message);
														 }];

    // Subscribe on presence event arrival events with block
    [[PNObservationCenter defaultCenter] addPresenceEventObserver:weakSelf
                                                        withBlock:^(PNPresenceEvent *presenceEvent) {

                                                            NSLog(@"{BLOCK-P} PubNubc client received new event: %@",
																  presenceEvent);
                                                        }];
}

- (void)connect {
	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"post-devbuild.pubnub.com" publishKey:@"pub-c-bb4a4d9b-21b1-40e8-a30b-04a22f5ef154" subscribeKey:@"sub-c-6b43405c-3694-11e3-a5ee-02ee2ddab7fe" secretKey: @"sec-c-ZmNlNzczNTEtOGUwNS00MmRjLWFkMjQtMjJiOTA2MjY2YjI5" cipherKey: @"cipherKey"];
	[PubNub setConfiguration: configuration];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {

		PNChannel *pnChannel = [PNChannel channelWithName: [NSString stringWithFormat: @"mediatorWithMessage"]];

		[PubNub grantAllAccessRightsForApplicationAtPeriod: 1440 andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
			[PubNub subscribeOnChannels: @[pnChannel]
			withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
			 {
				 [self openUrl];
			 }];
		}];


    }
                         errorBlock:^(PNError *connectionError) {
	 }];
}

- (BOOL)shouldRunClientInBackground {
	return NO;
}

- (NSNumber *)shouldRestoreSubscriptionFromLastTimeToken {
    NSString *lastTimeToken = @"0";

    if ([[PubNub subscribedChannels] count] > 0) {

        lastTimeToken = [[[PubNub subscribedChannels] lastObject] updateTimeToken];
		self.lastClientIdentifier = [PubNub clientIdentifier];
    }

	BOOL shouldRestoreSubscriptionFromLastTimeToken = (countSession%2 == 0);
    NSLog( @"PubNub client should restore subscription from last time token? %@ (last time token: %@)",
		  shouldRestoreSubscriptionFromLastTimeToken?@"YES":@"NO", lastTimeToken);
    return @(shouldRestoreSubscriptionFromLastTimeToken);
}

- (void)handleClientConnectionStateChange:(NSNotification *)notification {

    // Default field values
    BOOL connected = YES;
    PNError *connectionError = nil;
    NSString *origin = @"";

    if([notification.name isEqualToString:kPNClientDidConnectToOriginNotification] ||
       [notification.name isEqualToString:kPNClientDidDisconnectFromOriginNotification]) {

        origin = (NSString *)notification.userInfo;
        connected = [notification.name isEqualToString:kPNClientDidConnectToOriginNotification];
    }
    else if([notification.name isEqualToString:kPNClientConnectionDidFailWithErrorNotification]) {

        connected = NO;
        connectionError = (PNError *)notification.userInfo;
    }

    // Retrieving list of observers (including one time and persistent observers)
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    NSLog( @"PubNub client received message: %@", message);
	NSString *string = [NSString stringWithFormat: @"%@", message.message];
	if( [string rangeOfString: @"mediatorWithMessage"].location != NSNotFound )
		countNewMessage++;
}

- (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels {
	NSLog(@"WillRestoreSubscriptionOnChannelsDelegate");
	isWillRestoreSubscriptionOnChannelsDelegate = YES;
}

- (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels {
	NSLog(@"DidRestoreSubscriptionOnChannelsDelegate");
	isDidRestoreSubscriptionOnChannelsDelegate = YES;
}


@end
