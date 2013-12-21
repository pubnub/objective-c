//
//  PNAppDelegate.m
//  pubnub
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#import "PNAppDelegate.h"
#import "PNIdentificationViewController.h"
#import "PNReachability.h"

#pragma mark Private interface methods

@interface PNAppDelegate () {
	NSArray *pnChannels;
}


#pragma mark - Properties

// Stores whether client disconnected on network error
// or not
@property (nonatomic, assign, getter = isDisconnectedOnNetworkError) BOOL disconnectedOnNetworkError;


#pragma mark - Instance methods

- (void)initializePubNubClient;


@end


#pragma mark - Public interface methods

@implementation PNAppDelegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"My device token is: %@", deviceToken);

    NSString *devToken = [[[[deviceToken description]
                            stringByReplacingOccurrencesOfString:@"<"withString:@""]
                           stringByReplacingOccurrencesOfString:@">" withString:@""]
                          stringByReplacingOccurrencesOfString: @" " withString: @""];

	[[NSUserDefaults standardUserDefaults] setObject: devToken forKey: @"devToken"];
	[[NSUserDefaults standardUserDefaults] setObject: deviceToken forKey: @"deviceToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_AVAILABLE_IOS(3_0) {
	NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}

#pragma mark - Instance methods

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


#pragma mark - UIApplication delegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Configure application window and its content
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [PNIdentificationViewController new];
    [self.window makeKeyAndVisible];
    
    [self initializePubNubClient];
	[self startAsynchronousRequest];
	[self startAsynchronousRequest];
	[self startAsynchronousRequest];
	[self startAsynchronousRequest];
	[self startAsynchronousRequest];

#if !TARGET_IPHONE_SIMULATOR
	if( [[NSUserDefaults standardUserDefaults] objectForKey: @"deviceToken"] == nil ||
	   [[NSUserDefaults standardUserDefaults] objectForKey: @"devToken"] == nil )
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
#endif

	NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if(remoteNotif)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"didReceiveRemoteNotification"
															message:[NSString stringWithFormat: @"%@", remoteNotif]
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
	}

    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	NSLog(@"didReceiveRemoteNotification %@", userInfo);

	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"didReceiveRemoteNotification"
														message:[NSString stringWithFormat: @"%@", userInfo]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

#pragma mark - PubNub client delegate methods

- (void)pubnubClient:(PubNub *)client didEnablePushNotificationsOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client enabled push notifications on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client pushNotificationEnableDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed push notification enable because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisablePushNotificationsOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client disabled push notifications on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client pushNotificationDisableDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to disable push notifications because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client received push notificatino enabled channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client pushNotificationEnabledChannelsReceiveDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to receive list of channels because of error: %@", error);
}

- (void)pubnubClientDidRemovePushNotifications:(PubNub *)client {

    PNLog(PNLogGeneralLevel, self, @"PubNub client removed push notifications from all channels");
}

- (void)pubnubClient:(PubNub *)client pushNotificationsRemoveFromChannelsDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed remove push notifications from channels because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client error:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client report that error occurred: %@", error);
}

- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {


    if (self.isDisconnectedOnNetworkError) {

        PNLog(PNLogGeneralLevel, self, @"PubNub client trying to restore connection to PubNub origin at: %@", origin);
    }
    else {

        PNLog(PNLogGeneralLevel, self, @"PubNub client is about to connect to PubNub origin at: %@", origin);
    }
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {

    if (self.isDisconnectedOnNetworkError) {

        PNLog(PNLogGeneralLevel, self, @"PubNub client restored connection to PubNub origin at: %@", origin);
    }
    else {

        PNLog(PNLogGeneralLevel, self, @"PubNub client successfully connected to PubNub origin at: %@", origin);
    }



    self.disconnectedOnNetworkError = NO;
	[self subscribeOnChannels];
}

- (void)subscribeOnChannels
{
	NSLog(@"subscribeOnChannels");
//	pnChannels = [PNChannel channelsWithNames:@[@"iosdev", @"andoirddev", @"wpdev", @"ubuntudev", @"1"]];
	pnChannels = [PNChannel channelsWithNames:@[@"1", [NSString stringWithFormat: @"%@", [NSDate date]]]];
	[PubNub subscribeOnChannels: pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 NSLog(@"subscribeOnChannels, %@ %@", (subscriptionError==nil) ? @"" : @"error",  (subscriptionError== nil) ? @"" : subscriptionError);
		 //		 if( subscriptionError != nil )
		 //			 [self performSelector: @selector(errorSelector)];

		 int64_t delayInSeconds = 15;
		 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		 dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			 [self sendMessages];
		 });
	 }];
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
			 NSLog(@"send message, state %d", messageSendingState);
		 }];
	}
	[self startTest];
}

-(void)startTest {
	int64_t delayInSeconds = 15;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		NSLog(@"turning off WifI");

		int64_t delayInSeconds = 2;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			NSString *wiFiOnUrl = @"http://192.168.2.1/wiFiReconnect60.php";
			NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:wiFiOnUrl]
													 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];

			NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
			connection = nil;
		});
	});

	delayInSeconds = 50;
	popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		[self sendMessagesForFail];
		[self requestHistoryForChannelFail];
	});
}

-(void)sendMessagesForFail
{
	for( int i=0; i<pnChannels.count; i++ )
	{
		__block NSDate *start = [NSDate date];
		[PubNub sendMessage: [NSString stringWithFormat: @"Hello PubNub, %@", [NSDate date]]
				  toChannel:pnChannels[i]
		withCompletionBlock:^(PNMessageState messageSendingState, id data)
		 {
			 NSTimeInterval interval = -[start timeIntervalSinceNow];
			 NSLog(@"send message for fail, state %d, interval %f", messageSendingState, interval);
			 if( interval > 1.0 )
				 [self performSelector: @selector(errorSelectorSendMessage)];
		 }];
		NSLog(@"sendMessage");
	}
}

