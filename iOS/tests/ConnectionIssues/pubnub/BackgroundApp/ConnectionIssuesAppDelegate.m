

#import "ConnectionIssuesAppDelegate.h"
#import "PubNub.h"

@implementation ConnectionIssuesAppDelegate

#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Configure application window and its content
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UIViewController alloc] init];
    [self.window makeKeyAndVisible];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientDidConnectToOriginNotification:)
							   name:kPNClientDidConnectToOriginNotification
							 object:nil];

	[notificationCenter addObserver:self
						   selector:@selector(handleClientDidDisconnectToOriginNotification:)
							   name:kPNClientDidDisconnectFromOriginNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientDidDisconnectToOriginNotification:)
							   name:kPNClientConnectionDidFailWithErrorNotification
							 object:nil];
	
	NSArray *arrNibViews =  [[NSBundle mainBundle] loadNibNamed: @"Log" owner: self options: nil];
	UIView *viewForLog = arrNibViews[0];
	viewForLog.frame = self.window.bounds;
	[self.window addSubview: viewForLog];
	log.text = [log.text stringByAppendingFormat:@"%@ Start\n", [NSDate date]];

    [self initializePubNubClient];

	[PubNub clientIdentifier];
#if TARGET_IPHONE_SIMULATOR
	wiFiOnUrl = @"http://localhost/wiFiReconnect.php";
#else
	wiFiOnUrl = @"http://192.168.2.1/wiFiReconnect.php";
#endif

	lastWiFiReconnect = [NSDate date];
	[self connect];

    return YES;
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

-(void)wifiOn {
//	log.text = [log.text stringByAppendingFormat:@"%@ start reconnect\n", [NSDate date]];
//	NSLog(@"wifiReconnect %@", [NSString stringWithContentsOfURL: [NSURL URLWithString: wiFiOnUrl] encoding: NSUTF8StringEncoding error: nil]);
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:wiFiOnUrl]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];

    // создаём соединение и начинаем загрузку
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

//	log.text = [log.text stringByAppendingFormat:@"%@ end reconnect\n", [NSDate date]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"connection didReceiveResponse");
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
	NSLog(@"connection didReceiveData");
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
	NSLog(@"connection willCacheResponse");
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"connection connectionDidFinishLoading");
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"connection didFailWithError %@", error);
    // The request has failed for some reason!
    // Check the error var
}

-(void)wifiOff {
	[NSString stringWithContentsOfURL: [NSURL URLWithString: wiFiOffUrl] encoding: NSUTF8StringEncoding error: nil];
}

- (void)handleClientDidConnectToOriginNotification:(NSNotification *)notification {
	PNLog(PNLogGeneralLevel, nil, @"handleClientDidConnectToOriginNotification: %@", notification);
	log.text = [log.text stringByAppendingFormat:@"%@ Connected (%2.2f sec). Start reconnect\n", [NSDate date], -[lastWiFiReconnect timeIntervalSinceNow]];
//	[self wifiOff];
	[self wifiOn];
//	log.text = [log.text stringByAppendingFormat:@"%@ reconnected wifi\n", [NSDate date]];
	lastWiFiReconnect = [NSDate dateWithTimeIntervalSinceNow: 20];

	NSRange range = NSMakeRange(log.text.length - 1, 1);
	[log scrollRangeToVisible:range];
}

- (void)handleClientDidDisconnectToOriginNotification:(NSNotification *)notification {
	PNLog(PNLogGeneralLevel, nil, @"handleClientDidDisconnectToOriginNotification: %@", notification);
	log.text = [log.text stringByAppendingFormat:@"%@ %@\n", [NSDate date], notification.name];

	NSRange range = NSMakeRange(log.text.length - 1, 1);
	[log scrollRangeToVisible:range];
}


@end
