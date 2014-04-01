//
//  HistoryPamTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/28/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

//#import <OCMock/OCMock.h>

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"

@interface HistoryPamTest : SenTestCase <PNDelegate> {
	NSArray *pnChannels;
	NSString *authorizationKey;

	int timeout;
	int timeoutHistory;
	int timeoutNewMessage;
	BOOL isPNClientSubscriptionDidCompleteNotification;
	BOOL isPNClientSubscriptionDidFailNotification;

	BOOL isPNClientAccessRightsChangeDidCompleteNotification;

	BOOL isPNClientDidSendMessageNotification;
	BOOL isPNClientMessageSendingDidFailNotification;

	BOOL isPNClientDidReceiveMessagesHistoryNotification;
	BOOL isPNClientHistoryDownloadFailedWithErrorNotification;

	int countPNClientDidReceiveMessageNotification;
	int indexMessage;

	BOOL isPNClientUnsubscriptionDidCompleteNotification;
	BOOL isPNClientUnsubscriptionDidFailNotification;

	BOOL isPNClientAccessRightsAuditDidCompleteNotification;
	BOOL isPNClientAccessRightsAuditDidFailNotification;
}

@end

@implementation HistoryPamTest

- (void)setUp {
    [super setUp];
    [PubNub setDelegate:self];
	pnChannels = [PNChannel channelsWithNames:@[@"ch"]];
	authorizationKey = [NSString stringWithFormat:@"a2"/*, [NSDate date]*/];
	timeout = 15;
	timeoutHistory = 24;
	timeoutNewMessage = 10;
	indexMessage = 0;

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientAccessRightsAuditDidCompleteNotification:)
							   name: kPNClientAccessRightsAuditDidCompleteNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientAccessRightsAuditDidFailNotification:)
							   name:kPNClientAccessRightsAuditDidFailNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientSubscriptionDidCompleteNotification:)
							   name:kPNClientSubscriptionDidCompleteNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientSubscriptionDidFailNotification:)
							   name:kPNClientSubscriptionDidFailNotification
							 object:nil];

	[notificationCenter addObserver:self
						   selector:@selector(kPNClientAccessRightsChangeDidCompleteNotification:)
							   name:kPNClientAccessRightsChangeDidCompleteNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientUnsubscriptionDidCompleteNotification:)
							   name:kPNClientUnsubscriptionDidCompleteNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientUnsubscriptionDidFailNotification:)
							   name:kPNClientUnsubscriptionDidFailNotification
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
						   selector:@selector(kPNClientDidReceiveMessageNotification:)
							   name:kPNClientDidReceiveMessageNotification
							 object:nil];

	[notificationCenter addObserver:self
						   selector:@selector(kPNClientDidReceiveMessagesHistoryNotification:)
							   name:kPNClientDidReceiveMessagesHistoryNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientHistoryDownloadFailedWithErrorNotification:)
							   name:kPNClientHistoryDownloadFailedWithErrorNotification
							 object:nil];
}

- (void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
	[super tearDown];
}

-(void)kPNClientSubscriptionDidCompleteNotification:(NSNotification*)notification {
	NSLog(@"kPNClientSubscriptionDidCompleteNotification");
	isPNClientSubscriptionDidCompleteNotification = YES;
}
-(void)kPNClientSubscriptionDidFailNotification:(NSNotification*)notificaiotn {
	NSLog(@"kPNClientSubscriptionDidFailNotification");
	isPNClientSubscriptionDidFailNotification = YES;
}


-(void)kPNClientAccessRightsChangeDidCompleteNotification:(NSNotification*)notification {
	NSLog(@"kPNClientAccessRightsChangeDidCompleteNotification");
	isPNClientAccessRightsChangeDidCompleteNotification = YES;
}

-(void)kPNClientDidSendMessageNotification:(NSNumber*)notification {
	NSLog(@"kPNClientDidSendMessageNotification");
	isPNClientDidSendMessageNotification = YES;
}
-(void)kPNClientMessageSendingDidFailNotification:(NSNumber*)notification {
	NSLog(@"kPNClientMessageSendingDidFailNotification");
	isPNClientMessageSendingDidFailNotification = YES;
}

