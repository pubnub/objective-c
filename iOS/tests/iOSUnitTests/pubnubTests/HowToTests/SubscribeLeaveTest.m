//
//  SubscribeLeaveTest.m
//  pubnub
//
//  Created by Valentin Tuller on 3/4/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNNotifications.h"

@interface SubscribeLeaveTest : SenTestCase <PNDelegate> {
	int leaveDelegateCount;
	int joinDelegateCount;
	int leaveNotificationCount;
	int joinNotificationCount;
	int timeoutCount;
	NSMutableArray *channelNames;
}

@end

@implementation SubscribeLeaveTest

- (void)tearDown {
	[NSThread sleepForTimeInterval:1.0];
    [super tearDown];
}

- (void)setUp {
    [super setUp];
	channelNames = [NSMutableArray array];
	for( int i=0; i<5; i++ )
		[channelNames addObject: [NSString stringWithFormat: @"ch %@ %d", [NSDate date], i]];

//	[PubNub resetClient];
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


    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"presence-beta.pubnub.com" publishKey:@"pub-c-c9b0fe21-4ae1-433b-b766-62667cee65ef" subscribeKey:@"sub-c-d91ee366-9dbd-11e3-a759-02ee2ddab7fe" secretKey: @"sec-c-ZDUxZGEyNmItZjY4Ny00MjJmLWE0MjQtZTQyMDM0NTY2MDVk" cipherKey: @"key"];
	[PubNub setConfiguration: configuration];

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
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)subscribeOnChannels:(NSArray*)pnChannels withPresenceEvent:(BOOL)presenceEvent {
	//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	NSLog(@"subscribeOnChannels");
	__block BOOL isCompletionBlockCalled = NO;
	[PubNub subscribeOnChannels: pnChannels withPresenceEvent: presenceEvent andCompletionHandlingBlock: ^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
		 NSLog(@"subscribeOnChannels end");
		 //		 dispatch_semaphore_signal(semaphore);
		 isCompletionBlockCalled = YES;
		 STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
		 if( pnChannels.count != channels.count ) {
			 NSLog( @"pnChannels.count \n%@\n%@", pnChannels, channels);
		 }
		 STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
	 }];
    // Run loop
	NSLog(@"subscribeOnChannels runloop");
	for( int i=0; i<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 && isCompletionBlockCalled == NO; i++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
}

- (void)unsubscribeOnChannels:(NSArray*)pnChannels withPresenceEvent:(BOOL)presenceEvent {
	NSLog(@"unsubscribeOnChannels");
	__block BOOL isCompletionBlockCalled = NO;

	[PubNub unsubscribeFromChannels:pnChannels withPresenceEvent:YES  andCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError) {
		 NSLog(@"unsubscribeOnChannels end");
		 isCompletionBlockCalled = YES;
		 STAssertNil( unsubscribeError, @"unsubscribeError %@", unsubscribeError);
		 STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
	 }];
    // Run loop
	NSLog(@"unsubscribeOnChannels runloop");
	for( int i=0; i<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		isCompletionBlockCalled == NO; i++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
}

- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {
	NSLog(@"pubnubClient didReceivePresenceEvent %@", event);
	if( event.type == PNPresenceEventJoin )
		joinDelegateCount++;
	if( event.type == PNPresenceEventLeave )
		leaveDelegateCount++;
	if( event.type == PNPresenceEventTimeout )
		timeoutCount++;
}

-(void)kPNClientDidReceivePresenceEventNotification:(NSNotification*)notification {
	NSLog(@"kPNClientDidReceivePresenceEventNotification %@", notification.object);
}

-(void)kPNClientSubscriptionDidCompleteNotification:(NSNotification*)notificaton {
	NSLog(@"kPNClientSubscriptionDidCompleteNotification %@", notificaton);
}

- (void)test10SubscribeOnChannels {
	joinDelegateCount = 0;
	leaveDelegateCount = 0;
	joinNotificationCount = 0;
	leaveNotificationCount = 0;
	timeoutCount = 0;
	for( int i=0; i<channelNames.count; i++ )
		[self subscribeOnChannels: [PNChannel channelsWithNames: @[channelNames[i]]] withPresenceEvent: YES];
	STAssertTrue( joinDelegateCount == channelNames.count, @"joinDelegateCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);
	STAssertTrue( leaveDelegateCount == 0, @"leaveDelegateCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);

	STAssertTrue( joinNotificationCount == channelNames.count, @"joinNotificationCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);
	STAssertTrue( leaveNotificationCount == 0, @"leaveNotificationCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);

	STAssertTrue( timeoutCount == 0, @"timeoutCount %d", timeoutCount);


	joinDelegateCount = 0;
	leaveDelegateCount = 0;
	joinNotificationCount = 0;
	leaveNotificationCount = 0;
	timeoutCount = 0;
	for( int i=0; i<channelNames.count; i++ )
		[self unsubscribeOnChannels: [PNChannel channelsWithNames: @[channelNames[i]]] withPresenceEvent: YES];
	STAssertTrue( joinDelegateCount == 0, @"joinDelegateCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);
	STAssertTrue( leaveDelegateCount == channelNames.count, @"leaveDelegateCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);

	STAssertTrue( joinNotificationCount == 0, @"joinNotificationCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);
	STAssertTrue( leaveNotificationCount == channelNames.count, @"leaveNotificationCount %d, channelNames.count %d", joinNotificationCount, channelNames.count);

	STAssertTrue( timeoutCount == 0, @"timeoutCount %d", timeoutCount);
//	[self unsubscribeOnChannels: pnChannels2 withPresenceEvent: NO];
}

@end
