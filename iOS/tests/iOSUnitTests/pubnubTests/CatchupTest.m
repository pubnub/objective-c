//
//  CatchupTest.m
//  pubnub
//
//  Created by Valentin Tuller on 10/21/13.
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
#import "PNNotifications.h"


@interface CatchupTest : SenTestCase <PNDelegate> {
	NSArray *pnChannels;
	BOOL isPNClientDidReceivePresenceEventNotification;
	BOOL isHandleClientPresenceObservationEnablingProcess;
}

@end

@implementation CatchupTest

- (void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
	[super tearDown];
}



- (void)setUp
{
    [super setUp];
    [PubNub setDelegate:self];
	pnChannels = [PNChannel channelsWithNames:@[[NSString stringWithFormat: @"%@", [NSDate date]]]];


	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	// Handle subscription events
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientSubscriptionProcess:)
//							   name:kPNClientSubscriptionDidCompleteNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientSubscriptionProcess:)
//							   name:kPNClientSubscriptionWillRestoreNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientSubscriptionProcess:)
//							   name:kPNClientSubscriptionDidRestoreNotification
//							 object:nil];
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
	[notificationCenter addObserver:self
						   selector:@selector(handleClientPresenceObservationEnablingProcess:)
							   name:kPNClientPresenceEnablingDidCompleteNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientPresenceObservationEnablingProcess:)
							   name:kPNClientPresenceEnablingDidFailNotification
							 object:nil];
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


	// Handle time token events
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientCompletedTimeTokenProcessing:)
//							   name:kPNClientDidReceiveTimeTokenNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientCompletedTimeTokenProcessing:)
//							   name:kPNClientDidFailTimeTokenReceiveNotification
//							 object:nil];


	// Handle message processing events
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientMessageProcessingStateChange:)
//							   name:kPNClientWillSendMessageNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientMessageProcessingStateChange:)
//							   name:kPNClientDidSendMessageNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientMessageProcessingStateChange:)
//							   name:kPNClientMessageSendingDidFailNotification
//							 object:nil];

	// Handle messages/presence event arrival
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientDidReceiveMessage:)
//							   name:kPNClientDidReceiveMessageNotification
//							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientDidReceivePresenceEvent:)
							   name:kPNClientDidReceivePresenceEventNotification
							 object:nil];

//	// Handle message history events arrival
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientMessageHistoryProcess:)
//							   name:kPNClientDidReceiveMessagesHistoryNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientMessageHistoryProcess:)
//							   name:kPNClientHistoryDownloadFailedWithErrorNotification
//							 object:nil];
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

- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientDidReceivePresenceEvent: %@", notification);
	isPNClientDidReceivePresenceEventNotification = YES;
}

- (void)handleClientPresenceObservationEnablingProcess:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientPresenceObservationEnablingProcess: %@", notification);
	isHandleClientPresenceObservationEnablingProcess = YES;
}


- (void)test10Connect
{
	[PubNub disconnect];
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		//		[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];
		PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil];
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
	});
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];


    semaphore = dispatch_semaphore_create(0);
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
}

-(void)test20Catchup {
	NSString *clientIdentifier = [NSString stringWithFormat: @"%@", [NSDate date]];
	isPNClientDidReceivePresenceEventNotification = NO;
	isHandleClientPresenceObservationEnablingProcess = NO;

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

        [PubNub setClientIdentifier: clientIdentifier shouldCatchup:YES];
    });

	delayInSeconds = 15;
	popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		dispatch_semaphore_signal(semaphore);
		STAssertFalse( isPNClientDidReceivePresenceEventNotification, @"notification DidReceivePresence must should not come");
		STAssertFalse( isHandleClientPresenceObservationEnablingProcess, @"notification HandleClientPresence must should not come");
		NSString *newIdentifier = [PubNub clientIdentifier];
		STAssertEqualObjects( clientIdentifier, newIdentifier, @"identifires must be equla");
    });
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}


@end
