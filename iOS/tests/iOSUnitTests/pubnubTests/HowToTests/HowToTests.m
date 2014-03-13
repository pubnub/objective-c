//
//  PNBaseRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "HowToTests.h"
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import <OCMock/OCMock.h>

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNConnection.h"
#import "TestSemaphor.h"
#import "Swizzler.h"
#import "PNConnectionBadJson.h"
#import "PNMessageHistoryRequest.h"

@interface HowToTests ()

@property (nonatomic, assign) NSUInteger retryCount;

@end

@interface HowToTests () <PNDelegate>
{
	NSArray *pnChannels;
	NSArray *pnChannelsBad;
	dispatch_semaphore_t semaphoreNotification;
	NSArray *pnChannelsForReverse;

	SwizzleReceipt *receiptReconnect;
	int _reconnectCount;
	NSNumber *_reconnectNumber;
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
	BOOL pNClientDidSendMessageNotification;
	BOOL pNClientMessageSendingDidFailNotification;

	BOOL pNClientPresenceEnablingDidCompleteNotification;
	BOOL pNClientPresenceDisablingDidCompleteNotification;

	NSDate *dateMessage;
}

@property (nonatomic, retain) NSConditionLock *theLock;

@end


@implementation HowToTests

//- (void)setUp {
//    [super setUp];
- (void)test01Init {
	[PubNub resetClient];
	NSLog(@"end reset");
	for( int j=0; j<5; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

	semaphoreNotification = dispatch_semaphore_create(0);
    [PubNub setDelegate:self];
	pnChannels = [PNChannel channelsWithNames:@[@"iosdev1", @"andoirddev1", @"wpdev1", @"ubuntudev1", @"11"]];
	pnChannelsBad = [PNChannel channelsWithNames:@[@"iosdev", @"andoirddev", @"wpdev", @"", @""]];
	pnChannelsForReverse = [PNChannel channelsWithNames:@[[NSString stringWithFormat: @"%@", [NSDate date]]]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendRequest:) name:@"didSendRequest" object:nil];

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
						   selector:@selector(kPNClientDidSendMessageNotification:)
							   name:kPNClientDidSendMessageNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientMessageSendingDidFailNotification:)
							   name:kPNClientMessageSendingDidFailNotification
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

	[notificationCenter addObserver:self
						   selector:@selector(kPNClientPresenceEnablingDidCompleteNotification:)
							   name:kPNClientPresenceEnablingDidCompleteNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientPresenceDisablingDidCompleteNotification:)
							   name:kPNClientPresenceDisablingDidCompleteNotification
							 object:nil];


	[self t05AddClientConnectionStateObserver];
	[self t06ClientChannelSubscriptionStateObserver];
	[self t08AddPresenceEventObserver];
	[self t10ConnectNormal];
	[self t20SubscribeOnChannels];
	[self t25RequestParticipantsListForChannelRevert];
	[self t30RequestParticipantsListForChannel];
	[self t35RequestServerTimeTokenWithCompletionBlock];
	[self t40SendMessage];
//	[self t45SendMessageBig];
	[self t50RequestHistoryForChannel];
	[self t55RequestHistoryReverse];
	[self t60SubscribeOnChannelsByTurns];
	[self t900UnsubscribeFromChannels];

	[self t10ConnectPresence];
	[self t20SubscribeOnChannels];
	[self t25RequestParticipantsListForChannelRevert];
	[self t30RequestParticipantsListForChannel];
	[self t35RequestServerTimeTokenWithCompletionBlock];
	[self t40SendMessage];
	[self t45SendMessageBig];
//	[self t50RequestHistoryForChannel];
//	[self t55RequestHistoryReverse];
	[self t60SubscribeOnChannelsByTurns];
	[self t900UnsubscribeFromChannels];
	[self t910removeClientChannelSubscriptionStateObserver];
}

#pragma mark - Handler methods

