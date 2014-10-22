//
//  SubscribeLeaveTest.m
//  pubnub
//
//  Created by Valentin Tuller on 3/4/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNNotifications.h"
#import "PNPresenceEvent.h"

@interface SubscribeLeaveTest : XCTestCase <PNDelegate> {
	int leaveDelegateCount;
	int joinDelegateCount;
	int timeoutDelegateCount;
	int leaveNotificationCount;
	int joinNotificationCount;
	int timeoutNotificationCount;
	NSMutableArray *channelNames;
	int didReceiveMessageCount;
}

@end

@implementation SubscribeLeaveTest

- (void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
    [super tearDown];
}

- (void)setUp {
    [super setUp];
	channelNames = [NSMutableArray array];
	for( int i=0; i<10; i++ )
		[channelNames addObject: [NSString stringWithFormat: @"ch%d", i]];

	[PubNub resetClient];
	//[PubNub disconnect];
	[PubNub setDelegate: self];
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientDidReceivePresenceEventNotification:)
							   name:kPNClientDidReceivePresenceEventNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientSubscriptionDidCompleteNotification:)
							   name:kPNClientSubscriptionDidCompleteNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientDidReceiveMessage:)
							   name:kPNClientDidReceiveMessageNotification
							 object:nil];


    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"pub-c-c9b0fe21-4ae1-433b-b766-62667cee65ef" subscribeKey:@"sub-c-d91ee366-9dbd-11e3-a759-02ee2ddab7fe" secretKey: @"sec-c-ZDUxZGEyNmItZjY4Ny00MjJmLWE0MjQtZTQyMDM0NTY2MDVk" cipherKey: @"key"];
//	configuration = [PNConfiguration defaultConfiguration];
	[PubNub setConfiguration: configuration];

    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        PNLog(PNLogGeneralLevel, nil, @"{BLOCK} PubNub client connected to: %@", origin);
        dispatch_semaphore_signal(semaphore);
    }
     errorBlock:^(PNError *connectionError) {
							 PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
							 dispatch_semaphore_signal(semaphore);
							 XCTFail(@"connectionError %@", connectionError);
                         }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)subscribeOnChannels:(NSArray*)pnChannels withPresenceEvent:(BOOL)presenceEvent {
	NSLog(@"subscribeOnChannels");
	__block BOOL isCompletionBlockCalled = NO;
//	[PubNub subscribeOnChannel: pnChannels[0] withCompletionHandlingBlock: ^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
    [PubNub subscribeOnChannel:pnChannels[0] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
		 NSLog(@"subscribeOnChannels end");
		 isCompletionBlockCalled = YES;
		 XCTAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
		 if( pnChannels.count != channels.count ) {
			 NSLog( @"pnChannels.count \n%@\n%@", pnChannels, channels);
		 }
		 XCTAssertEqualObjects( @(pnChannels.count), @(channels.count), @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
	 }];
	NSLog(@"subscribeOnChannels runloop");
	for( int i=0; i<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 && isCompletionBlockCalled == NO; i++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isCompletionBlockCalled, @"completion block not called");
}

- (void)unsubscribeOnChannels:(NSArray*)pnChannels withPresenceEvent:(BOOL)presenceEvent {
	NSLog(@"unsubscribeOnChannels");
	__block BOOL isCompletionBlockCalled = NO;

	[PubNub unsubscribeFromChannels:pnChannels withCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError) {
		 NSLog(@"unsubscribeOnChannels end");
		 isCompletionBlockCalled = YES;
		 XCTAssertNil( unsubscribeError, @"unsubscribeError %@", unsubscribeError);
		 XCTAssertEqualObjects( @(pnChannels.count), @(channels.count), @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
	 }];
	NSLog(@"unsubscribeOnChannels runloop");
	for( int i=0; i<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		isCompletionBlockCalled == NO; i++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( isCompletionBlockCalled, @"completion block not called");
}

- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {
	NSLog(@"pubnubClient didReceivePresenceEvent %@", event);
	if( event.type == PNPresenceEventJoin )
		joinNotificationCount++;
	if( event.type == PNPresenceEventLeave )
		leaveNotificationCount++;
	if( event.type == PNPresenceEventTimeout )
		timeoutDelegateCount++;
}

-(void)kPNClientDidReceivePresenceEventNotification:(NSNotification*)notification {
	NSLog(@"kPNClientDidReceivePresenceEventNotification %@", notification.object);
	PNPresenceEvent *event = (PNPresenceEvent*)notification.userInfo;
	if( event.type == PNPresenceEventJoin )
		joinDelegateCount++;
	if( event.type == PNPresenceEventLeave )
		leaveDelegateCount++;
	if( event.type == PNPresenceEventTimeout )
		timeoutNotificationCount++;
}

-(void)kPNClientSubscriptionDidCompleteNotification:(NSNotification*)notificaton {
	NSLog(@"kPNClientSubscriptionDidCompleteNotification %@", notificaton);
}

- (void)test10SubscribeOnChannels {
	joinDelegateCount = 0;
	leaveDelegateCount = 0;
	timeoutDelegateCount = 0;
	joinNotificationCount = 0;
	leaveNotificationCount = 0;
	timeoutNotificationCount = 0;
	didReceiveMessageCount = 0;
	for( int i=0; i<channelNames.count; i++ ) {
		[self subscribeOnChannels: @[[PNChannel channelWithName: channelNames[i] shouldObservePresence: YES]] withPresenceEvent: YES];
		[PubNub sendMessage: @"message" toChannel: [PNChannel channelWithName: channelNames[i]] ];
	}
	for( int i=0; i<10; i++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( didReceiveMessageCount == channelNames.count, @"");

	XCTAssertTrue( joinDelegateCount == channelNames.count, @"joinDelegateCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);
	XCTAssertTrue( leaveDelegateCount == 0, @"leaveDelegateCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);

	XCTAssertTrue( joinNotificationCount == channelNames.count, @"joinNotificationCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);
	XCTAssertTrue( leaveNotificationCount == 0, @"leaveNotificationCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);

	XCTAssertTrue( timeoutDelegateCount == 0, @"timeoutCount %d", timeoutDelegateCount);
	XCTAssertTrue( timeoutNotificationCount == 0, @"timeoutCount %d", timeoutDelegateCount);


	joinDelegateCount = 0;
	leaveDelegateCount = 0;
	joinNotificationCount = 0;
	leaveNotificationCount = 0;
	timeoutDelegateCount = 0;
	for( int i=0; i<channelNames.count; i++ )
		[self unsubscribeOnChannels: [PNChannel channelsWithNames: @[channelNames[i]]] withPresenceEvent: YES];
	for( int i=0; i<10; i++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	XCTAssertTrue( joinDelegateCount == 0, @"joinDelegateCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);
	XCTAssertTrue( leaveDelegateCount == 0, @"leaveDelegateCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);

	XCTAssertTrue( joinNotificationCount == 0, @"joinNotificationCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);
	XCTAssertTrue( leaveNotificationCount == 0, @"leaveNotificationCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);

	XCTAssertTrue( timeoutDelegateCount == 0, @"timeoutCount %d", timeoutDelegateCount);
//	[self unsubscribeOnChannels: pnChannels2 withPresenceEvent: NO];
}

- (void)handleClientDidReceiveMessage:(NSNotification *)notification {
    PNLog(PNLogGeneralLevel, self, @"NSNotification handleClientDidReceiveMessage: %@", notification);
	didReceiveMessageCount++;
}


@end
