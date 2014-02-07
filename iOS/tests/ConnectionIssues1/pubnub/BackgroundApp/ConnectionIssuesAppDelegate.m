

#import "ConnectionIssuesAppDelegate.h"
#import "PubNub.h"

@implementation ConnectionIssuesAppDelegate

#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	delta = 11;
    // Configure application window and its content
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UIViewController alloc] init];
    [self.window makeKeyAndVisible];

	isPNSubscriptionProcessWillRestoreStateObserver = YES;
	isPNSubscriptionProcessRestoredStateObserver = YES;

	isWillRestoreSubscriptionOnChannelsDelegate = YES;
	isDidRestoreSubscriptionOnChannelsDelegate = YES;

	isPNClientSubscriptionWillRestoreNotification = YES;
	isPNClientSubscriptionDidRestoreNotification = YES;

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientDidConnectToOriginNotification:)
							   name:kPNClientDidConnectToOriginNotification
							 object:nil];

	[notificationCenter addObserver:self
						   selector:@selector(kPNClientDidDisconnectFromOriginNotification:)
							   name:kPNClientDidDisconnectFromOriginNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientConnectionDidFailWithErrorNotification:)
							   name:kPNClientConnectionDidFailWithErrorNotification
							 object:nil];

	[notificationCenter addObserver:self
						   selector:@selector(kPNClientSubscriptionDidRestoreNotification:)
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
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientSubscriptionProcess:)
//							   name:kPNClientSubscriptionDidFailNotification
//							 object:nil];
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
				 PNLog(PNLogGeneralLevel, weakSelf,  @"{BLOCK-P} PubNub client subscription failed with error: %@",  subscriptionError);
				 break;

			 case PNSubscriptionProcessSubscribedState:
				 PNLog(PNLogGeneralLevel, weakSelf,   @"{BLOCK-P} PubNub client subscribed on channels: %@",  channels);
				 break;

			 case PNSubscriptionProcessWillRestoreState:
//				 [self addMessagetoLog: [NSString stringWithFormat: @"PubNub client will restore subscribed on channels: %@", channels]];
				 isPNSubscriptionProcessWillRestoreStateObserver = YES;
				 [self addMessagetoLog: @"PNSubscriptionProcessWillRestoreStateObserver"];
				 break;

			 case PNSubscriptionProcessRestoredState:
				 isPNSubscriptionProcessRestoredStateObserver = YES;
				 [self addMessagetoLog: [NSString stringWithFormat: @"PNSubscriptionProcessRestoredStateObserver, restores subscribed on channels: %@", channels]];
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

- (void)handleClientDidConnectToOriginNotification:(NSNotification *)notification {
	[self addMessagetoLog: [NSString stringWithFormat: @"handleClientDidConnectToOriginNotification: %@", notification]];
	[self performSelector: @selector(subscribeOnChannels) withObject: nil afterDelay: 20];
}

- (void)kPNClientConnectionDidFailWithErrorNotification:(NSNotification *)notification {
	[self addMessagetoLog: @"kPNClientConnectionDidFailWithErrorNotification"];
}

- (void)kPNClientDidDisconnectFromOriginNotification:(NSNotification *)notification {
	[self addMessagetoLog: notification.name];
}


- (void)subscribeOnChannels
{
	[self addMessagetoLog: @"start subscribeOnChannels"];
	pnChannels = [PNChannel channelsWithNames:@[[NSString stringWithFormat: @"%@", [NSDate date]]]];
	__block NSDate *start = [NSDate date];
	[PubNub subscribeOnChannels: pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 NSTimeInterval interval = -[start timeIntervalSinceNow];
//		 if( interval > delta )
//			 [self performSelector: @selector(errorSelectorSubscribeOnChannels)];

		 [self addMessagetoLog: [NSString stringWithFormat: @"subscribeOnChannels, %@ %@, interval %f", (subscriptionError==nil) ? @"" : @"error",  (subscriptionError== nil) ? @"" : subscriptionError, interval]];
//		 if( subscriptionError != nil )
//			 [self performSelector: @selector(errorSelector)];

		 int64_t delayInSeconds = 15;
		 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		 dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			 [self sendMessages];
			 [self requestParticipantsListForChannel];
		 });
	}];
}