-(void)requestHistoryForChannel:(PNChannel *)channel
						   from:(PNDate *)startDate
							 to:(PNDate *)endDate
						  limit:(NSUInteger)limit
				 reverseHistory:(BOOL)shouldReverseMessageHistory
{
	NSDate *start = [NSDate date];
	[PubNub requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:NO
				 withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *startDate, PNDate *endDate, PNError *error)
	 {
		 NSTimeInterval interval = -[start timeIntervalSinceNow];
		 NSLog(@"history channel fail, error %@, interval %f", error, interval);
		 if( interval > 1.0 )
			 [self performSelector: @selector(errorSelectorHistory)];
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"#1 PubNub client was unable to connect because of error: %@", error);

    self.disconnectedOnNetworkError = error.code == kPNClientConnectionFailedOnInternetFailureError;
}

- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub clinet will close connection because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client closed connection because of error: %@", error);

    self.disconnectedOnNetworkError = error.code == kPNClientConnectionClosedOnInternetFailureError;
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {

    PNLog(PNLogGeneralLevel, self, @"PubNub client disconnected from PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully subscribed on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client willRestoreSubscriptionOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client resuming subscription on: %@", channels);
}

- (void)pubnubClient:(PubNub *)client didRestoreSubscriptionOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully restored subscription on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to subscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully unsubscribed from channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to unsubscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didEnablePresenceObservationOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully enabled presence observation on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client presenceObservationEnablingDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to enable presence observation because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisablePresenceObservationOnChannels:(NSArray *)channels {

    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully disabled presence observation on channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client presenceObservationDisablingDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to disable presence observation because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {

    PNLog(PNLogGeneralLevel, self, @"PubNub client recieved time token: %@", timeToken);
}

- (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to receive time token because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {

    PNLog(PNLogGeneralLevel, self, @"PubNub client is about to send message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to send message '%@' because of error: %@", message, error);
}

- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {

    PNLog(PNLogGeneralLevel, self, @"PubNub client sent message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {

    PNLog(PNLogGeneralLevel, self, @"PubNub client received message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {

    PNLog(PNLogGeneralLevel, self, @"PubNub client received presence event: %@", event);
}

- (void)    pubnubClient:(PubNub *)client
didReceiveMessageHistory:(NSArray *)messages
              forChannel:(PNChannel *)channel
            startingFrom:(PNDate *)startDate
                      to:(PNDate *)endDate {

    PNLog(PNLogGeneralLevel, self, @"PubNub client received history for %@ starting from %@ to %@: %@",
          channel, startDate, endDate, messages);
}

- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download history for %@ because of error: %@",
          channel, error);
}

- (void)      pubnubClient:(PubNub *)client
didReceiveParticipantsList:(NSArray *)participantsList
                forChannel:(PNChannel *)channel {

    PNLog(PNLogGeneralLevel, self, @"PubNub client received participants list for channel %@: %@",
          participantsList, channel);
}

- (void)                     pubnubClient:(PubNub *)client
didFailParticipantsListDownloadForChannel:(PNChannel *)channel
                                withError:(PNError *)error {

    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download participants list for channel %@ because of error: %@",
          channel, error);
}

- (NSNumber *)shouldResubscribeOnConnectionRestore {

    NSNumber *shouldResubscribeOnConnectionRestore = @(YES);

    PNLog(PNLogGeneralLevel, self, @"PubNub client should restore subscription? %@", [shouldResubscribeOnConnectionRestore boolValue] ? @"YES" : @"NO");


    return shouldResubscribeOnConnectionRestore;
}

- (NSNumber *)shouldRestoreSubscriptionFromLastTimeToken {

    NSNumber *shouldRestoreSubscriptionFromLastTimeToken = @(NO);
    NSString *lastTimeToken = @"0";

    if ([[PubNub subscribedChannels] count] > 0) {

        lastTimeToken = [[[PubNub subscribedChannels] lastObject] updateTimeToken];
    }

    PNLog(PNLogGeneralLevel, self, @"PubNub client should restore subscription from last time token? %@ (last time token: %@)",
            [shouldRestoreSubscriptionFromLastTimeToken boolValue]?@"YES":@"NO", lastTimeToken);


    return shouldRestoreSubscriptionFromLastTimeToken;
}

#pragma mark -
-(void)startAsynchronousRequest {
	NSLog(@"startAsynchronousRequest start");
	NSTimeInterval interval = [NSDate timeIntervalSinceReferenceDate];
	NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"http://google.com/%f", interval]];

	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];

	[NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
	{
		NSLog(@"startAsynchronousRequest finish, lenght %d", data.length);
		PNReachability *reach = [PNReachability serviceReachability];
		[reach isSuspended];
		[reach isServiceReachabilityChecked];
		[reach isServiceAvailable];
		[reach refreshReachabilityStateWithEvent: YES];
		[reach refreshReachabilityStateWithEvent: NO];

		int64_t delayInSeconds = 1;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		int sec = (int)interval;
		sec = sec%3;
		if( sec == 0 )
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
				[self startAsynchronousRequest];
			});
		if( sec == 1 )
			dispatch_after(popTime, dispatch_get_current_queue(), ^(void) {
				[self startAsynchronousRequest];
			});
		if( sec == 2 )
			dispatch_after(popTime, dispatch_get_global_queue(0, 0), ^(void) {
				[self startAsynchronousRequest];
			});
	}];
}

@end
