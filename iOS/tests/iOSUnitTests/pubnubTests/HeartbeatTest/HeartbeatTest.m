//
//  HeartbeatTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PubNub.h"
#import "PNConfiguration.h"
#import "PNConstants.h"

@interface HeartbeatTest : SenTestCase <PNDelegate> {
	NSDate *dateLastPresence;
	int presenceInterval;
	int countPresence;
}

@end

@implementation HeartbeatTest

-(void)tearDown {
    [super tearDown];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)presenceEvent:(NSNotification*)notification {
	NSLog(@"presenceEvent %@", notification);
	NSTimeInterval interval = -[dateLastPresence timeIntervalSinceNow];
	if( interval < 1 )
		return;
	STAssertTrue( interval > presenceInterval-1 && interval < presenceInterval+2, @"interval %f, presenceInterval %d", interval, presenceInterval);
	NSLog(@"presenceEvent interval %f", interval);
	countPresence++;
	dateLastPresence = [NSDate date];
}

- (void)test10Connect {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presenceEvent:) name: @"presenceEvent" object:nil];
	presenceInterval = /*kPNHeartbeatRequestTimeoutOffset + */10;
	[self check];

	presenceInterval = 20;
	[self check];

	presenceInterval = 30;
	[self check];
}

-(void)check {
	[PubNub disconnect];

	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"presence-beta.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil authorizationKey: nil];
		configuration.presenceHeartbeatTimeout = presenceInterval*2;
		configuration.presenceHeartbeatInterval = presenceInterval;
		[PubNub setConfiguration: configuration];

		[PubNub connectWithSuccessBlock:^(NSString *origin) {
			[PubNub subscribeOnChannels: [PNChannel channelsWithNames:@[@"channel"]] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
				 dispatch_semaphore_signal(semaphore);
				dateLastPresence = [NSDate date];
				countPresence = 0;
			 }];
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
	for( int j=0; j<60; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( countPresence >= 2, @"countPresence %d (interval %d)", countPresence, presenceInterval);
}

@end
