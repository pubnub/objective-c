//
//  PNChaosTest.m
//  pubnub
//
//  Created by Valentin Tuller on 9/19/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "W_ChaosTest.h"
#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNConnection.h"
#import "PNNotifications.h"
#import "PNChannel.h"
#import "Swizzler.h"
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import <OCMock/OCMock.h>

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
//#import "PNDataManager.h"

@interface W_ChaosTest () <PNDelegate>
{
	BOOL connectedFinish;
	NSArray *pnChannels;
	NSArray *pnChannelsBad;
	BOOL subscribeOnChannelsFinish;
	BOOL participantsListForChannelFinish;
	BOOL notifyDidDisconnectWithErrorCalled;
	BOOL shouldReconnectPubNubClient;

	dispatch_semaphore_t semaphoreNotification;

	BOOL handleApplicationDidEnterBackgroundState;
	BOOL handleApplicationDidEnterForegroundState;
	BOOL handleWorkspaceWillSleep;
	BOOL handleWorkspaceDidWake;
	BOOL handleClientConnectionStateChange;
	BOOL handleClientSubscriptionProcess;
	BOOL handleClientUnsubscriptionProcess;
	BOOL handleClientPresenceObservationEnablingProcess;
	BOOL handleClientPresenceObservationDisablingProcess;
	BOOL handleClientPushNotificationStateChange;
	BOOL handleClientPushNotificationRemoveProcess;
	BOOL handleClientPushNotificationEnabledChannels;
	BOOL handleClientMessageProcessingStateChange;
	BOOL handleClientDidReceiveMessage;
	BOOL handleClientDidReceivePresenceEvent;
	BOOL handleClientMessageHistoryProcess;
	BOOL handleClientHereNowProcess;
	BOOL handleClientCompletedTimeTokenProcessing;

	int willConnectCount;
}
@end

@implementation W_ChaosTest

-(NSNumber *)shouldReconnectPubNubClient:(id)object {
	return [NSNumber numberWithBool: shouldReconnectPubNubClient];
}

- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to subscribe because of error: %@", error);
	subscribeOnChannelsFinish = YES;
}

//nonSubscriptionRequestTimeout
- (void)pubnubClient:(PubNub *)client didFailParticipantsListDownloadForChannel:(PNChannel *)channel withError:(PNError *)error {
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download participants list for channel %@ because of error: %@",
          channel, error);
	participantsListForChannelFinish = YES;
}

- (void)setUp
{
    [super setUp];
	semaphoreNotification = dispatch_semaphore_create(0);
    [PubNub setDelegate:self];
	pnChannels = [PNChannel channelsWithNames:@[@"iosdev", @"1"]];
	pnChannelsBad = [PNChannel channelsWithNames:@[@"iosdev", @"", @""]];

	shouldReconnectPubNubClient = NO;


#if __IPHONE_OS_VERSION_MIN_REQUIRED
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationDidEnterBackgroundState:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleApplicationDidEnterForegroundState:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
#else
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(handleWorkspaceWillSleep:)
                                                               name:NSWorkspaceWillSleepNotification
                                                             object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(handleWorkspaceWillSleep:)
                                                               name:NSWorkspaceSessionDidResignActiveNotification
                                                             object:nil];

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(handleWorkspaceDidWake:)
                                                               name:NSWorkspaceDidWakeNotification
                                                             object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(handleWorkspaceDidWake:)
                                                               name:NSWorkspaceSessionDidBecomeActiveNotification
                                                             object:nil];
