//
//  PAMTest.m
//  pubnub
//
//  Created by Valentin Tuller on 12/5/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"

@interface PAMTestError : XCTestCase <PNDelegate> {
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

@implementation PAMTestError

- (void)setUp {
    [super setUp];
    [PubNub setDelegate:self];
	pnChannels = [PNChannel channelsWithNames:@[@"ch1", @"ch2"]];
	authorizationKey = [NSString stringWithFormat:@"a2" /*, [NSDate date]*/];
	timeout = 10;
	timeoutHistory = 10;
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
    
	// Handle subscription events
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
	// Handle presence events
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientDidSendMessageNotification:)
							   name:kPNClientDidSendMessageNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientMessageSendingDidFailNotification:)
							   name:kPNClientMessageSendingDidFailNotification
							 object:nil];
	// Handle messages/presence event arrival
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientDidReceiveMessageNotification:)
							   name:kPNClientDidReceiveMessageNotification
							 object:nil];
	// Handle message history events arrival
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
							 XCTFail(@"connectionError %@", connectionError);
						 }];
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];

	[self revokeAccessRightsForApplication];
	[self revokeAccessRightsForChannels];
	[self grantReadAccessRightForApplicationAtPeriod: 1];
	for( int i=0; i<pnChannels.count; i++ )
		[self grantWriteRightsForChannel: pnChannels[i] forPeriod: 1 client: authorizationKey];
	[self subscribeOnChannels: pnChannels isExpectError: NO];

	[self grantAllAccessRightsForApplicationAtPeriod: 1];
	[self subscribeOnChannels: pnChannels isExpectError: NO];//error
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
			XCTAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
			XCTAssertEqualObjects( @(pnChannels.count), @(channels.count), @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
		}
		else
			XCTAssertNotNil( subscriptionError, @"request must return error %@", subscriptionError);

		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"subscribeOnChannels interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
    
	NSLog(@"subscribeOnChannels end");
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	if( isExpectError == NO ) {
		XCTAssertTrue( isPNClientSubscriptionDidCompleteNotification, @"notification not called");
		XCTAssertFalse( isPNClientSubscriptionDidFailNotification, @"wrong notification called");
	}
	if( isExpectError == YES ) {
		XCTAssertFalse( isPNClientSubscriptionDidCompleteNotification, @"wrong notification called");
		XCTAssertTrue( isPNClientSubscriptionDidFailNotification, @"notification not called");
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
			XCTAssertNil( subscriptionError, @"unsubscribeFromChannels %@", subscriptionError);
		}
		else
			XCTAssertNotNil( subscriptionError, @"request must return error %@", subscriptionError);

		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"unsubscribeFromChannels interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	if( isExpectError == NO ) {
		XCTAssertTrue( isPNClientUnsubscriptionDidCompleteNotification, @"notification not called");
		XCTAssertFalse( isPNClientUnsubscriptionDidFailNotification, @"wrong notification called");
	}
	if( isExpectError == YES ) {
		XCTAssertFalse( isPNClientUnsubscriptionDidCompleteNotification, @"wrong notification called");
		XCTAssertTrue( isPNClientUnsubscriptionDidFailNotification, @"notification not called");
	}
}

-(void)grantAllAccessRightsForApplicationAtPeriod:(NSUInteger)accessPeriodDuration {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantAllAccessRightsForApplicationAtPeriod: accessPeriodDuration andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		XCTAssertNil( error, @"grantAllAccessRightsForApplicationAtPeriod %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantAllAccessRightsForApplicationAtPeriod interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	XCTAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)grantReadAccessRightForApplicationAtPeriod:(NSUInteger)accessPeriodDuration {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantReadAccessRightForApplicationAtPeriod: accessPeriodDuration andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		XCTAssertNil( error, @"grantReadAccessRightForApplicationAtPeriod %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantReadAccessRightForApplicationAtPeriod interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	XCTAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)revokeAccessRightsForApplication {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub revokeAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		XCTAssertNil( error, @"revokeAccessRightsForApplication %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"revokeAccessRightsForApplication interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	XCTAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
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
				XCTAssertFalse(messageSendingState==PNMessageSendingError, @"messageSendingState == PNMessageSendingError %@", data);
			}
			else {
				XCTAssertTrue(messageSendingState==PNMessageSendingError, @"messageSendingState != PNMessageSendingError %@", data);
			}
		}];

		for( int j=0; j<timeout; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		XCTAssertTrue( isBlockCalled, @"completion block not called");
	}
	if( isExpectError == NO ) {
		XCTAssertTrue( isPNClientDidSendMessageNotification, @"notification not called");
		XCTAssertFalse( isPNClientMessageSendingDidFailNotification, @"wrong notification called");
	}
	if( isExpectError == YES ) {
		XCTAssertFalse( isPNClientDidSendMessageNotification, @"wrong notification called");
		XCTAssertTrue( isPNClientMessageSendingDidFailNotification, @"notification not called");
	}
}

