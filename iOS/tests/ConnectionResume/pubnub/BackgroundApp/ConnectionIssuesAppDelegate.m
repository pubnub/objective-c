

#import "ConnectionIssuesAppDelegate.h"
#import "PubNub.h"
#import "PNSubscribeRequest.h"

@implementation ConnectionIssuesAppDelegate

#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	delta = 0.1;
	connectionCount = 0;
	didSendMessageDelegateCount = 0;
	shouldResubscribeOnConnectionRestore = [NSNumber numberWithBool: NO];
    // Configure application window and its content
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UIViewController alloc] init];
    [self.window makeKeyAndVisible];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientDidConnectToOriginNotification:)
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
						   selector:@selector(kPNClientSubscriptionWillRestoreNotification:)
							   name:kPNClientSubscriptionWillRestoreNotification
							 object:nil];



	NSArray *arrNibViews =  [[NSBundle mainBundle] loadNibNamed: @"Log" owner: self options: nil];
	UIView *viewForLog = arrNibViews[0];
	viewForLog.frame = self.window.bounds;
	[self.window addSubview: viewForLog];
	[self addMessagetoLog: @"Start"];

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
						   selector:@selector(kPNClientSubscriptionDidFailNotification:)
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
	[self addMessagetoLog: @"wifiOff"];
	clientConnectionDidFailWithErrorNotificationCount = 0;
	didDisconnectFromOriginCountWithError = 0;
	willDisconnectWithError = 0;
	int64_t delayInSeconds = 30;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		[self addMessagetoLog: [NSString stringWithFormat: @"clientConnectionDidFailWithErrorNotificationCount %d", clientConnectionDidFailWithErrorNotificationCount]];
		[self addMessagetoLog: [NSString stringWithFormat: @"willDisconnectWithError %d", willDisconnectWithError]];
		[self addMessagetoLog: [NSString stringWithFormat: @"didDisconnectFromOriginCountWithError %d", didDisconnectFromOriginCountWithError]];
		if( clientConnectionDidFailWithErrorNotificationCount == 0 )
			[self performSelector: @selector(errorSelectorClientConnectionDidFailWithErrorNotificationCount)];
		if( didDisconnectFromOriginCountWithError == 0 )
			[self performSelector: @selector(errorSelectorDidDisconnectFromOriginCountWithError)];
		if( willDisconnectWithError == 0 )
			[self performSelector: @selector(errorSelectorWillDisconnectWithError)];
	});
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

- (void)kPNClientDidConnectToOriginNotification:(NSNotification *)notification {
	[self addMessagetoLog: [NSString stringWithFormat: @"kPNClientDidConnectToOriginNotification: %@", notification]];

	connectionCount++;
	[self addMessagetoLog: [NSString stringWithFormat: @"connectionCount %d", connectionCount]];
	self.lastTimeToken = nil;
	if( connectionCount == 1 )
		[self subscribeOnChannels];
	if( connectionCount == 2 ) {
		int64_t delayInSeconds = 20;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			[self wifiOff];
		});
	}
	if( connectionCount >= 3 ) {
		int64_t delayInSeconds = 20;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			[self sendMessagesForFail];
		});
	}
}

- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {
	[self addMessagetoLog: @"willDisconnectWithError"];
	willDisconnectWithError++;
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {
	[self addMessagetoLog: @"didDisconnectFromOrigin withError"];
	didDisconnectFromOriginCountWithError++;
}


- (void)kPNClientDidDisconnectFromOriginNotification:(NSNotification *)notification {
	PNLog(PNLogGeneralLevel, nil, @"kPNClientDidDisconnectFromOriginNotification: %@", notification);
	[self addMessagetoLog: notification.name];
	clientDidDisconnectFromOriginNotificationCount++;
}

- (void)kPNClientConnectionDidFailWithErrorNotification:(NSNotification *)notification {
	PNLog(PNLogGeneralLevel, nil, @"kPNClientConnectionDidFailWithErrorNotification: %@", notification);
	[self addMessagetoLog: notification.name];
	clientConnectionDidFailWithErrorNotificationCount++;
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
	int64_t delayInSeconds = 15;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		[self wifiOff];
	});
}

