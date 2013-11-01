//
//  BadJsonTest.m
//  pubnub
//
//  Created by Valentin Tuller on 10/2/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "BadJsonTest.h"
#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNConnection.h"
#import "PNHereNowResponseParser.h"
#import "PNNotifications.h"
#import "Swizzler.h"

@interface BadJsonTest () <PNDelegate>
{
	NSArray *pnChannels;
	NSArray *pnChannels1;
	dispatch_semaphore_t semaphoreNotification;
	NSData *badJsonData;
	int messageSendingDidFailCount;
	int messageDidSendCount;

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
}

@end

@implementation BadJsonTest

- (void)setUp
{
    [super setUp];
	semaphoreNotification = dispatch_semaphore_create(0);
    [PubNub setDelegate:self];
	pnChannels = [PNChannel channelsWithNames:@[@"iosdev", @"andoirddev", @"wpdev", @"ubuntudev", @"1"]];
	pnChannels1 = [PNChannel channelsWithNames:@[@"iosdev1", @"andoirddev1", @"wpdev1", @"ubuntudev1"]];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientDidSendMessage:)
							   name:kPNClientDidSendMessageNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientMessageSendingDidFailChange:)
							   name:kPNClientMessageSendingDidFailNotification
							 object:nil];
}

- (void)handleClientDidSendMessage:(NSNotification *)notification {
	PNLog(PNLogGeneralLevel, nil, @"kPNClientDidSendMessageNotification handleClientDidSendMessage %@", notification);
	messageDidSendCount++;
}

- (void)handleClientMessageSendingDidFailChange:(NSNotification *)notification {
	PNLog(PNLogGeneralLevel, nil, @"kPNClientMessageSendingDidFailNotification handleClientMessageSendingDidFailChange %@", notification);
	messageSendingDidFailCount++;
}

-(void)resetConnection {
	[PubNub resetClient];
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];

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
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
	BOOL isConnected = [[PubNub sharedInstance] isConnected];
	STAssertTrue( isConnected, @"connect fail");
}


- (void)test10Connect
{
	[PubNub resetClient];
	NSLog(@"end reset");
	for( int j=0; j<5; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

	NSLog(@"start connect");
	[PubNub setDelegate:self];
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

	//    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: @"key"];
	//	//	configuration.autoReconnectClient = NO;
	configuration.subscriptionRequestTimeout = 10;
	configuration.nonSubscriptionRequestTimeout = 10;
	[PubNub setConfiguration: configuration];

	handleClientConnectionStateChange = NO;
    [PubNub connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, nil, @"{BLOCK} PubNub client connected to: %@", origin);
        dispatch_semaphore_signal(semaphore);
    }
                         errorBlock:^(PNError *connectionError) {
							 PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
							 dispatch_semaphore_signal(semaphore);
							 STFail(@"connectionError %@", connectionError);
                         }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
//	STAssertTrue( handleClientConnectionStateChange, @"notification not called");
}

//file://localhost/Users/tuller/work/pubnub/iOS/3.4/pubnubTests/RequestTests/PNBaseRequestTest.m: error: test20SubscribeOnChannels (PNBaseRequestTest) failed: "((subscriptionError) == nil)" should be true. subscriptionError Domain=com.pubnub.pubnub; Code=106; Description="Subscription failed by timeout"; Reason="Looks like there is some packets lost because of which request failed by timeout"; Fix suggestion="Try send request again later."; Associated object=(

- (void)test15SubscribeOnChannels
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	handleClientSubscriptionProcess = NO;
	[PubNub subscribeOnChannels: pnChannels1
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 dispatch_semaphore_signal(semaphore);
		 STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
	 }];
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