- (void)kPNClientPresenceEnablingDidCompleteNotification:(NSNotification *)__unused notification {
	PNLog(PNLogGeneralLevel, self, @"NSNotification kPNClientPresenceEnablingDidCompleteNotification: %@", notification);
	pNClientPresenceEnablingDidCompleteNotification = YES;
}
- (void)kPNClientPresenceDisablingDidCompleteNotification:(NSNotification *)__unused notification {
	PNLog(PNLogGeneralLevel, self, @"NSNotification kPNClientPresenceDisablingDidCompleteNotification: %@", notification);
	pNClientPresenceDisablingDidCompleteNotification = YES;
}


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
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientMessageProcessingStateChange: %@", notification.name);
	handleClientMessageProcessingStateChange = YES;
}


- (void)kPNClientDidSendMessageNotification:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification kPNClientDidSendMessageNotification");
	pNClientDidSendMessageNotification = YES;

	PNMessage *message = (PNMessage*)notification.userInfo;
	NSLog(@"message dates %@, %@", message.date, message.receiveDate);
	if( [message.message isKindOfClass: [NSString class]] == YES && [message.message rangeOfString: @"Hello PubNub"].location != NSNotFound ) {
		STAssertTrue( message.date != nil, @"");
		NSDate *date = [message.date date];
		NSTimeInterval interval = -[date timeIntervalSinceNow];
		STAssertTrue( interval < 300 && interval > - 300, @"invalid message.date - %f", interval);
		if( dateMessage != nil )
			STAssertTrue( [dateMessage compare: date] == NSOrderedAscending, @"invalid timetoken" );
		dateMessage = date;
	}
}

- (void)kPNClientMessageSendingDidFailNotification:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification kPNClientMessageSendingDidFailNotification: ");
	pNClientMessageSendingDidFailNotification = YES;
}


- (void)handleClientDidReceiveMessage:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientDidReceiveMessage: %@", notification);
	handleClientDidReceiveMessage = YES;

	PNMessage *message = (PNMessage*)notification.userInfo;

	BOOL isWrite = [message writeToFileAtPath: @"/invalidPath/"];
	STAssertFalse( isWrite, @"invalid result");
	isWrite = [message writeToFileAtPath: @"/invalidPath/file.txt"];
	STAssertFalse( isWrite, @"invalid result");

	NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSString *filePath = [documentsFolder stringByAppendingPathComponent:@"message.txt"];
	isWrite = [message writeToFileAtPath: filePath];
	STAssertTrue( isWrite, @"invalid result");

	PNMessage *loadedMessage = [PNMessage messageFromFileAtPath: @"/invalidPath/file.txt"];
	STAssertNil( loadedMessage, @"strange message");

	loadedMessage = [PNMessage messageFromFileAtPath: filePath];
	STAssertNotNil( loadedMessage, @"invalid message");
	STAssertTrue( [loadedMessage.message isEqual: message.message], @"");
	STAssertTrue( [loadedMessage.channel.name isEqualToString: message.channel.name], @"");
	NSLog(@"dates\n%@\n\n%@", loadedMessage.receiveDate, message.receiveDate);
	STAssertTrue( [loadedMessage.receiveDate.date isEqual: message.receiveDate.date], @"");
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

- (void)tearDown {
    [super tearDown];

    [[PNObservationCenter defaultCenter] removeClientConnectionStateObserver: self];
	[NSThread sleepForTimeInterval:0.1];
}

#pragma mark - PubNub client delegate methods


#pragma mark - States tests