#endif

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
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientWillConnectToOriginNotification:)
							   name:kPNClientWillConnectToOriginNotification
							 object:nil];


	// Handle subscription events
	[notificationCenter addObserver:self
						   selector:@selector(handleClientSubscriptionProcess:)
							   name:kPNClientSubscriptionDidCompleteNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientSubscriptionProcess:)
							   name:kPNClientSubscriptionWillRestoreNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientSubscriptionProcess:)
							   name:kPNClientSubscriptionDidRestoreNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientSubscriptionProcess:)
							   name:kPNClientSubscriptionDidFailNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientUnsubscriptionProcess:)
							   name:kPNClientUnsubscriptionDidCompleteNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientUnsubscriptionProcess:)
							   name:kPNClientUnsubscriptionDidFailNotification
							 object:nil];

	// Handle presence events
	[notificationCenter addObserver:self
						   selector:@selector(handleClientPresenceObservationEnablingProcess:)
							   name:kPNClientPresenceEnablingDidCompleteNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientPresenceObservationEnablingProcess:)
							   name:kPNClientPresenceEnablingDidFailNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientPresenceObservationDisablingProcess:)
							   name:kPNClientPresenceDisablingDidCompleteNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientPresenceObservationDisablingProcess:)
							   name:kPNClientPresenceDisablingDidFailNotification
							 object:nil];


	// Handle push notification state changing events
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleClientPushNotificationStateChange:)
												 name:kPNClientPushNotificationEnableDidCompleteNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleClientPushNotificationStateChange:)
												 name:kPNClientPushNotificationEnableDidFailNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleClientPushNotificationStateChange:)
												 name:kPNClientPushNotificationDisableDidCompleteNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleClientPushNotificationStateChange:)
												 name:kPNClientPushNotificationDisableDidFailNotification
											   object:nil];


	// Handle push notification remove events
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleClientPushNotificationRemoveProcess:)
												 name:kPNClientPushNotificationRemoveDidCompleteNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleClientPushNotificationRemoveProcess:)
												 name:kPNClientPushNotificationRemoveDidFailNotification
											   object:nil];


	// Handle push notification enabled channels retrieve events
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleClientPushNotificationEnabledChannels:)
												 name:kPNClientPushNotificationChannelsRetrieveDidCompleteNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleClientPushNotificationEnabledChannels:)
												 name:kPNClientPushNotificationChannelsRetrieveDidFailNotification
											   object:nil];


	// Handle time token events
	[notificationCenter addObserver:self
						   selector:@selector(handleClientCompletedTimeTokenProcessing:)
							   name:kPNClientDidReceiveTimeTokenNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientCompletedTimeTokenProcessing:)
							   name:kPNClientDidFailTimeTokenReceiveNotification
							 object:nil];


	// Handle message processing events
	[notificationCenter addObserver:self
						   selector:@selector(handleClientMessageProcessingStateChange:)
							   name:kPNClientWillSendMessageNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientMessageProcessingStateChange:)
							   name:kPNClientDidSendMessageNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientMessageProcessingStateChange:)
							   name:kPNClientMessageSendingDidFailNotification
							 object:nil];

	// Handle messages/presence event arrival
	[notificationCenter addObserver:self
						   selector:@selector(handleClientDidReceiveMessage:)
							   name:kPNClientDidReceiveMessageNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientDidReceivePresenceEvent:)
							   name:kPNClientDidReceivePresenceEventNotification
							 object:nil];

	// Handle message history events arrival
	[notificationCenter addObserver:self
						   selector:@selector(handleClientMessageHistoryProcess:)
							   name:kPNClientDidReceiveMessagesHistoryNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientMessageHistoryProcess:)
							   name:kPNClientHistoryDownloadFailedWithErrorNotification
							 object:nil];

	// Handle participants list arrival
	[notificationCenter addObserver:self
						   selector:@selector(handleClientHereNowProcess:)
							   name:kPNClientDidReceiveParticipantsListNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientHereNowProcess:)
							   name:kPNClientParticipantsListDownloadFailedWithErrorNotification
							 object:nil];


}

#pragma mark - Handler methods

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)handleApplicationDidEnterBackgroundState:(NSNotification *)__unused notification {
	PNLog(PNLogGeneralLevel, self, @"NSNotification handleApplicationDidEnterBackgroundState: %@", notification);
	handleApplicationDidEnterBackgroundState = YES;
}