-(void)test18SendMessage
{
	messageDidSendCount = 0;
	SwizzleReceipt *receipt = nil;
	SwizzleReceipt *receiptError = nil;
	for( int i=0; i<pnChannels1.count; i++ )
	{
		if( i==0 ) {
			receipt = [self closeSocket];
			receiptError = [self createError];
		}

		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		__block PNMessageState state = PNMessageSendingError;
		/*PNMessage *helloMessage = */[PubNub sendMessage:@"Hello PubNub"
												toChannel:pnChannels1[i]
									  withCompletionBlock:^(PNMessageState messageSendingState, id data)
									   {
										   dispatch_semaphore_signal(semaphore);
										   state = messageSendingState;
										   PNLog(PNLogGeneralLevel, nil, @"sendMessage state %d", messageSendingState);
//										   STAssertFalse(messageSendingState==PNMessageSendingError, @"messageSendingState can't be equal PNMessageSent, %@", data);
									   }];

		while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
									 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
		if( i==0 ) {
			[Swizzler unswizzleFromReceipt:receiptError];
			[Swizzler unswizzleFromReceipt:receipt];
		}
		//		STAssertTrue(handleClientMessageProcessingStateChange, @"notification not called");
		//		STAssertTrue(handleClientDidReceiveMessage || state != PNMessageSent, @"notificaition not called");
	}
	STAssertTrue(messageDidSendCount == pnChannels1.count-1, @"messageDidSendCount (%d) must be = pnChannels1.count (%d)", messageDidSendCount, pnChannels1.count);
}
//file://localhost/Users/tuller/work/pubnub%203.5.1b/iOS/iPadDemoApp/pubnubTests/BadJsonTest/BadJsonTest.m: error: test18SendMessage (BadJsonTest) failed: "messageDidSendCount == pnChannels1.count" should be true. messageDidSendCount (0) must be = pnChannels1.count (4)

-(void)resetConenction {
	[PubNub resetClient];
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];

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
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)test20SubscribeOnChannels
{
	[self resetConenction];
	SwizzleReceipt *receipt = [self setNewDataForBuffer];

//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	handleClientSubscriptionProcess = NO;
	__block BOOL isCompletionBlockCalled = NO;
	[PubNub subscribeOnChannels: pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
//		 dispatch_semaphore_signal(semaphore);
		 isCompletionBlockCalled = YES;
		 NSLog(@"test20SubscribeOnChannels %@, %@", (subscriptionError!=nil) ? @"" : channels, subscriptionError);
		 STAssertNotNil( subscriptionError, @"subscriptionError %@", subscriptionError);
	 }];
    // Run loop
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		isCompletionBlockCalled == NO /*&& notificationParticipantsListCalled == NO*/; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

	STAssertTrue(isCompletionBlockCalled, @"Completion block not called");
	[Swizzler unswizzleFromReceipt:receipt];
//	STAssertTrue( handleClientSubscriptionProcess, @"notification not caleld");
}

-(void)test40SendMessage
{
	messageSendingDidFailCount = 0;
	for( int i=0; i<pnChannels.count; i++ )
	{
		SwizzleReceipt *receipt = [self setNewDataForBuffer];

		//		handleClientMessageProcessingStateChange = NO;
		//		handleClientDidReceiveMessage = NO;
//		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		__block BOOL isCompletionBlockCalled = NO;
		__block PNMessageState state = PNMessageSendingError;
		/*PNMessage *helloMessage = */[PubNub sendMessage:@"Hello PubNub"
												toChannel:pnChannels[i]
									  withCompletionBlock:^(PNMessageState messageSendingState, id data)
									   {
										   isCompletionBlockCalled = YES;
//										   dispatch_semaphore_signal(semaphore);
										   state = messageSendingState;
										   NSLog(@"sendMessage state %@ %@ %@",
												 (messageSendingState==PNMessageSending) ? @"PNMessageSending" : @"",
												(messageSendingState==PNMessageSent) ? @"PNMessageSent" : @"",
												(messageSendingState==PNMessageSendingError) ? @"PNMessageSendingError" : @"");
										   STAssertFalse(messageSendingState==PNMessageSent, @"messageSendingState can't be equal PNMessageSent, %@", data);
									   }];

		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
			isCompletionBlockCalled == NO /*&& notificationParticipantsListCalled == NO*/; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		[Swizzler unswizzleFromReceipt: receipt];
		STAssertTrue(isCompletionBlockCalled, @"completion block not called");
		//		STAssertTrue(handleClientDidReceiveMessage || state != PNMessageSent, @"notificaition not called");
	}
//	STAssertTrue(messageSendingDidFailCount >= pnChannels.count, @"messageSendingDidFailCount (%d) must be >= pnChannels.count (%d)", messageSendingDidFailCount, pnChannels.count);
}

