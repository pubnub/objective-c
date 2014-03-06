//
//  ClientIdentifier.m
//  pubnub
//
//  Created by Valentin Tuller on 11/28/13.
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
#import "Swizzler.h"
#import "PNConnection.h"

@interface ClientIdentifier : SenTestCase <PNDelegate> {
	BOOL _isDidSubscribeOnChannels;
}
@end

@implementation ClientIdentifier

- (void)setUp
{
    [super setUp];

	[PubNub disconnect];

	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		[PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey: @"pub-c-bb4a4d9b-21b1-40e8-a30b-04a22f5ef154"  subscribeKey: @"sub-c-6b43405c-3694-11e3-a5ee-02ee2ddab7fe" secretKey: @"sec-c-ZmNlNzczNTEtOGUwNS00MmRjLWFkMjQtMjJiOTA2MjY2YjI5"]];

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

    semaphore = dispatch_semaphore_create(0);
	[PubNub subscribeOnChannels: [PNChannel channelsWithNames: @[@"channel"]]
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 dispatch_semaphore_signal(semaphore);
		 STAssertNil(subscriptionError, @"subscribeOnChannels subscriptionError %@", subscriptionError);
	 }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

- (void)tearDown {
	[NSThread sleepForTimeInterval:1.0];
	[super tearDown];
}

-(void)test10SendMessage {
	for( int i=0; i<10; i++) {
		_isDidSubscribeOnChannels = NO;
		[PubNub setClientIdentifier: [NSString stringWithFormat: @"identifier %@, %d", [NSDate date], i] shouldCatchup: YES];
		for( int j=0; _isDidSubscribeOnChannels == NO; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

		dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
		[PubNub sendMessage: @"message" toChannel: [PNChannel channelWithName: @"channel"]
			withCompletionBlock:^(PNMessageState messageSendingState, id data) {
				if( messageSendingState == PNMessageSending )
					return;
				dispatch_semaphore_signal(semaphore);
				STAssertTrue(messageSendingState == PNMessageSent, @"message error %@", data);
		 }];

		while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	}
}

- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
	 NSLog( @"PubNub client successfully subscribed on channels: %@", channels);
	_isDidSubscribeOnChannels = YES;
}


@end