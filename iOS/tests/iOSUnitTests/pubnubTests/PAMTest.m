//
//  PAMTest.m
//  pubnub
//
//  Created by Valentin Tuller on 12/5/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import <OCMock/OCMock.h>

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"

@interface PAMTest : SenTestCase <PNDelegate> {
	NSArray *pnChannels;
	NSString *authorizationKey;

	int timeout;
	BOOL isPNClientSubscriptionDidCompleteNotification;
	BOOL isPNClientSubscriptionDidFailNotification;

	BOOL isPNClientAccessRightsChangeDidCompleteNotification;

	BOOL isPNClientDidSendMessageNotification;
	BOOL isPNClientMessageSendingDidFailNotification;

	BOOL isPNClientDidReceiveMessagesHistoryNotification;
	BOOL isPNClientHistoryDownloadFailedWithErrorNotification;
}

@end

@implementation PAMTest 

- (void)setUp {
    [super setUp];
    [PubNub setDelegate:self];
	pnChannels = [PNChannel channelsWithNames:@[@"ch1", @"ch2"]];
	authorizationKey = [NSString stringWithFormat:@"a1", [NSDate date]];
	timeout = 11;

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientConnectionStateChange:)
//							   name: kPNClientDidConnectToOriginNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientConnectionStateChange:)
//							   name:kPNClientDidDisconnectFromOriginNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientConnectionStateChange:)
//							   name:kPNClientConnectionDidFailWithErrorNotification
//							 object:nil];
//
//
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
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientSubscriptionProcess:)
//							   name:kPNClientSubscriptionDidFailNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientUnsubscriptionProcess:)
//							   name:kPNClientUnsubscriptionDidCompleteNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientUnsubscriptionProcess:)
//							   name:kPNClientUnsubscriptionDidFailNotification
//							 object:nil];
//
//	// Handle presence events
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientPresenceObservationEnablingProcess:)
//							   name:kPNClientPresenceEnablingDidCompleteNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientPresenceObservationEnablingProcess:)
//							   name:kPNClientPresenceEnablingDidFailNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientPresenceObservationDisablingProcess:)
//							   name:kPNClientPresenceDisablingDidCompleteNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientPresenceObservationDisablingProcess:)
//							   name:kPNClientPresenceDisablingDidFailNotification
//							 object:nil];
//
//
//	// Handle push notification state changing events
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(handleClientPushNotificationStateChange:)
//												 name:kPNClientPushNotificationEnableDidCompleteNotification
//											   object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(handleClientPushNotificationStateChange:)
//												 name:kPNClientPushNotificationEnableDidFailNotification
//											   object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(handleClientPushNotificationStateChange:)
//												 name:kPNClientPushNotificationDisableDidCompleteNotification
//											   object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(handleClientPushNotificationStateChange:)
//												 name:kPNClientPushNotificationDisableDidFailNotification
//											   object:nil];
//
//
//	// Handle push notification remove events
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(handleClientPushNotificationRemoveProcess:)
//												 name:kPNClientPushNotificationRemoveDidCompleteNotification
//											   object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(handleClientPushNotificationRemoveProcess:)
//												 name:kPNClientPushNotificationRemoveDidFailNotification
//											   object:nil];
//
//
//	// Handle push notification enabled channels retrieve events
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(handleClientPushNotificationEnabledChannels:)
//												 name:kPNClientPushNotificationChannelsRetrieveDidCompleteNotification
//											   object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(handleClientPushNotificationEnabledChannels:)
//												 name:kPNClientPushNotificationChannelsRetrieveDidFailNotification
//											   object:nil];
//
//
//	// Handle time token events
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientCompletedTimeTokenProcessing:)
//							   name:kPNClientDidReceiveTimeTokenNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientCompletedTimeTokenProcessing:)
//							   name:kPNClientDidFailTimeTokenReceiveNotification
//							 object:nil];
//
//
//	// Handle message processing events
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientMessageProcessingStateChange:)
//							   name:kPNClientWillSendMessageNotification
//							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientDidSendMessageNotification:)
							   name:kPNClientDidSendMessageNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientMessageSendingDidFailNotification:)
							   name:kPNClientMessageSendingDidFailNotification
							 object:nil];

//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientMessageProcessingStateChange:)
//							   name:kPNClientMessageSendingDidFailNotification
//							 object:nil];
//
//	// Handle messages/presence event arrival
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientDidReceiveMessage:)
//							   name:kPNClientDidReceiveMessageNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientDidReceivePresenceEvent:)
//							   name:kPNClientDidReceivePresenceEventNotification
//							 object:nil];
//
	// Handle message history events arrival
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientDidReceiveMessagesHistoryNotification:)
							   name:kPNClientDidReceiveMessagesHistoryNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientHistoryDownloadFailedWithErrorNotification:)
							   name:kPNClientHistoryDownloadFailedWithErrorNotification
							 object:nil];
//
//	// Handle participants list arrival
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientHereNowProcess:)
//							   name:kPNClientDidReceiveParticipantsListNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientHereNowProcess:)
//							   name:kPNClientParticipantsListDownloadFailedWithErrorNotification
//							 object:nil];
}

