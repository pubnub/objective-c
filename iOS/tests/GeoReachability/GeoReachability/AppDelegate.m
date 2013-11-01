//
//  AppDelegate.m
//  GeoReachability
//
//  Created by Valentin Tuller on 10/14/13.
//  Copyright (c) 2013 Valentin. All rights reserved.
//

#import "AppDelegate.h"
#import "PubNub.h"
#import "PNConfiguration.h"
#import "PNReachability.h"
#import "PNNotifications.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

	UIViewController *vc = [[UIViewController alloc] init];
	self.window.rootViewController = vc;

	locationManager = [[CLLocationManager alloc] init];

    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;

    // Set a movement threshold for new events.
    locationManager.distanceFilter = 1; // meters

//    [locationManager startUpdatingLocation];
    [locationManager startMonitoringSignificantLocationChanges];

	isInBackground = NO;
	[self connect];

    return YES;
}

- (void)connect
{
	[PubNub disconnect];
	//    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
	//	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: @"key"];
	////	//	configuration.autoReconnectClient = NO;
	//	[PubNub setConfiguration: configuration];

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

	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		//		[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];
		PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil];
		[PubNub setConfiguration: configuration];

		[PubNub connectWithSuccessBlock:^(NSString *origin) {

			dispatch_semaphore_signal(semaphore);
			NSLog(@"connectWithSuccessBlock %@", origin);
		}
							 errorBlock:^(PNError *connectionError) {
								 dispatch_semaphore_signal(semaphore);
							 }];
	});
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
//
//	PNReachability *reachability = [PNReachability serviceReachability];
//	reachability.reachabilityChangeHandleBlock = ^(BOOL connected) {
//		BOOL isInBackground = NO;
//		if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
//			isInBackground = YES;
//		NSLog(@"IS CONNECTED? %@, isInBackground %d", connected?@"YES":@"NO", isInBackground);
//	};
//	[reachability startServiceReachabilityMonitoring];
}

- (void)handleClientConnectionStateChange:(NSNotification *)notification {
//	BOOL isInBackground = NO;
//	if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
//		isInBackground = YES;
	NSLog(@"handleClientConnectionStateChange, background %d, %@", isInBackground, notification);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	NSLog(@"applicationDidEnterBackground");
	isInBackground = YES;
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	NSLog(@"applicationDidBecomeActive");
	isInBackground = NO;
//	[locationManager stopMonitoringSignificantLocationChanges];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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

-(void) sendBackgroundLocationToServer:(CLLocation *)location
{
	NSLog(@"sendBackgroundLocationToServer %@", location);
    // REMEMBER. We are running in the background if this is being executed.
    // We can't assume normal network access.
    // bgTask is defined as an instance variable of type UIBackgroundTaskIdentifier

    // Note that the expiration handler block simply ends the task. It is important that we always
    // end tasks that we have started.

    UIBackgroundTaskIdentifier bgTask = 0;
	[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:
			  ^{
				  [[UIApplication sharedApplication] endBackgroundTask:bgTask];
				   }];
				  // ANY CODE WE PUT HERE IS OUR BACKGROUND TASK

				  // For example, I can do a series of SYNCHRONOUS network methods (we're in the background, there is
				  // no UI to block so synchronous is the correct approach here).

				  // ...

				  // AFTER ALL THE UPDATES, close the task

				  if (bgTask != UIBackgroundTaskInvalid)
				  {
					  [[UIApplication sharedApplication] endBackgroundTask:bgTask];
					   bgTask = UIBackgroundTaskInvalid;
					   }
}

@end