- (void)t05AddClientConnectionStateObserver {
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

- (void)t06ClientChannelSubscriptionStateObserver {
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

//- (void)test07addPresenceEventObserver
//{
//    __pn_desired_weak __typeof__(self) weakSelf = self;
//    [[PNObservationCenter defaultCenter] addPresenceEventObserver:weakSelf
//                                                        withBlock:^(PNPresenceEvent *presenceEvent) {
//
//                                                            PNLog(PNLogGeneralLevel, weakSelf, @"{BLOCK-P} PubNubc client received new event: %@",
//																  presenceEvent);
//                                                        }];
//}
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


- (void)t10ConnectNormal {
	[PubNub disconnect];
	//    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
	//	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: @"key"];
	////	//	configuration.autoReconnectClient = NO;
	//	[PubNub setConfiguration: configuration];
	// Tuller key's
	//	static NSString * const kPNPublishKey = @"pub-c-bb4a4d9b-21b1-40e8-a30b-04a22f5ef154";
	//	static NSString * const kPNSubscriptionKey = @"sub-c-6b43405c-3694-11e3-a5ee-02ee2ddab7fe";
	//	static NSString * const kPNSecretKey = @"sec-c-ZmNlNzczNTEtOGUwNS00MmRjLWFkMjQtMjJiOTA2MjY2YjI5";

	handleClientConnectionStateChange = NO;
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: @"key"];
		configuration = [PNConfiguration defaultConfiguration];
		[PubNub setConfiguration: configuration];

		handleClientConnectionStateChange = NO;
		[PubNub connectWithSuccessBlock:^(NSString *origin) {

			PNLog(PNLogGeneralLevel, nil, @"\n\n\n\n\n\n\n{BLOCK} PubNub client connected to: %@", origin);
			dispatch_semaphore_signal(semaphore);
		}
							 errorBlock:^(PNError *connectionError) {
								 PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
								 dispatch_semaphore_signal(semaphore);
								 STFail(@"connectionError %@", connectionError);
							 }];
	});
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];

	STAssertTrue( handleClientConnectionStateChange, @"notification not called");
	_reconnectCount = 0;
}

- (void)t10ConnectPresence {
	[PubNub disconnect];

	handleClientConnectionStateChange = NO;
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		//		[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];
		PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"pub-c-c9b0fe21-4ae1-433b-b766-62667cee65ef" subscribeKey:@"sub-c-d91ee366-9dbd-11e3-a759-02ee2ddab7fe" secretKey: @"sec-c-ZDUxZGEyNmItZjY4Ny00MjJmLWE0MjQtZTQyMDM0NTY2MDVk" cipherKey: nil authorizationKey: @"authorizationKey"];
		[PubNub setConfiguration: configuration];

		handleClientConnectionStateChange = NO;
		[PubNub connectWithSuccessBlock:^(NSString *origin) {

			PNLog(PNLogGeneralLevel, nil, @"\n\n\n\n\n\n\n{BLOCK} PubNub client connected to: %@", origin);
			dispatch_semaphore_signal(semaphore);
		}
							 errorBlock:^(PNError *connectionError) {
								 PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
								 dispatch_semaphore_signal(semaphore);
								 STFail(@"connectionError %@", connectionError);
							 }];
	});
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];

	STAssertTrue( handleClientConnectionStateChange, @"notification not called");

	_reconnectCount = 0;
}

- (void)t20SubscribeOnChannels {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	handleClientSubscriptionProcess = NO;
	[PubNub subscribeOnChannels: pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 dispatch_semaphore_signal(semaphore);
		 STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
		 STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
	 }];
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	STAssertTrue( handleClientSubscriptionProcess, @"notification not caleld");
}

-(void)revertPresenceObservationForChannel:(PNChannel*)channel {
	__block NSDate *start = [NSDate date];
	__block BOOL isCompletionBlockCalled = NO;
	BOOL state = [PubNub isPresenceObservationEnabledForChannel: channel];
	NSLog(@"[PubNub isPresenceObservationEnabledForChannel: channel] %d", state);
	if( state == NO ) {
		pNClientPresenceEnablingDidCompleteNotification = NO;
		NSLog(@"start enablePresenceObservationForChannel");
		[PubNub enablePresenceObservationForChannel: channel
						withCompletionHandlingBlock:^(NSArray *array, PNError *error) {
			 NSTimeInterval interval = -[start timeIntervalSinceNow];
			 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+2, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
			 STAssertNil( error, @"enablePresenceObservationForChannel error %@", error);
			 isCompletionBlockCalled = YES;
			NSLog(@"enablePresenceObservationForChannel completionBlock");
		 }];
		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+2 &&
			isCompletionBlockCalled == NO; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		STAssertTrue( pNClientPresenceEnablingDidCompleteNotification==YES, @"notification not called");
		NSLog(@"enablePresenceObservationForChannel end");
	}
	else {
		pNClientPresenceDisablingDidCompleteNotification = NO;
		NSLog(@"start disablePresenceObservationForChannel");
		[PubNub disablePresenceObservationForChannel: channel
						 withCompletionHandlingBlock:^(NSArray *array, PNError *error) {
			 NSTimeInterval interval = -[start timeIntervalSinceNow];
			 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+2, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
			 STAssertNil( error, @"disablePresenceObservationForChannel error %@", error);
			 isCompletionBlockCalled = YES;
			NSLog(@"disablePresenceObservationForChannel completionBlock");
		 }];
		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
			isCompletionBlockCalled == NO; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		STAssertTrue( pNClientPresenceDisablingDidCompleteNotification==YES, @"notification not called");
		NSLog(@"disablePresenceObservationForChannel end");
	}
	BOOL newState = [PubNub isPresenceObservationEnabledForChannel: channel];
	NSLog(@"[PubNub isPresenceObservationEnabledForChannel: channel] newState %d", newState);
	STAssertTrue( state != newState, @"state not changed");
	STAssertTrue(isCompletionBlockCalled, @"block not called");
}