-(void)sendMessagesForFail
{
	[self addMessagetoLog: @"sendMessagesForFail"];
	startSendMessage = [NSDate date];
	messageSendingDidFailNotificationCount = 0;
	didSendMessageDelegateCount = 0;
	didReceiveMessageCount = 0;
	for( int i=0; i<pnChannels.count; i++ )
	{
		__block NSDate *start = [NSDate date];
		[PubNub sendMessage: [NSString stringWithFormat: @"Fail message, %@", [NSDate date]]
				  toChannel:pnChannels[i]
		withCompletionBlock:^(PNMessageState messageSendingState, id data)
		 {
			 NSTimeInterval interval = -[start timeIntervalSinceNow];
			 [self addMessagetoLog: [NSString stringWithFormat: @"send message for fail, state %d, interval %f", messageSendingState, interval]];
		 }];
		NSLog(@"sendMessage");
	}

	int64_t delayInSeconds = 15;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		if( didReceiveMessageCount > 0 )
			[self performSelector: @selector(errorSelectorDidReceiveMessage)];

		[self wifiOff];
	});
}

-(void)kPNClientMessageSendingDidFailNotification:(NSNotification*)notification {
	messageSendingDidFailNotificationCount++;
	NSTimeInterval interval = -[startSendMessage timeIntervalSinceNow];
	[self addMessagetoLog: [NSString stringWithFormat: @"kPNClientMessageSendingDidFailNotification, interval %f", interval]];
	if( interval > delta )
		[self performSelector: @selector(errorSelectorClientMessageSendingDidFailNotification)];
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
		[self performSelector: @selector(errorSelector)];
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
			 [self performSelector: @selector(errorSelector)];
		 [self addMessagetoLog: [NSString stringWithFormat: @"requestServerTimeToken, error %@, interval %f", error, interval]];
	 }];
}

-(void)kPNClientDidFailTimeTokenReceiveNotification:(NSNotification*)notification {
	NSTimeInterval interval = -[startTimeToken timeIntervalSinceNow];
	if( interval > delta )
		[self performSelector: @selector(errorSelector)];
	[self addMessagetoLog: [NSString stringWithFormat: @"kPNClientDidFailTimeTokenReceiveNotification, interval %f", interval]];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)kPNClientSubscriptionDidFailNotification:(NSNotification *)notification {
	[self addMessagetoLog: @"kPNClientSubscriptionDidFailNotification"];
}

- (void)kPNClientSubscriptionDidRestoreNotification:(NSNotification *)notification {
	[self addMessagetoLog: @"kPNClientSubscriptionDidRestoreNotification"];
}

-(void)kPNClientSubscriptionWillRestoreNotification:(NSNotification *)notification {
	[self addMessagetoLog: @"kPNClientSubscriptionWillRestoreNotification"];
}

- (NSNumber *)shouldResubscribeOnConnectionRestore {
	if( connectionCount >= 3 )
		[self performSelector: @selector(errorSelectorshouldResubscribeOnConnectionRestore)];
	shouldResubscribeOnConnectionRestore = [NSNumber numberWithBool: (connectionCount<2)];
	[self addMessagetoLog: [NSString stringWithFormat: @"PubNub client should restore subscription? %@", [shouldResubscribeOnConnectionRestore boolValue] ? @"YES" : @"NO"]];
    return shouldResubscribeOnConnectionRestore;
}

-(NSNumber *)shouldRestoreSubscriptionFromLastTimeToken {
	[self addMessagetoLog: @"shouldRestoreSubscriptionFromLastTimeToken NO"];
	return [NSNumber numberWithBool: NO];
}

-(void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
	[self addMessagetoLog:@"- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin"];
}

- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to send message '%@' because of error: %@", message, error);
}

- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
	didSendMessageDelegateCount++;
    PNLog(PNLogGeneralLevel, self, @"PubNub client sent message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
	didReceiveMessageCount++;
	PNLog(PNLogGeneralLevel, self, @"PubNub client received message: %@", message);
	if( [[self shouldResubscribeOnConnectionRestore] boolValue] == NO )
		[self performSelector: @selector(errorSelectorDidReceiveMessage)];
}

-(IBAction)btnClearClick:(id)sender {
	log.text = @"";
}

@end