- (void)test50SubscribeOnChannels1 {
	[self resetConenction];
	SwizzleReceipt *receipt = [self setNewDataForBuffer1];

	//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	handleClientSubscriptionProcess = NO;
	__block BOOL isCompletionBlockCalled = NO;
	[PubNub subscribeOnChannels: pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 //		 dispatch_semaphore_signal(semaphore);
		 isCompletionBlockCalled = YES;
		 NSLog(@"test50SubscribeOnChannels1 %@, %@", (subscriptionError!=nil) ? @"" : channels, subscriptionError);
		 STAssertNotNil( subscriptionError, @"subscriptionError %@", subscriptionError);
	 }];
    // Run loop
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		isCompletionBlockCalled == NO /*&& notificationParticipantsListCalled == NO*/; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

	STAssertTrue(isCompletionBlockCalled, @"Completion block not called");
	[Swizzler unswizzleFromReceipt: receipt];
	//	STAssertTrue( handleClientSubscriptionProcess, @"notification not caleld");
}

-(void)test60SendMessage1
{
	messageSendingDidFailCount = 0;
	for( int i=0; i<pnChannels.count; i++ )
	{
		SwizzleReceipt *receipt = [self setNewDataForBuffer1];

		//		handleClientMessageProcessingStateChange = NO;
		//		handleClientDidReceiveMessage = NO;
		//		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		__block BOOL isCompletionBlockCalled = NO;
		__block PNMessageState state = PNMessageSendingError;
		/*PNMessage *helloMessage = */[PubNub sendMessage:@"Hello PubNub"
												toChannel:pnChannels[i]
									  withCompletionBlock:^(PNMessageState messageSendingState, id data)
									   {
										   isCompletionBlockCalled = YES;
										   //										   dispatch_semaphore_signal(semaphore);
										   state = messageSendingState;
										   NSLog(@"sendMessage state %@%@%@",
												 (messageSendingState==PNMessageSending) ? @"PNMessageSending" : @"",
												 (messageSendingState==PNMessageSent) ? @"PNMessageSent" : @"",
												 (messageSendingState==PNMessageSendingError) ? @"PNMessageSendingError" : @"");
										   STAssertFalse(messageSendingState==PNMessageSent, @"messageSendingState can't be equal PNMessageSent, %@", data);
									   }];

		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
			isCompletionBlockCalled == NO /*&& notificationParticipantsListCalled == NO*/; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		[Swizzler unswizzleFromReceipt: receipt];
		STAssertTrue(isCompletionBlockCalled, @"completion block not called");
		//		STAssertTrue(handleClientDidReceiveMessage || state != PNMessageSent, @"notificaition not called");
	}
	//	STAssertTrue(messageSendingDidFailCount >= pnChannels.count, @"messageSendingDidFailCount (%d) must be >= pnChannels.count (%d)", messageSendingDidFailCount, pnChannels.count);
}
///////////////////////////////////////////////////////

-(SwizzleReceipt*)setNewDataForBuffer {
	return [Swizzler swizzleSelector:@selector(isNeedUpdateBuffer)
				 forInstancesOfClass:[PNConnection class]
						   withBlock:
			^(id self, SEL sel){
				PNLog(PNLogGeneralLevel, nil, @"PNConnection isNeedUpdateBuffer");
				return YES;
			}];
}

-(SwizzleReceipt*)setNewDataForBuffer1 {
	return [Swizzler swizzleSelector:@selector(isNeedUpdateBuffer1)
				 forInstancesOfClass:[PNConnection class]
						   withBlock:
			^(id self, SEL sel){
				PNLog(PNLogGeneralLevel, nil, @"PNConnection isNeedUpdateBuffer1");
				return YES;
			}];
}

-(SwizzleReceipt*)closeSocket {
	return [Swizzler swizzleSelector:@selector(isNeedCloseSocket)
				 forInstancesOfClass:[PNConnection class]
						   withBlock:
			^(id self, SEL sel){
				PNLog(PNLogGeneralLevel, nil, @"PNConnection isNeedCloseSocket");
				return YES;
			}];
}

-(SwizzleReceipt*)createError {
	return [Swizzler swizzleSelector:@selector(isNeedCreateError)
				 forInstancesOfClass:[PNConnection class]
						   withBlock:
			^(id self, SEL sel){
				PNLog(PNLogGeneralLevel, nil, @"PNConnection isNeedCreateError");
				return YES;
			}];
}

@end
