

#import "ConnectionIssuesAppDelegate.h"
#import "PNReachability.h"
#import "PubNub.h"

@implementation ConnectionIssuesAppDelegate

typedef enum _PNReachabilityStatus {

    // PubNub services reachability wasn't tested yet
    PNReachabilityStatusUnknown,

    // PubNub services can't be reached at this moment (looks like network/internet failure occurred)
    PNReachabilityStatusNotReachable,

#if __IPHONE_OS_VERSION_MIN_REQUIRED
    // PubNub service is reachable over cellular channel (EDGE or 3G)
    PNReachabilityStatusReachableViaCellular,
#endif

    // PubNub services is available over WiFi
    PNReachabilityStatusReachableViaWiFi
} PNReachabilityStatus;

#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	delta = 0.5;
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

	[notificationCenter addObserver:self
						   selector:@selector(handleClientSubscriptionProcess:)
							   name:kPNClientSubscriptionDidRestoreNotification
							 object:nil];

	[notificationCenter addObserver:self
						   selector:@selector(subscriptionWillRestoreNotification:)
							   name:kPNClientSubscriptionWillRestoreNotification
							 object:nil];



	NSArray *arrNibViews =  [[NSBundle mainBundle] loadNibNamed: @"Log" owner: self options: nil];
	UIView *viewForLog = arrNibViews[0];
	viewForLog.frame = self.window.bounds;
	[self.window addSubview: viewForLog];
	log.text = [log.text stringByAppendingFormat:@"%@ Start\n", [NSDate date]];

	pnChannels = [PNChannel channelsWithNames:@[@"iosdev", @"andoirddev", @"wpdev", @"ubuntudev", @"1"]];

    [self initializePubNubClient];

	[PubNub clientIdentifier];
#if TARGET_IPHONE_SIMULATOR
	wiFiOnUrl = @"http://localhost/wiFiReconnect60.php";
	wiFiOffUrl = @"http://localhost/wiFiOff.php";
#else
	wiFiOnUrl = @"http://192.168.2.1/wiFiReconnect60.php";
	wiFiOffUrl = @"http://192.168.2.1/wiFiOff.php";
#endif

	lastWiFiReconnect = [NSDate date];
	[self connect];

    return YES;
}

-(void)addMessagetoLog:(NSString*)message {
	NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
	[timeFormat setDateFormat:@"HH:mm:ss"];

	message = [NSString stringWithFormat: @"%@ %@\n", [timeFormat stringFromDate: [NSDate date]], message];
	log.text = [log.text stringByAppendingString: message];
	NSRange range = NSMakeRange(log.text.length - 1, 1);
	[log scrollRangeToVisible:range];
	NSLog(@"addMessagetoLog %@", message);
}


- (void)initializePubNubClient {

    [PubNub setDelegate:self];


	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientSubscriptionProcess:)
							   name:kPNClientSubscriptionDidFailNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientMessageSendingDidFailNotification:)
							   name:kPNClientMessageSendingDidFailNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientDidFailTimeTokenReceiveNotification:)
							   name:kPNClientDidFailTimeTokenReceiveNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientHistoryDownloadFailedWithErrorNotification:)
							   name:kPNClientHistoryDownloadFailedWithErrorNotification
							 object:nil];


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
							 PNLog(PNLogGeneralLevel, nil, @"connectionError: %@", connectionError);
						 }];
}

-(void)wifiOn {
//	log.text = [log.text stringByAppendingFormat:@"%@ start reconnect\n", [NSDate date]];
//	NSLog(@"wifiReconnect %@", [NSString stringWithContentsOfURL: [NSURL URLWithString: wiFiOnUrl] encoding: NSUTF8StringEncoding error: nil]);
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:wiFiOnUrl]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	connection = nil;
//	log.text = [log.text stringByAppendingFormat:@"%@ end reconnect\n", [NSDate date]];
}

-(void)wifiOff {
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:wiFiOnUrl]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	connection = nil;
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

- (void)handleClientDidConnectToOriginNotification:(NSNotification *)notification {
	[self addMessagetoLog: [NSString stringWithFormat: @"handleClientDidConnectToOriginNotification: %@", notification]];
//	log.text = [log.text stringByAppendingFormat:@"%@ Connected (%2.2f sec). Start reconnect\n", [NSDate date], -[lastWiFiReconnect timeIntervalSinceNow]];
////	[self wifiOff];
//	[self wifiOn];
//	log.text = [log.text stringByAppendingFormat:@"%@ reconnected wifi\n", [NSDate date]];
//	lastWiFiReconnect = [NSDate dateWithTimeIntervalSinceNow: 20];
//	NSRange range = NSMakeRange(log.text.length - 1, 1);
//	[log scrollRangeToVisible:range];
	[self subscribeOnChannels];

	int64_t delay = 10;
	dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
	dispatch_after(time, dispatch_get_main_queue(), ^(void) {
		PNReachability *serviceReachability = [[PubNub sharedInstance] performSelector:@selector(reachability)];
		NSLog(@"PNReachability status %d", (int)[serviceReachability performSelector:@selector(status)]);
		if( (int)[serviceReachability performSelector:@selector(status)] == PNReachabilityStatusNotReachable &&
		   (int)[serviceReachability performSelector:@selector(status)] == PNReachabilityStatusNotReachable ) {
			[self performSelector: @selector(errorSelectorInvalidReachabilityStatus)];
		}
		NSLog(@"PNReachability lookupStatus %d", (int)[serviceReachability performSelector:@selector(lookupStatus)]);
		if( (int)[serviceReachability performSelector:@selector(lookupStatus)] == PNReachabilityStatusNotReachable &&
		   (int)[serviceReachability performSelector:@selector(lookupStatus)] == PNReachabilityStatusNotReachable ) {
			[self performSelector: @selector(errorSelectorInvalidReachabilityStatus)];
		}
	});
}