-(void)kPNClientDidReceiveMessagesHistoryNotification:(NSNumber*)notification {
	NSLog(@"kPNClientDidReceiveMessagesHistoryNotification");
	isPNClientDidReceiveMessagesHistoryNotification = YES;
}
-(void)kPNClientHistoryDownloadFailedWithErrorNotification:(NSNumber*)notification {
	NSLog(@"kPNClientHistoryDownloadFailedWithErrorNotification");
	isPNClientHistoryDownloadFailedWithErrorNotification = YES;
}
//////////////////////////////////////////////////////////////////////////////

- (void)test10Connect {
	[PubNub resetClient];
	for( int j=0; j<3; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

	[PubNub setDelegate:self];
	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"pub-c-bb4a4d9b-21b1-40e8-a30b-04a22f5ef154" subscribeKey:@"sub-c-6b43405c-3694-11e3-a5ee-02ee2ddab7fe" secretKey: @"sec-c-ZmNlNzczNTEtOGUwNS00MmRjLWFkMjQtMjJiOTA2MjY2YjI5" cipherKey: nil authorizationKey: authorizationKey];
	[PubNub setConfiguration: configuration];

	[PubNub connectWithSuccessBlock:^(NSString *origin) {
		PNLog(PNLogGeneralLevel, nil, @"\n\n\n\n\n\n\n{BLOCK} PubNub client connected to: %@", origin);
		dispatch_semaphore_signal(semaphore);
	}
						 errorBlock:^(PNError *connectionError) {
							 PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
							 dispatch_semaphore_signal(semaphore);
							 STFail(@"connectionError %@", connectionError);
						 }];
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];

	for( int j=0; j<2; j++ ) {
		[self revokeAccessRightsForApplication];
		[self revokeAccessRightsForChannels];

		[self requestHistoryForChannelsIsExpectError: YES];
		for( int i=0; i<pnChannels.count; i++ )
			[self grantWriteAccessRightForChannel: pnChannels[i] forPeriod: 1];
		[self requestHistoryForChannelsIsExpectError: YES];

		[self grantAllAccessRightsForApplicationAtPeriod: 1];
		[self subscribeOnChannels: pnChannels isExpectError: NO];
		[self sendMessageIsExpectError: NO];
		[self requestHistoryForChannelsIsExpectError: NO];

		[self revokeAccessRightsForApplication];
		[self revokeAccessRightsForChannels];
		[self requestHistoryForChannelsIsExpectError: YES];
	}
}