-(void)t25RequestParticipantsListForChannelRevert {
	for( int i=0; i<pnChannels.count; i++ ) {
		[self revertPresenceObservationForChannel: pnChannels[i]];
		[self revertPresenceObservationForChannel: pnChannels[i]];
	}
}


-(void)t30RequestParticipantsListForChannel {
	for( int i=0; i<pnChannels.count; i++ ) {
		handleClientHereNowProcess = NO;
		__block BOOL isCompletionBlockCalled = NO;
		[PubNub requestParticipantsListForChannel:pnChannels[i] withCompletionBlock:^(NSArray *udids, PNChannel *channel, PNError *error) {
			isCompletionBlockCalled = YES;
			 if( error != nil )
				 PNLog(PNLogGeneralLevel, nil, @"error %@", error);
			 STAssertNil( error, @"error %@", error);
			 NSLog(@"udids %@", udids);
		 }];
		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 && isCompletionBlockCalled == NO; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		STAssertTrue(handleClientHereNowProcess, @"notification not called");
		STAssertTrue(isCompletionBlockCalled, @"block not called");
	}
}

-(void)t35RequestServerTimeTokenWithCompletionBlock {
	handleClientCompletedTimeTokenProcessing = NO;
	__block BOOL isCompletionBlockCalled = NO;
	[PubNub requestServerTimeTokenWithCompletionBlock:^(NSNumber *timeToken, PNError *error) {
		isCompletionBlockCalled = YES;
		STAssertNil( error, @"error %@", error);
	 }];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 && isCompletionBlockCalled == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue(handleClientCompletedTimeTokenProcessing, @"notification not called");
	STAssertTrue(isCompletionBlockCalled, @"block not called");
}

-(void)t40SendMessage {
	for( int j=0; j<5; j++ ) {
		for( int i=0; i<pnChannels.count; i++ )	{
			pNClientDidSendMessageNotification = NO;
			dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
			__block PNMessageState state = PNMessageSendingError;
			NSString *message = [NSString stringWithFormat: @"Hello PubNub %d", j];
			message = [message stringByAppendingString: @" sdfфвып !№%,,%;%,.(№.(@#$^@$%&%(^)@"];
			[PubNub sendMessage: message toChannel:pnChannels[i]
			withCompletionBlock:^(PNMessageState messageSendingState, id data) {
				 if( messageSendingState != PNMessageSending )
					 dispatch_semaphore_signal(semaphore);
				 state = messageSendingState;
				 STAssertFalse(messageSendingState==PNMessageSendingError, @"messageSendingState==PNMessageSendingError %@", data);
			 }];


			for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
				(state != PNMessageSent || pNClientDidSendMessageNotification == NO); j++ )
				[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
									 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
			STAssertTrue(pNClientDidSendMessageNotification || state != PNMessageSent, @"notificaition not called");

//			[PubNub sendMessage: [NSNumber numberWithInt: i] toChannel:pnChannels[i]
//			withCompletionBlock:^(PNMessageState messageSendingState, id data) {
//				state = messageSendingState;
//				STAssertFalse(messageSendingState==PNMessageSendingError, @"messageSendingState==PNMessageSendingError %@", data);
//			}];
//
//			for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
//				(state != PNMessageSent || pNClientDidSendMessageNotification == NO); j++ )
//				[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
//			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//									 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
//			STAssertTrue(pNClientDidSendMessageNotification || state != PNMessageSent, @"notificaition not called");
//
//			[PubNub sendMessage: [NSNumber numberWithInt: i] toChannel:pnChannels[i]
//			withCompletionBlock:^(PNMessageState messageSendingState, id data) {
//				state = messageSendingState;
//				STAssertFalse(messageSendingState==PNMessageSendingError, @"messageSendingState==PNMessageSendingError %@", data);
//			}];
//
//			for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
//				(state != PNMessageSent || pNClientDidSendMessageNotification == NO); j++ )
//				[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
//			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//									 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
//			STAssertTrue(pNClientDidSendMessageNotification || state != PNMessageSent, @"notificaition not called");
		}
	}
}