- (void)handleClientDidDisconnectToOriginNotification:(NSNotification *)notification {
	PNLog(PNLogGeneralLevel, nil, @"handleClientDidDisconnectToOriginNotification: %@", notification);
	log.text = [log.text stringByAppendingFormat:@"%@ %@\n", [NSDate date], notification.name];

	NSRange range = NSMakeRange(log.text.length - 1, 1);
	[log scrollRangeToVisible:range];
}


- (void)subscribeOnChannels
{
	[self addMessagetoLog: @"start subscribeOnChannels"];
	pnChannels = [PNChannel channelsWithNames:@[[NSString stringWithFormat: @"%@", [NSDate date]]]];
	[PubNub subscribeOnChannels: pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 [self addMessagetoLog: [NSString stringWithFormat: @"subscribeOnChannels, %@ %@", (subscriptionError==nil) ? @"" : @"error",  (subscriptionError== nil) ? @"" : subscriptionError]];
//		 if( subscriptionError != nil )
//			 [self performSelector: @selector(errorSelector)];

		 int64_t delayInSeconds = 15;
		 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		 dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			 [self sendMessages];
		 });
	}];
}

- (void)handleClientConnectionStateChange:(NSNotification *)notification {
}

-(void)sendMessages
{
	NSLog(@"sendMessages");
	for( int i=0; i<pnChannels.count; i++ )
	{
		[PubNub sendMessage: [NSString stringWithFormat: @"Hello PubNub, %@", [NSDate date]]
												toChannel:pnChannels[i]
									  withCompletionBlock:^(PNMessageState messageSendingState, id data)
									   {
										   [self addMessagetoLog: [NSString stringWithFormat: @"send message, state %d", messageSendingState]];
									   }];
	}
	[self startTest];
}

-(void)startTest {
	int64_t delayInSeconds = 15;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		[self addMessagetoLog: @"turning off WifI"];
		[self wifiOff];

		int64_t delay = 15;
		dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
		dispatch_after(time, dispatch_get_main_queue(), ^(void) {
			PNReachability *serviceReachability = [[PubNub sharedInstance] performSelector:@selector(reachability)];
			NSLog(@"PNReachability status %d", (int)[serviceReachability performSelector:@selector(status)]);
			if( (int)[serviceReachability performSelector:@selector(status)] == PNReachabilityStatusReachableViaCellular ||
			    (int)[serviceReachability performSelector:@selector(status)] == PNReachabilityStatusReachableViaWiFi ) {
				[self performSelector: @selector(errorSelectorInvalidReachabilityStatus)];
			}
			NSLog(@"PNReachability lookupStatus %d", (int)[serviceReachability performSelector:@selector(lookupStatus)]);
			if( (int)[serviceReachability performSelector:@selector(lookupStatus)] == PNReachabilityStatusReachableViaCellular ||
			   (int)[serviceReachability performSelector:@selector(lookupStatus)] == PNReachabilityStatusReachableViaWiFi ) {
				[self performSelector: @selector(errorSelectorInvalidReachabilityStatus)];
			}
		});
	});

	delayInSeconds = 30;
	popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		[self sendMessagesForFail];
		[self requestHistoryForChannelFail];
		[self requestServerTimeTokenWithCompletionBlock];
	});
}

-(void)sendMessagesForFail
{
	[self addMessagetoLog: @"sendMessagesForFail"];
	startSendMessage = [NSDate date];
	for( int i=0; i<pnChannels.count; i++ )
	{
		__block NSDate *start = [NSDate date];
		[PubNub sendMessage: [NSString stringWithFormat: @"Hello PubNub, %@", [NSDate date]]
				  toChannel:pnChannels[i]
		withCompletionBlock:^(PNMessageState messageSendingState, id data)
		 {
			 NSTimeInterval interval = -[start timeIntervalSinceNow];
			 [self addMessagetoLog: [NSString stringWithFormat: @"send message for fail, state %d, interval %f", messageSendingState, interval]];
			 if( interval > delta )
				 [self performSelector: @selector(errorSelectorSendMesage)];
		 }];
		NSLog(@"sendMessage");
	}
}

