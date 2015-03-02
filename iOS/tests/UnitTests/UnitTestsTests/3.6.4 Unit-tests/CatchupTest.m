//
//  CatchupTest.m
//  pubnub
//
//  Created by Valentin Tuller on 10/21/13.
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
#import "PNNotifications.h"


@interface CatchupTest : XCTestCase <PNDelegate> {
	NSArray *pnChannels;
	BOOL isPNClientDidReceivePresenceEventNotification;
	BOOL isHandleClientPresenceObservationEnablingProcess;
}

@end

@implementation CatchupTest

- (void)tearDown {
	[super tearDown];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUp
{
    [super setUp];
    
    [PubNub setDelegate:self];
	pnChannels = [PNChannel channelsWithNames:@[[NSString stringWithFormat: @"%@", [NSDate date]]]];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

	[notificationCenter addObserver:self
						   selector:@selector(handleClientPresenceObservationEnablingProcess:)
							   name:kPNClientPresenceEnablingDidCompleteNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientPresenceObservationEnablingProcess:)
							   name:kPNClientPresenceEnablingDidFailNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientDidReceivePresenceEvent:)
							   name:kPNClientDidReceivePresenceEventNotification
							 object:nil];

}

- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification {
    NSLog(@"NSNotification handleClientDidReceivePresenceEvent: %@", notification);
	isPNClientDidReceivePresenceEventNotification = YES;
}

- (void)handleClientPresenceObservationEnablingProcess:(NSNotification *)notification {
    NSLog(@"NSNotification handleClientPresenceObservationEnablingProcess: %@", notification);
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
		PNConfiguration *configuration = [PNConfiguration defaultTestConfiguration];
		[PubNub setConfiguration:configuration];

		[PubNub connectWithSuccessBlock:^(NSString *origin) {

			NSLog(@"\n\n\n\n\n\n\n{BLOCK} PubNub client connected to: %@", origin);
			dispatch_semaphore_signal(semaphore);
		}
							 errorBlock:^(PNError *connectionError) {
								 NSLog(@"connectionError %@", connectionError);
								 dispatch_semaphore_signal(semaphore);
								 XCTFail(@"connectionError %@", connectionError);
							 }];
	});
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];


    semaphore = dispatch_semaphore_create(0);
	[PubNub subscribeOn: pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 dispatch_semaphore_signal(semaphore);
		 XCTAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
		 XCTAssertEqualObjects( @(pnChannels.count), @(channels.count), @"pnChannels.count %lu, channels.count %lu", (unsigned long)pnChannels.count, (unsigned long)channels.count);
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
		XCTAssertFalse( isPNClientDidReceivePresenceEventNotification, @"notification DidReceivePresence must should not come");
		XCTAssertFalse( isHandleClientPresenceObservationEnablingProcess, @"notification HandleClientPresence must should not come");
		NSString *newIdentifier = [PubNub clientIdentifier];
		XCTAssertEqualObjects( clientIdentifier, newIdentifier, @"identifires must be equla");
    });
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}


@end