-(void)t45SendMessageBig {
	NSMutableString *message = [NSMutableString stringWithString: @""];
	for( int j=0; j<6; j++ ) {
		for( int i=0; i<pnChannels.count; i++ )	{
			pNClientDidSendMessageNotification = NO;
			pNClientMessageSendingDidFailNotification = NO;
			__block PNMessageState state = PNMessageSendingError;
			[message appendFormat: @"message block ______________________ _______________________ ____________________________ _____________________________ ___________________ _______________________________ ____________________________________ ______________________ _________________ ________________________________ ___________________ %d_%d, ", i, j];
			NSLog(@"send message %d_%d with size %lu", i, j, (unsigned long)message.length);
			state = PNMessageSending;
			__block NSDate *start = [NSDate date];
			[PubNub sendMessage: message toChannel:pnChannels[i] withCompletionBlock:^(PNMessageState messageSendingState, id data) {
				 state = messageSendingState;
				 if( state == PNMessageSending )
					 return;
				 NSTimeInterval interval = -[start timeIntervalSinceNow];
				 //				 NSLog( @"test45SendMessageBig %f", interval);
				 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

				 NSLog(@"withCompletionBlock %d, message size %lu", (int)messageSendingState, (unsigned long)message.length);
			 }];

			for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 && state == PNMessageSending /*|| pNClientDidSendMessageNotification == NO || pNClientMessageSendingDidFailNotification == NO)*/; j++ )
				[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

			if( message.length < 1300 )
				STAssertTrue( pNClientDidSendMessageNotification == YES && state == PNMessageSent, @"message not sent, size %d", message.length);
			if( message.length >= 1600 ) {
				NSLog(@"sended message %d_%d with size %lu", i, j, (unsigned long)message.length);

				STAssertTrue( pNClientMessageSendingDidFailNotification == YES && state == PNMessageSendingError, @"message's methods not called, size %d", message.length);
			}
		}
	}
}

-(NSArray*)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessageHistory includingTimeToken:(BOOL)shouldIncludeTimeToken {
	//	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	__block NSArray *history;
	handleClientMessageHistoryProcess = NO;
	__block BOOL isCompletionBlockCalled = NO;
	NSDate *start = [NSDate date];
	NSLog(@"requestHistoryForChannel start %@, end %@", startDate, endDate);
	PNMessageHistoryRequest *request = [PNMessageHistoryRequest messageHistoryRequestForChannel:channel
																						   from:startDate
																							 to:endDate
																						  limit:limit
																				 reverseHistory: shouldReverseMessageHistory includingTimeToken: shouldIncludeTimeToken];
	PNWriteBuffer *buffer = [request buffer];
	NSString *string = [NSString stringWithUTF8String: (char*)buffer.buffer];
	NSLog(@"buffer:\n%@", string);
	STAssertTrue( [string rangeOfString: [PubNub sharedInstance].configuration.subscriptionKey].location != NSNotFound, @"subscriptionKey not found");

	[PubNub requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:NO includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:^(NSArray *messages, PNChannel *ch, PNDate *fromDate, PNDate *toDate, PNError *error) {
		isCompletionBlockCalled = YES;
		history = messages;

		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"requestHistoryForChannel interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

		if( startDate == nil || endDate == nil || endDate.timeToken.intValue > startDate.timeToken.intValue ) {
			if( error != nil )
				NSLog(@"requestHistoryForChannel error %@, start %@, end %@", error, startDate, endDate);
			STAssertNil( error, @"requestHistoryForChannel error %@", error);
		}
	}];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 && isCompletionBlockCalled == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	STAssertTrue( handleClientMessageHistoryProcess, @"notification not called");
	if( shouldIncludeTimeToken == NO )
		for( int i=0; i<history.count; i++ ) {
			PNMessage *message = history[i];
			if( shouldIncludeTimeToken == NO )
				STAssertNil( message.receiveDate, @"");
		}
	else {
		float time = 0;
		for( int i=0; i<history.count; i++ ) {
			PNMessage *message = history[i];
			STAssertNotNil( message.receiveDate, @"");
			PNDate *date = message.receiveDate;
			if( i<0 )
				STAssertTrue( time < [date.date timeIntervalSinceNow], @"");
			time = [date.date timeIntervalSinceNow];
		}
	}
	return history;
}

