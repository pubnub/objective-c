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
    self.window.rootViewController = [[UIViewController alloc] init];
    [self.window makeKeyAndVisible];

    [self initializePubNubClient];

	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDelegate:self];
	//Only applies when in foreground otherwise it is very significant changes
	[locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
	[locationManager startUpdatingLocation];

	[PubNub clientIdentifier];
	[self connect];

	[self performSelector: @selector(openUrl) withObject: nil afterDelay: 5.0];

    return YES;
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"applicationWillEnterForeground");
}


-(void)openUrl {
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"myappMediator://"]];
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


    // Subscribe for client connection state change (observe when client will be disconnected)
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
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
}

- (void)connect {
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, nil, @"{BLOCK} PubNub client connected to: %@", origin);
    }
                         errorBlock:^(PNError *connectionError) {
//    BOOL isControlsEnabled = connectionError.code != kPNClientConnectionFailedOnInternetFailureError;
						 }];
}

- (BOOL)shouldRunClientInBackground {
	return YES;
}



@end
