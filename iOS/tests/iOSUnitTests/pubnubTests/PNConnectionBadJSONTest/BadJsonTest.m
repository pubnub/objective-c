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

- (void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
	[super tearDown];
}

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

- (void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
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

-(NSArray*)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessageHistory isExpectationError:(BOOL)isExpectationError
{
	__block NSArray *history;
	__block BOOL isCompletionBlockCalled = NO;
	NSDate *start = [NSDate date];
	NSLog(@"requestHistoryForChannel start %@, end %@", startDate, endDate);
	[PubNub requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:NO
				 withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *fromDate, PNDate *toDate, PNError *error)
	 {
		 isCompletionBlockCalled = YES;
		 history = messages;

		 NSTimeInterval interval = -[start timeIntervalSinceNow];
		 NSLog(@"requestHistoryForChannel interval %f", interval);
		 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

		 if( isExpectationError == YES
//			&& (startDate == nil || endDate == nil || endDate.timeToken.intValue > startDate.timeToken.intValue)
			) {
			 if( error != nil )
				 NSLog(@"requestHistoryForChannel error %@\n, start %@\n, end %@", error, startDate, endDate);
			 STAssertNotNil( error, @"requestHistoryForChannel error %@", error);
		 }
	 }];
	for( int j=0; /*j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 && */
		isCompletionBlockCalled == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	return history;
}


- (void)test10Connect {
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
	configuration.reduceSecurityLevelOnError = YES;
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

	[self t15SubscribeOnChannels];
	[self t18SendMessage];
	[self t20SubscribeOnChannels];
	[self t40SendMessage];
	[self t45RequestHistoryForChannel];
	[self t50SubscribeOnChannels1];
	[self t60SendMessage1];
	[self t70RequestHistoryForChannel1];
}

- (void)t15SubscribeOnChannels {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	handleClientSubscriptionProcess = NO;
	__block NSDate *start = [NSDate date];
	[PubNub subscribeOnChannels: pnChannels1 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
		 dispatch_semaphore_signal(semaphore);
		 NSTimeInterval interval = -[start timeIntervalSinceNow];
		 NSLog( @"test15SubscribeOnChannels %f", interval);
		 STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
	 }];
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

-(void)t18SendMessage {
	messageDidSendCount = 0;
//	__block SwizzleReceipt *receiptCloseSocket = nil;
	__block SwizzleReceipt *receiptError = nil;
//	__block int countSendMessageNumber0 = 0;
//	receiptCloseSocket = [self closeSocket];
	receiptError = [self setNewDataForBuffer];
	[self performSelector: @selector(unswizzleFromReceipt:) withObject: receiptError afterDelay: 5];
//	[self performSelector: @selector(unswizzleFromReceipt:) withObject: receiptCloseSocket afterDelay: 5];
	for( int j=0; j<5; j++ )
		for( int i=0; i<pnChannels1.count; i++ ) {
			__block NSDate *start = [NSDate date];
			dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
			[PubNub sendMessage:[NSString stringWithFormat: @"Hello PubNub %d", i] toChannel:pnChannels1[i] withCompletionBlock:^(PNMessageState messageSendingState, id data) {
				NSLog( @"sendMessage state %d", messageSendingState);
				if( messageSendingState == PNMessageSending && i == 0 )
	//				[self unswizzleFromReceipt: receiptError];
	//				countSendMessageNumber0 ++;

	//			STAssertTrue( messageSendingState != PNMessageSendingError, @"PNMessageSendingError");
				if( messageSendingState == PNMessageSending )
					start = [NSDate date];
				if( messageSendingState != PNMessageSending ) {
					dispatch_semaphore_signal(semaphore);
					NSTimeInterval interval = -[start timeIntervalSinceNow];
					NSLog(@"test18SendMessage %f", interval);
					STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+2, @"Timeout no correct, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
			   }
			}];

			while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
		}
}

-(void)unswizzleFromReceipt:(SwizzleReceipt *)receipt {
	[Swizzler unswizzleFromReceipt:receipt];
	NSLog(@"unswizzleFromReceipt");
}

- (void)t20SubscribeOnChannels {
	[self resetConnection];
	SwizzleReceipt *receipt = [self setNewDataForBuffer];

	handleClientSubscriptionProcess = NO;
	__block NSDate *start = [NSDate date];
	__block BOOL isCompletionBlockCalled = NO;
	[PubNub subscribeOnChannels: pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
		 NSTimeInterval interval = -[start timeIntervalSinceNow];
		 NSLog( @"test20SubscribeOnChannels %f", interval);

		 isCompletionBlockCalled = YES;
		 NSLog(@"test20SubscribeOnChannels %@, %@", (subscriptionError!=nil) ? @"" : channels, subscriptionError);
		 STAssertNotNil( subscriptionError, @"subscriptionError %@", subscriptionError);
	 }];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		isCompletionBlockCalled == NO /*&& notificationParticipantsListCalled == NO*/; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

	STAssertTrue(isCompletionBlockCalled, @"Completion block not called");
	[Swizzler unswizzleFromReceipt:receipt];
}