-(void)grantAllAccessRightsForChannels {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantAllAccessRightsForChannels: pnChannels forPeriod: 10 withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		XCTAssertNil( error, @"grantAllAccessRightsForChannels %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantAllAccessRightsForChannels interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	XCTAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)revokeAccessRightsForChannels {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub revokeAccessRightsForChannels: pnChannels withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		XCTAssertNil( error, @"revokeAccessRightsForChannels %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"revokeAccessRightsForChannels interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	XCTAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}


-(void)grantWriteAccessRightForChannels {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantWriteAccessRightForChannels: pnChannels forPeriod: 10 withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		XCTAssertNil( error, @"grantWriteAccessRightForChannels %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantWriteAccessRightForChannels interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	XCTAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)grantReadAccessRightForChannels {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantReadAccessRightForChannels: pnChannels forPeriod: 10 withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		XCTAssertNil( error, @"grantReadAccessRightForChannels %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantReadAccessRightForChannels interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	XCTAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)requestHistoryForChannelsIsExpectError:(BOOL)isExpectError {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	for( int i=0; i<pnChannels.count; i++ ) {
		isPNClientDidReceiveMessagesHistoryNotification = NO;
		isPNClientHistoryDownloadFailedWithErrorNotification = NO;
		[PubNub requestHistoryForChannel: pnChannels[i] from: nil to: nil limit: 0 reverseHistory: NO withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *fromDate, PNDate *toDate, PNError *error) {
			isBlockCalled = YES;

			if( isExpectError == NO )
				XCTAssertNil( error, @"requestHistoryForChannel %@", error);
			else
				XCTAssertNotNil( error, @"request must return error %@", error);

			NSTimeInterval interval = -[start timeIntervalSinceNow];
			NSLog(@"requestHistoryForChannel interval %f", interval);
			XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
		}];
		for( int j=0; j<timeoutHistory; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		XCTAssertTrue( isBlockCalled, @"completion block not called");
	}
	if( isExpectError == NO ) {
		XCTAssertTrue( isPNClientDidReceiveMessagesHistoryNotification, @"notification not called");
		XCTAssertFalse( isPNClientHistoryDownloadFailedWithErrorNotification, @"wrong notification called");
	}
	if( isExpectError == YES ) {
		XCTAssertFalse( isPNClientDidReceiveMessagesHistoryNotification, @"wrong notification called");
		XCTAssertTrue( isPNClientHistoryDownloadFailedWithErrorNotification, @"notification not called");
	}
}

-(void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSUInteger)accessPeriodDuration {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantAllAccessRightsForChannel: channel forPeriod: accessPeriodDuration withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		XCTAssertNil( error, @"grantAllAccessRightsForChannel %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantAllAccessRightsForChannel interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	XCTAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)grantWriteAccessRightForChannel:(PNChannel *)channel forPeriod:(NSUInteger)accessPeriodDuration {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantWriteAccessRightForChannel: channel forPeriod: accessPeriodDuration withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		XCTAssertNil( error, @"grantWriteAccessRightForChannel %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantWriteAccessRightForChannel interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	XCTAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)grantAllAccessRightsForChannel:(PNChannel *)channel forPeriod:(NSUInteger)accessPeriodDuration client:(NSString *)clientAuthorizationKey {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantAllAccessRightsForChannel: channel forPeriod: accessPeriodDuration client: clientAuthorizationKey withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		XCTAssertNil( error, @"grantAllAccessRightsForChannelClient %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantAllAccessRightsForChannelClient interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	XCTAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)grantWriteRightsForChannel:(PNChannel *)channel forPeriod:(NSUInteger)accessPeriodDuration client:(NSString *)clientAuthorizationKey {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantWriteAccessRightForChannel: channel forPeriod: accessPeriodDuration client: clientAuthorizationKey withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		XCTAssertNil( error, @"grantWriteRightsForChannelClient %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"grantWriteRightsForChannelClient interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	XCTAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)startDetectNewMessage {
	NSLog(@"startDetectNewMessage");
	countPNClientDidReceiveMessageNotification = 0;
}

-(void)checkNewMessageIsExpect0:(BOOL)isExpect0 {
	for( int j=0; j<timeoutNewMessage; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	if( isExpect0 == YES )
		XCTAssertTrue( countPNClientDidReceiveMessageNotification==0, @"came the extra posts");
	else
		XCTAssertTrue( countPNClientDidReceiveMessageNotification>0, @"messages do not come");
	[self startDetectNewMessage];
}

-(void)kPNClientDidReceiveMessageNotification:(NSNotification *)notification {
	NSLog( @"kPNClientDidReceiveMessageNotification %@", notification.userInfo);
	countPNClientDidReceiveMessageNotification++;
}

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
		XCTAssertNil( error, @"auditAccessRightsForApplicationWithCompletionHandlingBlock %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"auditAccessRightsForApplicationWithCompletionHandlingBlock interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	XCTAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");

	XCTAssertTrue( isPNClientAccessRightsAuditDidCompleteNotification, @"notification not called");
	XCTAssertFalse( isPNClientAccessRightsAuditDidFailNotification, @"wrong notification called");
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
		XCTAssertNil( error, @"auditAccessRightsForChannel %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"auditAccessRightsForChannel interval %f", interval);
		XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isBlockCalled, @"completion block not called");
	XCTAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");

	XCTAssertTrue( isPNClientAccessRightsAuditDidCompleteNotification, @"notification not called");
	XCTAssertFalse( isPNClientAccessRightsAuditDidFailNotification, @"wrong notification called");
	return coll;
}

-(void)isApplicationCanReadExpect:(BOOL)canRead canWriteExpect:(BOOL)canWrite {
	PNAccessRightsCollection *col = [self auditAccessRightsForApplication];
	PNAccessRightsInformation *infoApp = col.accessRightsInformationForApplication;
	XCTAssertTrue( [infoApp hasReadRight] == canRead, @"wrong rights" );
	XCTAssertTrue( [infoApp hasWriteRight] == canWrite, @"wrong rights" );
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
		XCTAssertTrue( [info hasReadRight] == canRead, @"wrong rights" );
		XCTAssertTrue( [info hasWriteRight] == canWrite, @"wrong rights" );
	}
}

@end
