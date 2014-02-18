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

	if( countSession % 3 == 0 )
		[self performSelector: @selector(setClientIdentifier) withObject: nil afterDelay: 10];

	return YES;
}

-(void)setClientIdentifier {
	lastClientIdentifier = [NSString stringWithFormat: @"%@", [NSDate date]];
	[PubNub setClientIdentifier: lastClientIdentifier shouldCatchup: YES];
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
	if( countMessageSend < 1 )
		[self performSelector: @selector(errorSelectorCountDidSend)];
	if( countSubscribred < 1 )
		[self performSelector: @selector(errorSelectorCountSubscribed)];
	if( [lastClientIdentifier isEqualToString: [PubNub clientIdentifier]] != YES )
		[self performSelector: @selector(errorSelectorClientIdentifier)];
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
}

- (void)connect {
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {

		lastClientIdentifier = [PubNub clientIdentifier];
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