-(void)subscribeOnChannels:(NSArray*)channels isExpectError:(BOOL)isExpectError {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientSubscriptionDidCompleteNotification = NO;
	isPNClientSubscriptionDidFailNotification = NO;

	NSLog(@"subscribeOnChannels start");
	[PubNub subscribeOnChannels: channels withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
		isBlockCalled = YES;
		if( isExpectError == NO ) {
			STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
			STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
		}
		else
			STAssertNotNil( subscriptionError, @"request must return error %@", subscriptionError);

		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"subscribeOnChannels interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; /*j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
				   isBlockCalled == NO*/ j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	NSLog(@"subscribeOnChannels end");
	STAssertTrue( isBlockCalled, @"completion block not called");
	if( isExpectError == NO ) {
		STAssertTrue( isPNClientSubscriptionDidCompleteNotification, @"notification not called");
		STAssertFalse( isPNClientSubscriptionDidFailNotification, @"wrong notification called");
	}
	if( isExpectError == YES ) {
		STAssertFalse( isPNClientSubscriptionDidCompleteNotification, @"wrong notification called");
		STAssertTrue( isPNClientSubscriptionDidFailNotification, @"notification not called");
	}
}

- (void)kPNClientUnsubscriptionDidCompleteNotification:(NSNotification *)notification {
	NSLog( @"kPNClientUnsubscriptionDidCompleteNotification %@", notification.userInfo);
	isPNClientUnsubscriptionDidCompleteNotification = YES;
}
- (void)kPNClientUnsubscriptionDidFailNotification:(NSNotification *)notification {
	NSLog( @"kPNClientUnsubscriptionDidFailNotification %@", notification.userInfo);
	isPNClientUnsubscriptionDidFailNotification = YES;
}

-(void)unsubscribeFromChannels:(NSArray*)channels isExpectError:(BOOL)isExpectError {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientUnsubscriptionDidCompleteNotification = NO;
	isPNClientUnsubscriptionDidFailNotification = NO;

	NSLog(@"unsubscribeFromChannels start");
	[PubNub unsubscribeFromChannels: channels withCompletionHandlingBlock:^(NSArray *channels, PNError *subscriptionError) {
		isBlockCalled = YES;
		if( isExpectError == NO ) {
			STAssertNil( subscriptionError, @"unsubscribeFromChannels %@", subscriptionError);
		}
		else
			STAssertNotNil( subscriptionError, @"request must return error %@", subscriptionError);

		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"unsubscribeFromChannels interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isBlockCalled, @"completion block not called");
	if( isExpectError == NO ) {
		STAssertTrue( isPNClientUnsubscriptionDidCompleteNotification, @"notification not called");
		STAssertFalse( isPNClientUnsubscriptionDidFailNotification, @"wrong notification called");
	}
	if( isExpectError == YES ) {
		STAssertFalse( isPNClientUnsubscriptionDidCompleteNotification, @"wrong notification called");
		STAssertTrue( isPNClientUnsubscriptionDidFailNotification, @"notification not called");
	}
}

-(void)grantAllAccessRightsForApplicationAtPeriod:(NSUInteger)accessPeriodDuration {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantAllAccessRightsForApplicationAtPeriod: accessPeriodDuration andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		STAssertNil( error, @"grantAllAccessRightsForApplicationAtPeriod %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantAllAccessRightsForApplicationAtPeriod interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isBlockCalled, @"completion block not called");
	STAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)grantReadAccessRightForApplicationAtPeriod:(NSUInteger)accessPeriodDuration {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantReadAccessRightForApplicationAtPeriod: accessPeriodDuration andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		STAssertNil( error, @"grantReadAccessRightForApplicationAtPeriod %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantReadAccessRightForApplicationAtPeriod interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isBlockCalled, @"completion block not called");
	STAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)revokeAccessRightsForApplication {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	NSLog(@"revokeAccessRightsForApplicationWithCompletionHandlingBlock start");
	[PubNub revokeAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		STAssertNil( error, @"revokeAccessRightsForApplication %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"revokeAccessRightsForApplication interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	NSLog(@"revokeAccessRightsForApplicationWithCompletionHandlingBlock end");
	STAssertTrue( isBlockCalled, @"completion block not called");
	STAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)sendMessageIsExpectError:(BOOL)isExpectError {
	for( int i=0; i<pnChannels.count; i++ )	{
		isPNClientDidSendMessageNotification = NO;
		isPNClientMessageSendingDidFailNotification = NO;
		__block BOOL isBlockCalled = NO;
		NSString *string = [NSString stringWithFormat: @"Hello PubNub %@, index %d", [NSDate date], indexMessage ];
		indexMessage++;
		NSLog(@"start sendMessage   %@", string);
		[PubNub sendMessage: string toChannel:pnChannels[i] withCompletionBlock:^(PNMessageState messageSendingState, id data) {
			NSLog(@"sendMessage, state %d", (int)messageSendingState);
			if( messageSendingState == PNMessageSending )
				return;

			isBlockCalled = YES;
			if( isExpectError == NO ) {
				STAssertFalse(messageSendingState==PNMessageSendingError, @"messageSendingState == PNMessageSendingError %@", data);
			}
			else {
				STAssertTrue(messageSendingState==PNMessageSendingError, @"messageSendingState != PNMessageSendingError %@", data);
			}
		}];

		for( int j=0; j<timeout; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		STAssertTrue( isBlockCalled, @"completion block not called");
	}
	if( isExpectError == NO ) {
		STAssertTrue( isPNClientDidSendMessageNotification, @"notification not called");
		STAssertFalse( isPNClientMessageSendingDidFailNotification, @"wrong notification called");
	}
	if( isExpectError == YES ) {
		STAssertFalse( isPNClientDidSendMessageNotification, @"wrong notification called");
		STAssertTrue( isPNClientMessageSendingDidFailNotification, @"notification not called");
	}
}

-(void)grantAllAccessRightsForChannels {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantAllAccessRightsForChannels: pnChannels forPeriod: 10 withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		STAssertNil( error, @"grantAllAccessRightsForChannels %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantAllAccessRightsForChannels interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isBlockCalled, @"completion block not called");
	STAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)revokeAccessRightsForChannels {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub revokeAccessRightsForChannels: pnChannels withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		STAssertNil( error, @"revokeAccessRightsForChannels %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"revokeAccessRightsForChannels interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isBlockCalled, @"completion block not called");
	STAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}


-(void)grantWriteAccessRightForChannels {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantWriteAccessRightForChannels: pnChannels forPeriod: 10 withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		STAssertNil( error, @"grantWriteAccessRightForChannels %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantWriteAccessRightForChannels interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isBlockCalled, @"completion block not called");
	STAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)grantReadAccessRightForChannels {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantReadAccessRightForChannels: pnChannels forPeriod: 10 withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		STAssertNil( error, @"grantReadAccessRightForChannels %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantReadAccessRightForChannels interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isBlockCalled, @"completion block not called");
	STAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

/////////////////////////////////////////////////////
-(void)requestHistoryForChannelsIsExpectError:(BOOL)isExpectError {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	for( int i=0; i<pnChannels.count; i++ ) {
		isPNClientDidReceiveMessagesHistoryNotification = NO;
		isPNClientHistoryDownloadFailedWithErrorNotification = NO;
		[PubNub requestHistoryForChannel: pnChannels[i] from: nil to: nil limit: 0 reverseHistory: NO withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *fromDate, PNDate *toDate, PNError *error) {
			isBlockCalled = YES;

			if( isExpectError == NO ) {
				[self auditAccessRightsForApplication];
				for( int i=0; i<pnChannels.count; i++ )
					[self auditAccessRightsForChannel: pnChannels[i] client: authorizationKey];
				STAssertNil( error, @"requestHistoryForChannel %@", error);
			}
			else {
				[self auditAccessRightsForApplication];
				for( int i=0; i<pnChannels.count; i++ )
					[self auditAccessRightsForChannel: pnChannels[i] client: authorizationKey];
				STAssertNotNil( error, @"request must return error %@", error);
			}

			NSTimeInterval interval = -[start timeIntervalSinceNow];
			NSLog(@"requestHistoryForChannel interval %f", interval);
//			STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
		}];
		for( int j=0; j<timeoutHistory; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		STAssertTrue( isBlockCalled, @"completion block not called");
	}
	if( isExpectError == NO ) {
		STAssertTrue( isPNClientDidReceiveMessagesHistoryNotification, @"notification not called");
		STAssertFalse( isPNClientHistoryDownloadFailedWithErrorNotification, @"wrong notification called");
	}
	if( isExpectError == YES ) {
		STAssertFalse( isPNClientDidReceiveMessagesHistoryNotification, @"wrong notification called");
		STAssertTrue( isPNClientHistoryDownloadFailedWithErrorNotification, @"notification not called");
	}
}
/////////////////////////////////////
-(void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSUInteger)accessPeriodDuration {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantAllAccessRightsForChannel: channel forPeriod: accessPeriodDuration withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		STAssertNil( error, @"grantAllAccessRightsForChannel %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantAllAccessRightsForChannel interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isBlockCalled, @"completion block not called");
	STAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSUInteger)accessPeriodDuration {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantWriteAccessRightForChannel: channel forPeriod: accessPeriodDuration withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		STAssertNil( error, @"grantWriteAccessRightForChannel %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantWriteAccessRightForChannel interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isBlockCalled, @"completion block not called");
	STAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}
////////////////////////////////////////////////////////////
-(void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSUInteger)accessPeriodDuration client:(NSString *)clientAuthorizationKey {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantAllAccessRightsForChannel: channel forPeriod: accessPeriodDuration client: clientAuthorizationKey withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		STAssertNil( error, @"grantAllAccessRightsForChannelClient %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantAllAccessRightsForChannelClient interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isBlockCalled, @"completion block not called");
	STAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)grantWriteRightsForChannel:(PNChannel *)channel forPeriod:(NSUInteger)accessPeriodDuration client:(NSString *)clientAuthorizationKey {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantWriteAccessRightForChannel: channel forPeriod: accessPeriodDuration client: clientAuthorizationKey withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		STAssertNil( error, @"grantWriteRightsForChannelClient %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantWriteRightsForChannelClient interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isBlockCalled, @"completion block not called");
	STAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}
////////////////////////////////////////////////////////////
-(void)startDetectNewMessage {
	NSLog(@"startDetectNewMessage");
	countPNClientDidReceiveMessageNotification = 0;
}

-(void)checkNewMessageIsExpect0:(BOOL)isExpect0 {
	for( int j=0; j<timeoutNewMessage; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	if( isExpect0 == YES )
		STAssertTrue( countPNClientDidReceiveMessageNotification==0, @"came the extra posts");
	else
		STAssertTrue( countPNClientDidReceiveMessageNotification>0, @"messages do not come");
	[self startDetectNewMessage];
}

-(void)kPNClientDidReceiveMessageNotification:(NSNotification *)notification {
	NSLog( @"kPNClientDidReceiveMessageNotification %@", notification.userInfo);
	countPNClientDidReceiveMessageNotification++;
}

//////////////////////////////
-(void)kPNClientAccessRightsAuditDidCompleteNotification:(NSNotification *)notification {
	NSLog( @"kPNClientAccessRightsAuditDidCompleteNotification %@", notification.userInfo);
	isPNClientAccessRightsAuditDidCompleteNotification = YES;
}

-(void)kPNClientAccessRightsAuditDidFailNotification:(NSNotification *)notification {
	NSLog( @"kPNClientAccessRightsAuditDidFailNotification %@", notification.userInfo);
	isPNClientAccessRightsAuditDidFailNotification = YES;
}

-(PNAccessRightsCollection*)auditAccessRightsForApplication {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	__block PNAccessRightsCollection *coll = nil;
	isPNClientAccessRightsAuditDidCompleteNotification = NO;
	isPNClientAccessRightsAuditDidFailNotification = NO;
	[PubNub auditAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		coll = collection;
		NSLog(@"auditAccessRightsForApplicationWithCompletionHandlingBlock \n%@", collection);
		STAssertNil( error, @"auditAccessRightsForApplicationWithCompletionHandlingBlock %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"auditAccessRightsForApplicationWithCompletionHandlingBlock interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isBlockCalled, @"completion block not called");
	STAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");

	STAssertTrue( isPNClientAccessRightsAuditDidCompleteNotification, @"notification not called");
	STAssertFalse( isPNClientAccessRightsAuditDidFailNotification, @"wrong notification called");
	return coll;
}

-(PNAccessRightsCollection*)auditAccessRightsForChannel:(PNChannel *)channel client:(NSString *)clientAuthorizationKey {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	__block PNAccessRightsCollection *coll = nil;
	isPNClientAccessRightsAuditDidCompleteNotification = NO;
	isPNClientAccessRightsAuditDidFailNotification = NO;
	[PubNub auditAccessRightsForChannel: channel client: clientAuthorizationKey withCompletionHandlingBlock: ^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		coll = collection;
		NSLog(@"auditAccessRightsForChannel \n%@", collection);
		STAssertNil( error, @"auditAccessRightsForChannel %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"auditAccessRightsForChannel interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isBlockCalled, @"completion block not called");
	STAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");

	STAssertTrue( isPNClientAccessRightsAuditDidCompleteNotification, @"notification not called");
	STAssertFalse( isPNClientAccessRightsAuditDidFailNotification, @"wrong notification called");
	return coll;
}

-(void)isApplicationCanReadExpect:(BOOL)canRead canWriteExpect:(BOOL)canWrite {
	PNAccessRightsCollection *col = [self auditAccessRightsForApplication];
	PNAccessRightsInformation *infoApp = col.accessRightsInformationForApplication;
	STAssertTrue( [infoApp hasReadRight] == canRead, @"wrong rights" );
	STAssertTrue( [infoApp hasWriteRight] == canWrite, @"wrong rights" );
}

-(void)isChannelsClientAuthorizationKey:(NSString *)clientAuthorizationKey canReadExpect:(BOOL)canRead canWriteExpect:(BOOL)canWrite {
	PNAccessRightsCollection *col = nil;
	if( clientAuthorizationKey == nil )
		col = [self auditAccessRightsForApplication];
	for( int i=0; i<pnChannels.count; i++ ) {
		PNAccessRightsInformation *info = nil;
		if( clientAuthorizationKey == nil )
			info = [col accessRightsInformationForChannel: pnChannels[i]];
		else {
			col = [self auditAccessRightsForChannel: pnChannels[i] client: clientAuthorizationKey];
			info = [col accessRightsInformationClientAuthorizationKey: clientAuthorizationKey onChannel: pnChannels[i]];
		}
		STAssertTrue( [info hasReadRight] == canRead, @"wrong rights" );
		STAssertTrue( [info hasWriteRight] == canWrite, @"wrong rights" );
	}
}


@end