-(NSArray*)requestFullHistoryForChannel:(PNChannel *)channel includingTimeToken:(BOOL)shouldIncludeTimeToken {
	handleClientMessageHistoryProcess = NO;
	__block BOOL isCompletionBlockCalled = NO;
	NSDate *start = [NSDate date];
	__block NSArray *history;
	[PubNub requestFullHistoryForChannel:channel includingTimeToken:(BOOL)shouldIncludeTimeToken withCompletionBlock:^(NSArray *messages, PNChannel *ch, PNDate *fromDate, PNDate *toDate, PNError *error) {
		isCompletionBlockCalled = YES;
		history = messages;

		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"requestHistoryForChannel interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		isCompletionBlockCalled == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	STAssertTrue( handleClientMessageHistoryProcess, @"notification not called");
	if( shouldIncludeTimeToken == NO )
		for( int i=0; i<history.count; i++ ) {
			PNMessage *message = history[i];
			if( shouldIncludeTimeToken == NO )
				STAssertNil( message.receiveDate, @"");
		}
	else {
		float time = 0;
		for( int i=0; i<history.count; i++ ) {
			PNMessage *message = history[i];
			STAssertNotNil( message.receiveDate, @"");
			PNDate *date = message.receiveDate;
			NSLog(@"[date.date timeIntervalSinceNow] %f", [date.date timeIntervalSinceNow]);
			if( i<0 )
				STAssertTrue( time < [date.date timeIntervalSinceNow], @"");
			time = [date.date timeIntervalSinceNow];
		}
	}
	return history;
}

-(void)requestFullHistoryForChannel:(PNChannel *)channel {
	handleClientMessageHistoryProcess = NO;
	__block BOOL isCompletionBlockCalled = NO;
	NSDate *start = [NSDate date];

	[PubNub requestFullHistoryForChannel:channel withCompletionBlock:^(NSArray *messages, PNChannel *ch, PNDate *fromDate, PNDate *toDate, PNError *error) {
		isCompletionBlockCalled = YES;
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"requestHistoryForChannel interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		isCompletionBlockCalled == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	STAssertTrue( handleClientMessageHistoryProcess, @"notification not called");
}

-(void)t50RequestHistoryForChannel {
	[self requestHistoryForChannel: nil from: nil to: nil limit: 0 reverseHistory: NO includingTimeToken: YES];
	for( int i=0; i<pnChannels.count; i++ ) {
		PNDate *startDate = [PNDate dateWithDate:[NSDate dateWithTimeIntervalSinceNow:(-3600.0f)]];
		PNDate *endDate = [PNDate dateWithDate:[NSDate date]];
		int limit = 34;
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: limit reverseHistory: YES includingTimeToken: NO];
		[self requestHistoryForChannel: pnChannels[i] from: endDate to: startDate limit: limit reverseHistory: YES includingTimeToken: YES];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: startDate limit: limit reverseHistory: YES includingTimeToken: NO];
		[self requestHistoryForChannel: pnChannels[i] from: endDate to: endDate limit: limit reverseHistory: NO includingTimeToken: YES];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: limit reverseHistory: NO includingTimeToken: NO];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: 0 reverseHistory: NO includingTimeToken: YES];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: nil limit: 0 reverseHistory: NO includingTimeToken: NO];
		[self requestFullHistoryForChannel: pnChannels[i]];
		[self requestFullHistoryForChannel: pnChannels[i] includingTimeToken: YES];
		[self requestFullHistoryForChannel: pnChannels[i] includingTimeToken: NO];
	}
}