- (void)handleApplicationDidEnterForegroundState:(NSNotification *)__unused notification  {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleApplicationDidEnterForegroundState: %@", notification);
	handleApplicationDidEnterForegroundState = YES;
}
#else
- (void)handleWorkspaceWillSleep:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleWorkspaceWillSleep: %@", notification);
	handleWorkspaceWillSleep = YES;
}

- (void)handleWorkspaceDidWake:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleWorkspaceDidWake: %@", notification);
	handleWorkspaceDidWake = YES;
}
#endif


- (void)kPNClientWillConnectToOriginNotification:(NSNotification *)notification {
    NSLog(@"kPNClientWillConnectToOriginNotification");
	willConnectCount++;
}

- (void)handleClientConnectionStateChange:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientConnectionStateChange: %@", notification);
	handleClientConnectionStateChange = YES;
}

- (void)handleClientSubscriptionProcess:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientSubscriptionProcess: %@", notification);
	handleClientSubscriptionProcess = YES;
}

- (void)handleClientUnsubscriptionProcess:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientUnsubscriptionProcess: %@", notification);
	handleClientUnsubscriptionProcess = YES;
}

- (void)handleClientPresenceObservationEnablingProcess:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientPresenceObservationEnablingProcess: %@", notification);
	handleClientPresenceObservationEnablingProcess = YES;
}

- (void)handleClientPresenceObservationDisablingProcess:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientPresenceObservationDisablingProcess: %@", notification);
	handleClientPresenceObservationDisablingProcess = YES;
}

- (void)handleClientPushNotificationStateChange:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientPushNotificationStateChange: %@", notification);
	handleClientPushNotificationStateChange = YES;
}

- (void)handleClientPushNotificationRemoveProcess:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientPushNotificationRemoveProcess: %@", notification);
	handleClientPushNotificationRemoveProcess = YES;
}

- (void)handleClientPushNotificationEnabledChannels:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientPushNotificationEnabledChannels: %@", notification);
	handleClientPushNotificationEnabledChannels = YES;
}

- (void)handleClientMessageProcessingStateChange:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientMessageProcessingStateChange: %@", notification);
	handleClientMessageProcessingStateChange = YES;
}

- (void)handleClientDidReceiveMessage:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientDidReceiveMessage: %@", notification);
	handleClientDidReceiveMessage = YES;
}

- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientDidReceivePresenceEvent: %@", notification);
	handleClientDidReceivePresenceEvent = YES;
}

- (void)handleClientMessageHistoryProcess:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientMessageHistoryProcess: %@", notification);
	handleClientMessageHistoryProcess = YES;
}

- (void)handleClientHereNowProcess:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientHereNowProcess: %@", notification);
	handleClientHereNowProcess = YES;
}

- (void)handleClientCompletedTimeTokenProcessing:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientCompletedTimeTokenProcessing: %@", notification);
	handleClientCompletedTimeTokenProcessing = YES;
}


#pragma mark - States tests

- (void)t05AddClientConnectionStateObserver
{
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self
                                                        withCallbackBlock:^(NSString *origin,
                                                                            BOOL connected,
                                                                            PNError *error)
	 {
		 STAssertNil( error, @"error %@", error);
		 if (!connected && error) {
			 PNLog(PNLogGeneralLevel, self, @"#2 PubNub client was unable to connect because of error: %@",
				   [error localizedDescription],
				   [error localizedFailureReason]);
		 }
	 }];
}

- (void)t06ClientChannelSubscriptionStateObserver
{
    // Subscribe application delegate on subscription updates
    // (events when client subscribe on some channel)
    __pn_desired_weak __typeof__(self) weakSelf = self;
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:weakSelf
                                                                 withCallbackBlock:^(PNSubscriptionProcessState state,
                                                                                     NSArray *channels,
                                                                                     PNError *subscriptionError)
	 {
		 STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
		 STAssertFalse( state == PNSubscriptionProcessNotSubscribedState, @"state == PNSubscriptionProcessNotSubscribedState, %@", subscriptionError );
	 }];
}

