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
	countMessageSend = 10;
	countSubscribred = 10;
	subscribedChannelNames = [NSMutableArray array];
	wiFiOnUrl = @"http://192.168.2.1/wiFiReconnect60.php";
	[self connect];

    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//	NSLog(@"openURL %@, %@, %@", url, sourceApplication, annotation);
	[self performSelector:@selector(openUrl) withObject:nil afterDelay:100];
	countMessageSend = 0;
	for( int i=0; i<19; i++)
		[self performSelector: @selector(sendMessage) withObject: nil afterDelay: i*5];

	countSubscribred = 0;
	for( int i=0; i<subscribedChannelNames.count; i++ )
		[PubNub unsubscribeFromChannel: [PNChannel channelWithName: subscribedChannelNames[i]]];
	[subscribedChannelNames removeAllObjects];

	for( int i=0; i<19; i++)
		[self performSelector: @selector(subscribeToNewTestChannel) withObject: nil afterDelay: i*5];

	return YES;
}

-(void)subscribeToNewTestChannel {
	[PubNub grantAllAccessRightsForApplicationAtPeriod: 1440 andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		NSString *name = [NSString stringWithFormat: @"channel %@", [NSDate date]];
		[subscribedChannelNames addObject: name];
		[PubNub subscribeOnChannels: [PNChannel channelsWithNames: @[name]]
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
			if( subscriptionError == nil )
				countSubscribred++;
		}];
	}];
}


-(void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"applicationWillEnterForeground");
}


-(void)openUrl {
//	if( countNewMessage != 1 && countSession%2 == 0 )
//		[self performSelector: @selector(errorSelectorCountNewMessage)];
	if( isWillRestoreSubscriptionOnChannelsDelegate == NO )
		[self performSelector: @selector(errorSelectorWillRestore)];
	if( isDidRestoreSubscriptionOnChannelsDelegate == NO )
		[self performSelector: @selector(errorSelectorDidRestore)];
	if( countMessageSend < 2 )
		[self performSelector: @selector(errorSelectorCountDidSend)];
	if( countSubscribred < 2 )
		[self performSelector: @selector(errorSelectorCountSubscribed)];
	countNewMessage = 0;
	countSession++;
	isWillRestoreSubscriptionOnChannelsDelegate = NO;
	isDidRestoreSubscriptionOnChannelsDelegate = NO;

	[self wifiRestart];
	NSLog(@"open Mediator---------------------------------------------------------------------------");
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
/*
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
*/
    // Subscribe for client connection state change (observe when client will be disconnected)
/*    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                            BOOL connected,
                                                                            PNError *error) {

															if (!connected && error) {

																PNLog(PNLogGeneralLevel, self, @"#2 PubNub client was unable to connect because of error: %@",
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

																			 PNLog(PNLogGeneralLevel, weakSelf,
																				   @"{BLOCK-P} PubNub client subscription failed with error: %@",
																				   subscriptionError);
																			 break;

																		 case PNSubscriptionProcessSubscribedState:

																			 PNLog(PNLogGeneralLevel, weakSelf,
																				   @"{BLOCK-P} PubNub client subscribed on channels: %@",
																				   channels);
																			 break;

																		 case PNSubscriptionProcessWillRestoreState:

																			 PNLog(PNLogGeneralLevel, weakSelf,
																				   @"{BLOCK-P} PubNub client will restore subscribed on channels: %@",
																				   channels);
																			 break;

																		 case PNSubscriptionProcessRestoredState:

																			 PNLog(PNLogGeneralLevel, weakSelf,
																				   @"{BLOCK-P} PubNub client restores subscribed on channels: %@",
																				   channels);
																			 break;
																	 }
																 }];

    // Subscribe on message arrival events with block
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:weakSelf
                                                         withBlock:^(PNMessage *message) {

															 PNLog(PNLogGeneralLevel, weakSelf, @"{BLOCK-P} PubNubc client received new message: %@",
																   message);
														 }];

    // Subscribe on presence event arrival events with block
    [[PNObservationCenter defaultCenter] addPresenceEventObserver:weakSelf
                                                        withBlock:^(PNPresenceEvent *presenceEvent) {

                                                            PNLog(PNLogGeneralLevel, weakSelf, @"{BLOCK-P} PubNubc client received new event: %@",
																  presenceEvent);
                                                        }];
 */
}

- (void)connect {
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {

		pnChannel = [PNChannel channelWithName: [NSString stringWithFormat: @"mediatorWithMessage"]];

		[PubNub grantAllAccessRightsForApplicationAtPeriod: 1440 andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
			[PubNub subscribeOnChannels: @[pnChannel]
			withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
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
/*
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
*/
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
//	if( countNewMessage > 0 )
//		[self performSelector: @selector(errorSelectorExpectMessage)];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)sendMessage {
	__block BOOL isCalbackCalled = NO;
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	[PubNub sendMessage:[NSString stringWithFormat: @"mediatorWithMessage, %@", [NSDate date]] toChannel:pnChannel compressed: NO 	withCompletionBlock:^(PNMessageState messageSendingState, id data) {
		if( messageSendingState != PNMessageSending ) {
			isCalbackCalled = YES;
			dispatch_semaphore_signal(semaphore);
		}
		if( messageSendingState == PNMessageSent )
			countMessageSend++;
	 }];
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	if( isCalbackCalled == NO )
		[self performSelector: @selector(callbackMessageNotCalled)];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)wifiRestart {
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:wiFiOnUrl]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"connection didReceiveResponse");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"connection didReceiveData");
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
	NSLog(@"connection willCacheResponse");
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"connection connectionDidFinishLoading");
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"connection didFailWithError %@", error);
}


@end
