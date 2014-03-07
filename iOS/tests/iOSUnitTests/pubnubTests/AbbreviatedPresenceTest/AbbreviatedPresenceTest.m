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
#import "TestSemaphor.h"
#import "PNClient.h"
#import "PNPresenceEvent.h"

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
							 object:nil];
}

- (void)test10Connect
{
	[PubNub disconnect];
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

	[PubNub setDelegate:self];
	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"pub-c-bb4a4d9b-21b1-40e8-a30b-04a22f5ef154" subscribeKey:@"sub-c-6b43405c-3694-11e3-a5ee-02ee2ddab7fe" secretKey: @"sec-c-ZmNlNzczNTEtOGUwNS00MmRjLWFkMjQtMjJiOTA2MjY2YjI5" cipherKey: nil];
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

	[PubNub grantAllAccessRightsForApplicationAtPeriod: 10 andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		STAssertNil( error, @"grantAllAccessRightsForApplicationAtPeriod %@", error);
	}];
	for( int j=0; j<10; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

	BOOL isConnect = [[PubNub sharedInstance] isConnected];
	STAssertTrue( isConnect, @"not connected");

	__block BOOL isCompletionBlockCalled = NO;
//	NSDate *start = [NSDate date];
	[PubNub subscribeOnChannels: @[[PNChannel channelWithName: @"zzz" shouldObservePresence: YES shouldUpdatePresenceObservingFlag: YES]]
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
			 //			 dispatch_semaphore_signal(semaphore);
			 isCompletionBlockCalled = YES;
	 }];
//	[self subscribeOnChannelsByTurns];

	// Run loop
	clientDidReceivePresenceEvent = 0; 
	for( int j=0; j<60 && clientDidReceivePresenceEvent <= 2; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	isConnect = [PubNub sharedInstance].isConnected;
	if( isConnect == YES )
		STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	STAssertTrue( clientDidReceivePresenceEvent >= 2, @"clientDidReceivePresenceEvent not received (%d)", clientDidReceivePresenceEvent);
}

- (void)subscribeOnChannelsByTurns
{
	for( int i = 0; i<20; i++ )
	{
		NSString *channelName = [NSString stringWithFormat: @"%@ %d", [NSDate date], i];
		NSArray *arr = [PNChannel channelsWithNames: @[channelName]];
		NSDate *start = [NSDate date];
		NSLog(@"Start subscribe to channel %@", channelName);
		[PubNub subscribeOnChannels: arr
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
			 [[TestSemaphor sharedInstance] lift:channelName];
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
		STAssertTrue([[TestSemaphor sharedInstance] waitForKey: channelName timeout: [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1], @"completion block not called, %@", channelName);
	}
}

- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification {
    // Retrieve reference on presence event which was received
	NSLog(@"clientDidReceivePresenceEvent %@", notification);
    PNPresenceEvent *event = (PNPresenceEvent *)notification.userInfo;
	if( event.client.identifier == nil )
		clientDidReceivePresenceEvent ++;
}


@end
