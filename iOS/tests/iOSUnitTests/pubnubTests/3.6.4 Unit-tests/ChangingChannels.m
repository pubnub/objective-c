//
//  ChangingChannels.m
//  pubnub
//
//  Created by Valentin Tuller on 10/21/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

/* Test descripition:
 This test should work only when Presence and Access Manager features
 enabled for developer account.
 
 It should check following scenario:
 - connect to pubsub; For configuration we setup 20 sec as a presence heartbeat timeout;
 - grant all access rights;
 - subscribe to channes with observing events
 - check that we receive two Presence events: join and timeout
 */


#import <SenTestingKit/SenTestingKit.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "GCDWrapper.h"

static NSUInteger const kTestTimout = 60;
static NSUInteger const kTestPresenceHeartbeatTimeout = 20;

@interface ChangingChannels : SenTestCase <PNDelegate>

@end

@implementation ChangingChannels

- (void)setUp
{
    [super setUp];
    [PubNub setDelegate:self];
}

- (void)tearDown {
	[super tearDown];
}

- (void)test10Connect {
	[PubNub disconnect];
    
    // unknown delay
    
    // 1. Connect to pubnub
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
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
    
    

	BOOL isConnect = [[PubNub sharedInstance] isConnected];
	STAssertTrue( isConnect, @"not connected");

	[self t20SubscribeOnChannelsByTurns];
}

-(void)t20SubscribeOnChannelsByTurns {
	for( int i = 0; i<90; i++ ) {
		//		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		__block BOOL isCompletionBlockCalled = NO;
		NSString *channelName = [NSString stringWithFormat: @"%@ %d", [NSDate date], i];
		NSArray *arr = [PNChannel channelsWithNames: @[channelName]];
		NSDate *start = [NSDate date];
		NSLog(@"Start subscribe to channel %@", channelName);
		[PubNub subscribeOnChannels: arr
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
			 //			 dispatch_semaphore_signal(semaphore);
			 isCompletionBlockCalled = YES;
			 NSTimeInterval interval = -[start timeIntervalSinceNow];
			 NSLog(@"subscribed %f, %@, %@", interval, channels, subscriptionError);
			 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %d instead of %d", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

			 if( subscriptionError == nil ) {
				 STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
				 BOOL isSubscribed = NO;
				 for( int j=0; j<channels.count; j++ ) {
					 if( [[channels[j] name] isEqualToString: channelName] == YES ) {
						 isSubscribed = YES;
						 break;
					 }
				 }
				 STAssertTrue( isSubscribed == YES, @"Channel no subecribed");
			 }
		 }];
		// Run loop
		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
			isCompletionBlockCalled == NO; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		BOOL isConnect = [PubNub sharedInstance].isConnected;
		if( isConnect == YES )
			STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	}
}


@end