-(void)requestParticipantsListForChannel {
	for( int i=0; i<pnChannels.count; i++ ) {
		__block NSNumber *isBlockCalled = [NSNumber numberWithBool: NO];
		[self addMessagetoLog: [NSString stringWithFormat: @"requestParticipants, ch № %d", i]];
		__block NSDate *start = [NSDate date];
		[PubNub requestParticipantsListForChannel:pnChannels[i] withCompletionBlock:^(NSArray *udids, PNChannel *channel, PNError *error)
		{
			NSTimeInterval interval = -[start timeIntervalSinceNow];
			[self addMessagetoLog: [NSString stringWithFormat: @"requestParticipants finish, err %@, interval %f", error, interval]];
			if( interval > delta )
				[self performSelector: @selector(errorSelectorServerTimeToken)];
			NSLog(@"udids %@", udids);
			isBlockCalled = [NSNumber numberWithBool: YES];
		}];
		int64_t delayInSeconds = 15;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			[self addMessagetoLog: [NSString stringWithFormat: @"requestParticipants block called: %d", [isBlockCalled boolValue]]];
			if( [isBlockCalled boolValue] == NO )
				[self performSelector: @selector(errorSelectorRequestParticipantsListForChannel)];
		});
	}
}

- (void)handleClientConnectionStateChange:(NSNotification *)notification {
}

-(void)sendMessages {
	[self addMessagetoLog:@"sendMessages"];
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
//	if( isPNSubscriptionProcessWillRestoreStateObserver == NO )
//		[self performSelector: @selector(errorSelectorPNSubscriptionProcessRestoredState)];
	if( isPNSubscriptionProcessWillRestoreStateObserver == NO || isPNSubscriptionProcessRestoredStateObserver == NO || isWillRestoreSubscriptionOnChannelsDelegate == NO || isDidRestoreSubscriptionOnChannelsDelegate == NO || isPNClientSubscriptionWillRestoreNotification == NO || isPNClientSubscriptionDidRestoreNotification == NO )
		[self performSelector: @selector(errorSelectorRestore)];

	int64_t delayInSeconds = 14;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		[self requestParticipantsListForChannel];
	});

	delayInSeconds = 15;
	popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		[self addMessagetoLog: @"turning off WifI"];
		isPNSubscriptionProcessWillRestoreStateObserver = NO;
		isPNSubscriptionProcessRestoredStateObserver = NO;

		isWillRestoreSubscriptionOnChannelsDelegate = NO;
		isDidRestoreSubscriptionOnChannelsDelegate = NO;

		isPNClientSubscriptionWillRestoreNotification = NO;
		isPNClientSubscriptionDidRestoreNotification = NO;
		[self wifiOff];
	});

	delayInSeconds = 30;
	popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		[self sendMessagesForFail];
		[self requestHistoryForChannelFail];
		[self requestServerTimeTokenWithCompletionBlock];
		[self requestParticipantsListForChannel];
	});
}

-(void)sendMessagesForFail
{
	//[self addMessagetoLog: @"sendMessagesForFail start"];
	for( int i=0; i<pnChannels.count; i++ )
	{
		__block NSDate *start;
		startSendMessage = [NSDate date];
		[self addMessagetoLog: [NSString stringWithFormat: @"sendMessagesForFail start, channel № %d", i]];
		[PubNub sendMessage: [NSString stringWithFormat: @"Hello PubNub (fail), %@", [NSDate date]]
				  toChannel:pnChannels[i]
		withCompletionBlock:^(PNMessageState messageSendingState, id data)
		 {
			 if( messageSendingState == PNMessageSending ) {
				 [self addMessagetoLog: @"PNMessageSending"];
				startSendMessage = [NSDate date];
				start = [NSDate date];
				return;
			 }

			 NSTimeInterval interval = -[start timeIntervalSinceNow];
			 [self addMessagetoLog: [NSString stringWithFormat: @"send message for fail, state %d, interval %f", messageSendingState, interval]];
			 if( interval > delta )
				 [self performSelector: @selector(errorSelectorSendMessage)];
		 }];
		NSLog(@"sendMessage");
	}
}