-(void)kPNClientMessageSendingDidFailNotification:(NSNotification*)notification {
	NSTimeInterval interval = -[startSendMessage timeIntervalSinceNow];
	if( interval > delta )
		[self performSelector: @selector(errorSelectorPNClientMessageSendingDidFailNotification)];
	[self addMessagetoLog: [NSString stringWithFormat: @"kPNClientMessageSendingDidFailNotification, interval %f", interval]];
	startSendMessage = [NSDate date];
}


-(void)requestHistoryForChannel:(PNChannel *)channel
						   from:(PNDate *)startDate
							 to:(PNDate *)endDate
						  limit:(NSUInteger)limit
				 reverseHistory:(BOOL)shouldReverseMessageHistory
{
	startHistory = [NSDate date];
	NSDate *start = [NSDate date];
	[self addMessagetoLog: @"requestHistoryForChannel"];
	[PubNub requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:NO
				 withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *startDate, PNDate *endDate, PNError *error)
	 {
		 NSTimeInterval interval = -[start timeIntervalSinceNow];
		 if( interval > delta )
			 [self performSelector: @selector(errorSelectorHistoryForChannel)];
		 [self addMessagetoLog: [NSString stringWithFormat: @"history channel fail, error %@, interval %f", error, interval]];
	 }];
}

-(void)requestHistoryForChannelFail
{
	for( int i=0; i<pnChannels.count; i++ )
	{
//		PNDate *startDate = [PNDate dateWithDate:[NSDate dateWithTimeIntervalSinceNow:(-3600.0f)]];
//		PNDate *endDate = [PNDate dateWithDate:[NSDate date]];
//		int limit = 34;
//		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: limit reverseHistory: YES];
//		[self requestHistoryForChannel: pnChannels[i] from: nil to: endDate limit: 0 reverseHistory: YES];
		[self requestHistoryForChannel: pnChannels[i] from: nil to: nil limit: 0 reverseHistory: NO];
	}
}
-(void)kPNClientHistoryDownloadFailedWithErrorNotification:(NSNotification*)notification {
	NSTimeInterval interval = -[startHistory timeIntervalSinceNow];
	if( interval > delta )
		[self performSelector: @selector(errorSelectorPNClientHistoryDownloadFailedWithErrorNotification)];
	[self addMessagetoLog: [NSString stringWithFormat: @"kPNClientHistoryDownloadFailedWithErrorNotification, interval %f", interval]];
	startHistory = [NSDate date];
}
//////////////////

-(void)requestServerTimeTokenWithCompletionBlock
{
	[self addMessagetoLog: @"requestServerTimeToken"];
	startTimeToken = [NSDate date];
	NSDate *start = [NSDate date];
	[PubNub requestServerTimeTokenWithCompletionBlock:^(NSNumber *timeToken, PNError *error)
	 {
		 NSTimeInterval interval = -[start timeIntervalSinceNow];
		 if( interval > delta )
			 [self performSelector: @selector(errorSelectorServerTimeToken)];
		 [self addMessagetoLog: [NSString stringWithFormat: @"requestServerTimeToken, error %@, interval %f", error, interval]];
	 }];
}

-(void)kPNClientDidFailTimeTokenReceiveNotification:(NSNotification*)notification {
	NSTimeInterval interval = -[startTimeToken timeIntervalSinceNow];
	if( interval > delta )
		[self performSelector: @selector(errorSelectorPNClientDidFailTimeTokenReceiveNotification)];
	[self addMessagetoLog: [NSString stringWithFormat: @"kPNClientDidFailTimeTokenReceiveNotification, interval %f", interval]];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)handleClientSubscriptionProcess:(NSNotification *)notification {
    NSArray *channels = nil;
//    PNError *error = nil;
    PNSubscriptionProcessState state = PNSubscriptionProcessNotSubscribedState;

    // Check whether arrived notification that subscription failed or not
    if ([notification.name isEqualToString:kPNClientSubscriptionDidFailNotification] ||
        [notification.name isEqualToString:kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification]) {
    }
    else {

        // Retrieve list of channels on which event is occurred
        channels = (NSArray *)notification.userInfo;
        state = PNSubscriptionProcessSubscribedState;

        // Check whether arrived notification that subscription will be restored
        if ([notification.name isEqualToString:kPNClientSubscriptionWillRestoreNotification]) {

            state = PNSubscriptionProcessWillRestoreState;
        }
        // Check whether arrived notification that subscription restored
        else if ([notification.name isEqualToString:kPNClientSubscriptionDidRestoreNotification]) {

            state = PNSubscriptionProcessRestoredState;
			[self startTest];
        }
    }

}

-(void)subscriptionWillRestoreNotification:(NSNotification *)notification {
//	[self startTest];
}

-(NSNumber *)shouldRestoreSubscriptionFromLastTimeToken {
	return [NSNumber numberWithBool: YES];
}

-(void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
	NSLog(@"- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin");
//	[self startTest];
}


@end