- (void)t08AddPresenceEventObserver
{
    // Subscribe on presence event arrival events with block
	__pn_desired_weak __typeof__(self) weakSelf = self;
    [[PNObservationCenter defaultCenter] addPresenceEventObserver:weakSelf
                                                        withBlock:^(PNPresenceEvent *presenceEvent) {

                                                            PNLog(PNLogGeneralLevel, weakSelf, @"{BLOCK-P} PubNubc client received new event: %@",
																  presenceEvent);
                                                        }];
}

-(void)resetConnection {
	[PubNub resetClient];
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"chaos.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil];
		[PubNub setConfiguration: configuration];

		[PubNub connectWithSuccessBlock:^(NSString *origin) {

			NSLog(@"PubNub client connected to: %@", origin);
			dispatch_semaphore_signal(semaphore);
		}
							 errorBlock:^(PNError *connectionError) {
								 NSLog(@"connectionError %@", connectionError);
								 dispatch_semaphore_signal(semaphore);
							 }];
	});
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
}

- (void)test09Connect
{
	[PubNub disconnect];
	[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
							 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	shouldReconnectPubNubClient = NO;
	willConnectCount = 0;

	for( int i=0; i<1; i++ )
	{
		[self resetConnection];

		BOOL isConnected = [[PubNub sharedInstance] isConnected];
		if( isConnected == YES )
			break;
	}
	for( int j=0; [[PubNub sharedInstance] isConnected] == NO && j<15; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

	STAssertTrue( willConnectCount<=5, @"extra reconnect attemp");

	[self t10Connect];
	[self t05AddClientConnectionStateObserver];
	[self t06ClientChannelSubscriptionStateObserver];
	[self t08AddPresenceEventObserver];
	[self t20SubscribeOnChannels];
	[self t30RequestParticipantsListForChannel];
	[self t35RequestServerTimeTokenWithCompletionBlock];
	[self t40RequestHistoryForChannel];
	[self t50SendMessage];
	[self t900UnsubscribeFromChannels];
}


- (void)t10Connect
{
	[PubNub disconnect];
	[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
							 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	shouldReconnectPubNubClient = YES;

	for( int i=0; i<1; i++ )
	{
		[self resetConnection];

		BOOL isConnected = [[PubNub sharedInstance] isConnected];
		if( isConnected == YES )
			break;
//		NSLog(@"attemt №%d", i);
	}
	for( int j=0; [[PubNub sharedInstance] isConnected] == NO && j<15; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

	BOOL isConnected = [[PubNub sharedInstance] isConnected];
	STAssertTrue( isConnected, @"not connection");
}

- (void)t20SubscribeOnChannels
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	handleClientSubscriptionProcess = NO;
	[PubNub subscribeOnChannels: pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 dispatch_semaphore_signal(semaphore);
		 STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
		 STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
		 //		connectedChannels = channels;
		 switch(state) {
			 case PNSubscriptionProcessNotSubscribedState:
				 // Check whether 'subscriptionError' instance is nil or not (if not, handle error)
				 break;
			 case PNSubscriptionProcessSubscribedState:
				 // Do something after subscription completed
				 break;
			 case PNSubscriptionProcessWillRestoreState:
				 // Library is about to restore subscription on channels after connection went down and restored
				 break;
			 case PNSubscriptionProcessRestoredState:
				 // Handle event that client completed resubscription
				 break;
		 }
	 }];
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	STAssertTrue( handleClientSubscriptionProcess, @"notification not caleld");
}

-(void)t30RequestParticipantsListForChannel
{
	for( int i=0; i<pnChannels.count; i++ )
	{
		handleClientHereNowProcess = NO;
		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		//		PNLog(PNLogGeneralLevel, nil, @"pnChannels[i] %@", pnChannels[i]);
		[PubNub requestParticipantsListForChannel:pnChannels[i]
							  withCompletionBlock:^(NSArray *udids, PNChannel *channel, PNError *error)
		 {
			 if( error != nil )
				 PNLog(PNLogGeneralLevel, nil, @"error %@", error);
			 STAssertNil( error, @"error %@", error);
			 dispatch_semaphore_signal(semaphore);
			 NSLog(@"udids %@", udids);
		 }];
		while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
									 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
		STAssertTrue(handleClientHereNowProcess, @"notification not called");
	}
}

-(void)t35RequestServerTimeTokenWithCompletionBlock
{
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	handleClientCompletedTimeTokenProcessing = NO;
	[PubNub requestServerTimeTokenWithCompletionBlock:^(NSNumber *timeToken, PNError *error)
	 {
		 dispatch_semaphore_signal(semaphore);
		 STAssertNil( error, @"error %@", error);
	 }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	STAssertTrue(handleClientCompletedTimeTokenProcessing, @"notification not called");
}

-(void)requestHistoryForChannel:(PNChannel *)channel
						   from:(PNDate *)startDate
							 to:(PNDate *)endDate
						  limit:(NSUInteger)limit
				 reverseHistory:(BOOL)shouldReverseMessageHistory
{
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	handleClientMessageHistoryProcess = NO;
	[PubNub requestHistoryForChannel:channel
								from:startDate
								  to:endDate
							   limit:limit
					  reverseHistory:NO
				 withCompletionBlock:^(NSArray *messages,
									   PNChannel *channel,
									   PNDate *startDate,
									   PNDate *endDate,
									   PNError *error)
	 {
		 dispatch_semaphore_signal(semaphore);
		 STAssertNil( error, @"error %@", error);
	 }];
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW) || handleClientMessageHistoryProcess == NO)
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

-(void)t40RequestHistoryForChannel
{
	for( int i=0; i<pnChannels.count; i++ )
	{
		PNDate *startDate = [PNDate dateWithDate:[NSDate dateWithTimeIntervalSinceNow:(-3600.0f)]];
		PNDate *endDate = [PNDate dateWithDate:[NSDate date]];
		int limit = 34;
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: limit reverseHistory: YES];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: 0 reverseHistory: NO];
		[self requestHistoryForChannel: pnChannels[i] from: nil to: endDate limit: 0 reverseHistory: YES];
	}
}