- (void)tearDown {
	[NSThread sleepForTimeInterval:1.0];
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

	[self revokeAccessRightsForApplication];
	[self revokeAccessRightsForChannels];

	[self subscribeOnChannels: pnChannels isExpectError: YES];
	[self requestHistoryForChannelsIsExpectError: YES];
	[self grantAllAccessRightsForChannels];
	[self subscribeOnChannels: pnChannels isExpectError: NO];
	[self requestHistoryForChannelsIsExpectError: NO];
	[self sendMessageIsExpectError: NO];
	[self revokeAccessRightsForChannels];
	[self sendMessageIsExpectError: YES];
	[self requestHistoryForChannelsIsExpectError: YES];

	[self grantWriteAccessRightForChannels];
	[self sendMessageIsExpectError: NO];
	[self grantReadAccessRightForChannels];
	[self sendMessageIsExpectError: YES];
	[self requestHistoryForChannelsIsExpectError: NO];

	[self revokeAccessRightsForChannels];
	[self subscribeOnChannels: pnChannels isExpectError: YES];
	[self sendMessageIsExpectError: YES];
	[self grantAllAccessRightsForApplication];
	[self subscribeOnChannels: pnChannels isExpectError: NO];
	[self sendMessageIsExpectError: NO];
	[self requestHistoryForChannelsIsExpectError: NO];
	[self sendMessageIsExpectError: NO];
	[self revokeAccessRightsForApplication];
	[self sendMessageIsExpectError: YES];
	[self grantReadAccessRightForChannels];
	[self requestHistoryForChannelsIsExpectError: NO];
	[self revokeAccessRightsForChannels];
	[self subscribeOnChannels: pnChannels isExpectError: YES];
	[self subscribeOnChannels: pnChannels isExpectError: YES];
	[self grantAllAccessRightsForApplication];
	[self sendMessageIsExpectError: NO];
	[self grantAllAccessRightsForApplication];
	[self grantAllAccessRightsForApplication];
	[self revokeAccessRightsForApplication];
	[self revokeAccessRightsForApplication];
	[self sendMessageIsExpectError: YES];
	[self grantReadAccessRightForChannels];
	[self requestHistoryForChannelsIsExpectError: NO];
	[self revokeAccessRightsForApplication];
	[self revokeAccessRightsForApplication];
	[self grantAllAccessRightsForApplication];
	[self subscribeOnChannels: pnChannels isExpectError: NO];
	[self sendMessageIsExpectError: NO];

	[self revokeAccessRightsForApplication];
}

- (void)subscribeOnChannels:(NSArray*)channels isExpectError:(BOOL)isExpectError {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientSubscriptionDidCompleteNotification = NO;
	isPNClientSubscriptionDidFailNotification = NO;

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


-(void)grantAllAccessRightsForApplication {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub grantAllAccessRightsForApplicationAtPeriod: 10 andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
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

-(void)revokeAccessRightsForApplication {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	isPNClientAccessRightsChangeDidCompleteNotification = NO;
	[PubNub revokeAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		isBlockCalled = YES;
		STAssertNil( error, @"revokeAccessRightsForApplication %@", error);
		NSTimeInterval interval = -[start timeIntervalSinceNow];
		NSLog(@"revokeAccessRightsForApplication interval %f", interval);
		STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
	}];
	for( int j=0; j<timeout; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isBlockCalled, @"completion block not called");
	STAssertTrue( isPNClientAccessRightsChangeDidCompleteNotification, @"notification not called");
}

-(void)sendMessageIsExpectError:(BOOL)isExpectError {
	for( int i=0; i<pnChannels.count; i++ )	{
		isPNClientDidSendMessageNotification = NO;
		isPNClientMessageSendingDidFailNotification = NO;
		__block BOOL isBlockCalled = NO;
		NSLog(@"start sendMessage");
		[PubNub sendMessage: [NSString stringWithFormat: @"Hello PubNub %d", i] toChannel:pnChannels[i]
			  withCompletionBlock:^(PNMessageState messageSendingState, id data) {
				  NSLog(@"sendMessage, state %d", messageSendingState);
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


-(void)requestHistoryForChannelsIsExpectError:(BOOL)isExpectError {
	__block BOOL isBlockCalled = NO;
	__block NSDate *start = [NSDate date];
	for( int i=0; i<pnChannels.count; i++ ) {
		isPNClientDidReceiveMessagesHistoryNotification = NO;
		isPNClientHistoryDownloadFailedWithErrorNotification = NO;
		[PubNub requestHistoryForChannel: pnChannels[i] from: nil to: nil limit: 0 reverseHistory: NO withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *fromDate, PNDate *toDate, PNError *error) {
			isBlockCalled = YES;

			if( isExpectError == NO )
				STAssertNil( error, @"requestHistoryForChannel %@", error);
			else
				STAssertNotNil( error, @"request must return error %@", error);

			NSTimeInterval interval = -[start timeIntervalSinceNow];
			NSLog(@"requestHistoryForChannel interval %f", interval);
			STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
		 }];
		for( int j=0; j<timeout; j++ )
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

@end