-(void)kPNClientMessageSendingDidFailNotification:(NSNotification*)notification {
	[self addMessagetoLog: [NSString stringWithFormat: @"kPNClientMessageSendingDidFailNotification %@", notification]];
	NSTimeInterval interval = -[startSendMessage timeIntervalSinceNow];
	[self addMessagetoLog: [NSString stringWithFormat: @"kPNClientMessageSendingDidFailNotification, interval %f", interval]];
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
		 [self addMessagetoLog: [NSString stringWithFormat: @"history channel fail, error %@, interval %f", error, interval]];
//		 if( interval > delta )
//			 [self performSelector: @selector(errorSelectorHistoryForChannel)];
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
		 [self addMessagetoLog: [NSString stringWithFormat: @"requestServerTimeToken, error %@, interval %f", error, interval]];
		 if( interval > delta )
			 [self performSelector: @selector(errorSelectorServerTimeToken)];
	 }];
}

-(void)kPNClientDidFailTimeTokenReceiveNotification:(NSNotification*)notification {
	NSTimeInterval interval = -[startTimeToken timeIntervalSinceNow];
	[self addMessagetoLog: [NSString stringWithFormat: @"kPNClientDidFailTimeTokenReceiveNotification, interval %f", interval]];
	if( interval > delta )
		[self performSelector: @selector(errorSelectorPNClientDidFailTimeTokenReceiveNotification)];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////

//- (void)handleClientSubscriptionProcess:(NSNotification *)notification {
//    NSArray *channels = nil;
////    PNError *error = nil;
//    PNSubscriptionProcessState state = PNSubscriptionProcessNotSubscribedState;
//
//    // Check whether arrived notification that subscription failed or not
//    if ([notification.name isEqualToString:kPNClientSubscriptionDidFailNotification] ||
//        [notification.name isEqualToString:kPNClientSubscriptionDidFailOnClientIdentifierUpdateNotification]) {
//    }
//    else {
//
//        // Retrieve list of channels on which event is occurred
//        channels = (NSArray *)notification.userInfo;
//        state = PNSubscriptionProcessSubscribedState;
//
//        // Check whether arrived notification that subscription will be restored
//        if ([notification.name isEqualToString:kPNClientSubscriptionWillRestoreNotification]) {
//
//            state = PNSubscriptionProcessWillRestoreState;
//        }
//        // Check whether arrived notification that subscription restored
//        else if ([notification.name isEqualToString:kPNClientSubscriptionDidRestoreNotification]) {
//
//            state = PNSubscriptionProcessRestoredState;
//			[self startTest];
//        }
//    }
//}

-(void)subscriptionWillRestoreNotification:(NSNotification *)notification {
	isPNClientSubscriptionWillRestoreNotification = YES;
	[self addMessagetoLog: @"kPNClientSubscriptionWillRestoreNotification"];
}

-(void)kPNClientSubscriptionDidRestoreNotification:(NSNotification *)notification {
	isPNClientSubscriptionDidRestoreNotification = YES;
	[self addMessagetoLog: @"kPNClientSubscriptionDidRestoreNotification"];
//	if( isPNClientSubscriptionWillRestoreNotification == NO )
//		[self performSelector: @selector(errorSelectorSubscriptionWillRestoreNotification)];

//	[self performSelector: @selector(startTest) withObject: nil afterDelay: 10];
}

-(NSNumber *)shouldRestoreSubscriptionFromLastTimeToken {
	return [NSNumber numberWithBool: YES];
}

-(void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
	NSLog(@"- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin");
//	[self startTest];
}

- (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels {
	isWillRestoreSubscriptionOnChannelsDelegate = YES;
	[self addMessagetoLog: @"WillRestoreSubscriptionOnChannelsDelegate"];
}

- (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels {
	isDidRestoreSubscriptionOnChannelsDelegate = YES;
	[self addMessagetoLog:@"DidRestoreSubscriptionOnChannelsDelegate"];
	if( isWillRestoreSubscriptionOnChannelsDelegate == NO )
		[self performSelector: @selector(errorSelectorDidRestoreSubscriptionOnChannels)];
}


@end