-(void)t40SendMessage {
	messageSendingDidFailCount = 0;
	for( int i=0; i<pnChannels.count; i++ ) {
		SwizzleReceipt *receipt = [self setNewDataForBuffer];
		__block BOOL isCompletionBlockCalled = NO;
		__block PNMessageState state = PNMessageSendingError;
		[PubNub sendMessage:@"Hello PubNub" toChannel:pnChannels[i]
									  withCompletionBlock:^(PNMessageState messageSendingState, id data) {
										  if( messageSendingState != PNMessageSending )
											   isCompletionBlockCalled = YES;
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
	}
}

-(void)t45RequestHistoryForChannel {
	SwizzleReceipt *receipt = [self setNewDataForBuffer];
	for( int i=0; i<pnChannels.count && i<2; i++ ) {
		PNDate *startDate = [PNDate dateWithDate:[NSDate dateWithTimeIntervalSinceNow:(-3600.0f)]];
		PNDate *endDate = [PNDate dateWithDate:[NSDate date]];
		int limit = 34;
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: limit reverseHistory: YES isExpectationError: YES];
		[self requestHistoryForChannel: pnChannels[i] from: endDate to: startDate limit: limit reverseHistory: YES isExpectationError: YES];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: startDate limit: limit reverseHistory: YES isExpectationError: YES];
		[self requestHistoryForChannel: pnChannels[i] from: endDate to: endDate limit: limit reverseHistory: NO isExpectationError: YES];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: limit reverseHistory: NO isExpectationError: YES];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: 0 reverseHistory: NO isExpectationError: YES];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: nil limit: 0 reverseHistory: NO isExpectationError: YES];
	}
	[Swizzler unswizzleFromReceipt: receipt];
}


- (void)t50SubscribeOnChannels1 {
	[self resetConnection];
	SwizzleReceipt *receipt = [self setNewDataForBuffer1];

	handleClientSubscriptionProcess = NO;
	__block BOOL isCompletionBlockCalled = NO;
	[PubNub subscribeOnChannels: pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
		 isCompletionBlockCalled = YES;
		 NSLog(@"test50SubscribeOnChannels1 %@, %@", (subscriptionError!=nil) ? @"" : channels, subscriptionError);
		 STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
	 }];
    // Run loop
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		isCompletionBlockCalled == NO /*&& notificationParticipantsListCalled == NO*/; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

	STAssertTrue(isCompletionBlockCalled, @"Completion block not called");
	[Swizzler unswizzleFromReceipt: receipt];
}

-(void)t60SendMessage1 {
	messageSendingDidFailCount = 0;
	for( int i=0; i<pnChannels.count; i++ )
	{
		SwizzleReceipt *receipt = [self setNewDataForBuffer1];
		__block BOOL isCompletionBlockCalled = NO;
		__block PNMessageState state = PNMessageSendingError;
		[PubNub sendMessage:@"Hello PubNub" toChannel:pnChannels[i] withCompletionBlock:^(PNMessageState messageSendingState, id data)
									   {
										   if( messageSendingState == PNMessageSending )
											   return;
										   isCompletionBlockCalled = YES;
										   state = messageSendingState;
										   NSLog(@"sendMessage state %@%@%@",
												 (messageSendingState==PNMessageSending) ? @"PNMessageSending" : @"",
												 (messageSendingState==PNMessageSent) ? @"PNMessageSent" : @"",
												 (messageSendingState==PNMessageSendingError) ? @"PNMessageSendingError" : @"");
										   STAssertTrue(messageSendingState==PNMessageSent, @"messageSendingState can't be equal PNMessageSendingError, %@", data);
									   }];

		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
			isCompletionBlockCalled == NO /*&& notificationParticipantsListCalled == NO*/; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		[Swizzler unswizzleFromReceipt: receipt];
		STAssertTrue(isCompletionBlockCalled, @"completion block not called");
	}
}

-(void)t70RequestHistoryForChannel1
{
	SwizzleReceipt *receipt = [self setNewDataForBuffer1];
	for( int i=0; i<pnChannels.count && i<2; i++ )
	{
		PNDate *startDate = [PNDate dateWithDate:[NSDate dateWithTimeIntervalSinceNow:(-3600.0f)]];
		PNDate *endDate = [PNDate dateWithDate:[NSDate date]];
		int limit = 34;
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: limit reverseHistory: YES isExpectationError: NO];
		[self requestHistoryForChannel: pnChannels[i] from: endDate to: startDate limit: limit reverseHistory: YES isExpectationError: NO];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: startDate limit: limit reverseHistory: YES isExpectationError: NO];
		[self requestHistoryForChannel: pnChannels[i] from: endDate to: endDate limit: limit reverseHistory: NO isExpectationError: NO];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: limit reverseHistory: NO isExpectationError: NO];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: 0 reverseHistory: NO isExpectationError: NO];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: nil limit: 0 reverseHistory: NO isExpectationError: NO];
	}
	[Swizzler unswizzleFromReceipt: receipt];
	NSLog(@"test finish");
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