-(void)t55RequestHistoryReverse {
	__block NSNumber *timeMiddle = nil;
	__block NSString *messageMiddle = @"";
	for( int j=0; j<5; j++ ) {
		for( int i=0; i<pnChannelsForReverse.count; i++ ) {
			pNClientDidSendMessageNotification = NO;
			dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
			__block PNMessageState state = PNMessageSendingError;
			__block NSString *text = [NSString stringWithFormat: @"Hello PubNub %d", j];
			[PubNub sendMessage: text toChannel:pnChannelsForReverse[i] withCompletionBlock:^(PNMessageState messageSendingState, id data) {
			   if( messageSendingState != PNMessageSending )
				   dispatch_semaphore_signal(semaphore);
			   state = messageSendingState;
			   STAssertFalse(messageSendingState==PNMessageSendingError, @"messageSendingState==PNMessageSendingError %@", data);

			   if( j==2 && state == PNMessageSent ) {
				   dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
				   handleClientCompletedTimeTokenProcessing = NO;
				   [PubNub requestServerTimeTokenWithCompletionBlock:^(NSNumber *timeToken, PNError *error)
					{
						dispatch_semaphore_signal(semaphore);
						timeMiddle = timeToken;
						messageMiddle = text;
					}];
				   while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
					   [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
												beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
			   }
		   }];

			for( int j=0; j<4 && j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
				(state != PNMessageSent || pNClientDidSendMessageNotification == NO); j++ )
				[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
			STAssertTrue(pNClientDidSendMessageNotification || state != PNMessageSent, @"notificaition not called");
		}
	}

		for( int i=0; i<pnChannelsForReverse.count; i++ ) {
			//		PNDate *startDate = [PNDate dateWithDate:[NSDate dateWithTimeIntervalSinceNow:(-3600.0f)]];
			//		PNDate *endDate = [PNDate dateWithDate:[NSDate date]];
			NSArray *messages = [self requestHistoryForChannel: pnChannelsForReverse[i] from: nil to: nil limit: 0 reverseHistory: NO includingTimeToken: NO];
			STAssertTrue( messages.count > 0, @"empty history");
			NSArray *messagesReverse = [self requestHistoryForChannel: pnChannelsForReverse[i] from: [PNDate dateWithToken: timeMiddle] to: nil limit: NO reverseHistory: YES includingTimeToken: YES];
//			STAssertTrue( messages == nil, @"");
			for( int j=0; j<messagesReverse.count-1 && messages != nil; j++ ) {
				PNMessage *messageReverse = messagesReverse[j];
				STAssertTrue( [(NSString*)(messageReverse.message) compare: messageMiddle] != NSOrderedDescending, @"invalid message order, %@ %@", messageReverse.message, messageMiddle);

				PNMessage *messageReverse1 = messagesReverse[j+1];
				STAssertTrue( [messageReverse.message compare: messageReverse1.message] == NSOrderedAscending, @"invalid message order, %@ %@\n %@ %@", messageReverse, messageReverse1, messageReverse.receiveDate, messageReverse1.receiveDate);
			}
		}
}


- (void)t60SubscribeOnChannelsByTurns {
	for( int i = 0; i<20; i++ )	{
		//		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		__block BOOL isCompletionBlockCalled = NO;
		NSString *channelName = [NSString stringWithFormat: @" sdf sdfsdf asd fa adsf as %@ %d", [NSDate date], i];
		NSArray *arr = [PNChannel channelsWithNames: @[channelName]];
		NSDate *start = [NSDate date];
		NSLog(@"Start subscribe to channel %@", channelName);
		[PubNub subscribeOnChannels: arr withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
			isCompletionBlockCalled = YES;
			NSTimeInterval interval = -[start timeIntervalSinceNow];
			NSLog(@"subscribed %f, %@", interval, channels);
			STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %d instead of %d", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

			STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
			BOOL isSubscribed = NO;
			for( int j=0; j<channels.count; j++ ) {
				if( [[channels[j] name] isEqualToString: channelName] == YES ) {
					isSubscribed = YES;
					break;
				}
			}
			 STAssertTrue( isSubscribed == YES, @"Channel no subecribed");
		 }];
		// Run loop
		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
			isCompletionBlockCalled == NO; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		STAssertTrue( isCompletionBlockCalled, @"completion block not called, %@", channelName);
		if( isCompletionBlockCalled == NO )
			return;
	}
}


-(void)t900UnsubscribeFromChannels
{
	handleClientUnsubscriptionProcess = YES;
	//	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	__block BOOL isCompletionBlockCalled = NO;
	// Unsubscribe from set of channels and notify everyone that we are left
	NSDate *start = [NSDate date];
	[PubNub unsubscribeFromChannels: pnChannels withCompletionHandlingBlock: ^(NSArray *channels, PNError *unsubscribeError) {
		 NSTimeInterval interval = -[start timeIntervalSinceNow];
		 NSLog(@"unsubscribeFromChannels %f, %@", interval, channels);
		 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

		 isCompletionBlockCalled = YES;
		 STAssertNil( unsubscribeError, @"unsubscribeError %@", unsubscribeError);
		 STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
	 }];
    // Run loop
	//    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
	//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
	//                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		isCompletionBlockCalled == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue(handleClientUnsubscriptionProcess, @"notification not called");
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");

	//	[self t950ReconnectCount];
}

- (void)t910removeClientChannelSubscriptionStateObserver {
    [[PNObservationCenter defaultCenter] removeClientChannelSubscriptionStateObserver: self];
}

-(void)didSendRequest:(NSNotification*)notification {
	NSLog(@"didSendRequest %@", notification.object);
	PNBaseRequest *request = notification.object;
	PNWriteBuffer *buffer = [request buffer];
	NSString *string = [NSString stringWithUTF8String: (char*)buffer.buffer];
	if( string == nil )
		string = [buffer description];
	STAssertTrue( string != nil, @"");
	NSLog(@"buffer:\n%@", string);
    NSString *authorizationKey = [PubNub sharedInstance].configuration.authorizationKey;
    if ([authorizationKey length] > 0)
        authorizationKey = [NSString stringWithFormat:@"auth=%@", authorizationKey];
	if( authorizationKey.length > 0 )
		STAssertTrue( [string rangeOfString: authorizationKey].location != NSNotFound, @"");
}

//-(void)test910UnsubscribeFromChannelsBad
//{
//	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//	// Unsubscribe from set of channels and notify everyone that we are left
//	[PubNub unsubscribeFromChannels: pnChannelsBad
//				  withPresenceEvent:YES
//		 andCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError)
//	 {
//		 // Check whether "unsubscribeError" is nil or not (if not, than handle error)
//		 dispatch_semaphore_signal(semaphore);
//		 STAssertNotNil( unsubscribeError, @"unsubscribeError %@", unsubscribeError);
//	 }];
//    // Run loop
//    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
//}
//-(void)t950ReconnectCount {
//	[Swizzler unswizzleFromReceipt:receiptReconnect];
//
//	STAssertTrue(_reconnectCount == 0, @"excess reconnect");
//}

-(SwizzleReceipt*)setReconnect {
	return [Swizzler swizzleSelector:@selector(reconnect)
				 forInstancesOfClass:[PNConnection class]
						   withBlock:
			^(id object, SEL sel){
				PNLog(PNLogGeneralLevel, nil, @"PNConnection setReconnect");
				_reconnectCount++;
				_reconnectNumber = [NSNumber numberWithInt: [_reconnectNumber intValue]+1];
				[Swizzler unswizzleFromReceipt:receiptReconnect];
				[(PNConnection*)object reconnect];
				receiptReconnect = [self setReconnect];
			}];
}

@end
