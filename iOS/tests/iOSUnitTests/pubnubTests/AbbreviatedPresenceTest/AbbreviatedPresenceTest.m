//
//  AbbreviatedPresenceTest.m
//  pubnub
//
//  Created by Valentin Tuller on 10/23/13.
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

@interface AbbreviatedPresenceTest : SenTestCase <PNDelegate> {
	int clientDidReceivePresenceEvent;
}

@end

@implementation AbbreviatedPresenceTest

- (void)setUp
{
    [super setUp];
    [PubNub setDelegate:self];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientDidReceivePresenceEvent:)
							   name:kPNClientDidReceivePresenceEventNotification
							 object:nil];}

- (void)test10Connect
{
	[PubNub disconnect];
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

	[PubNub setDelegate:self];
	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"pub-c-6887e7f3-aec8-4470-b9a0-e68567c7bd71" subscribeKey:@"sub-c-2d4a4646-0e77-11e3-9bef-02ee2ddab7fe" secretKey: @"sec-c-ZjRmZmQzMmYtMDMxMC00NDU1LTliOTUtZmM1ODNlZWM3ZGVm" cipherKey: nil];
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

	BOOL isConnect = [[PubNub sharedInstance] isConnected];
	STAssertTrue( isConnect, @"not connected");

	__block BOOL isCompletionBlockCalled = NO;
//	NSDate *start = [NSDate date];
	[PubNub subscribeOnChannels: @[[PNChannel channelWithName: @"zzz" shouldObservePresence: YES shouldUpdatePresenceObservingFlag: YES]]
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
			 //			 dispatch_semaphore_signal(semaphore);
			 isCompletionBlockCalled = YES;
	 }];

	// Run loop
	clientDidReceivePresenceEvent = 0;
	for( int j=0; j<160; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	isConnect = [PubNub sharedInstance].isConnected;
	if( isConnect == YES )
		STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	STAssertTrue( clientDidReceivePresenceEvent > 5, @"clientDidReceivePresenceEvent not received (%d)", clientDidReceivePresenceEvent);
}

- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification {
    // Retrieve reference on presence event which was received
	NSLog(@"clientDidReceivePresenceEvent %@", notification);
    PNPresenceEvent *event = (PNPresenceEvent *)notification.userInfo;
	if( event.uuid == nil )
		clientDidReceivePresenceEvent ++;
}


@end