-(void)t50SendMessage
{
	for( int i=0; i<pnChannels.count; i++ )
	{
		handleClientMessageProcessingStateChange = NO;
		handleClientDidReceiveMessage = NO;
		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		__block PNMessageState state = PNMessageSendingError;
		/*PNMessage *helloMessage = */[PubNub sendMessage:@"Hello PubNub"
												toChannel:pnChannels[i]
									  withCompletionBlock:^(PNMessageState messageSendingState, id data)
									   {
										   dispatch_semaphore_signal(semaphore);
										   state = messageSendingState;
										   STAssertFalse(messageSendingState==PNMessageSendingError, @"messageSendingState==PNMessageSendingError %@", data);
										   switch (messageSendingState)
										   {
											   case PNMessageSending:
												   // Handle message sending event (it means that message processing started and
												   // still in progress)
												   break;
											   case PNMessageSent:
												   // Handle message sent event
												   break;
											   case PNMessageSendingError:
												   // Retry message sending (but in real world should check error and hanle it)
												   //											  [PubNub sendMessage:helloMessage];
												   break;
										   }
									   }];

		while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
									 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
		STAssertTrue(handleClientMessageProcessingStateChange, @"notification not called");
		STAssertTrue(handleClientDidReceiveMessage || state != PNMessageSent, @"notificaition not called");
	}
}


-(void)t900UnsubscribeFromChannels
{
	handleClientUnsubscriptionProcess = YES;
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	[PubNub unsubscribeFromChannels: pnChannels withCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError) {
		 dispatch_semaphore_signal(semaphore);
		 STAssertNil( unsubscribeError, @"unsubscribeError %@", unsubscribeError);
		 STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
	 }];
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	STAssertTrue(handleClientUnsubscriptionProcess, @"notification not called");
}


@end
