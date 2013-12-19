//
//  ChannelLimitTest.m
//  pubnub
//
//  Created by Valentin Tuller on 11/20/13.
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

@interface ChannelLimitTest : SenTestCase <PNDelegate> {
	int clientUnsubscriptionDidCompleteNotificationCount;
}

@end

@implementation ChannelLimitTest


-(void)resetConnection {
	[PubNub resetClient];
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];

		[PubNub connectWithSuccessBlock:^(NSString *origin) {

			NSLog(@"PubNub client connected to: %@", origin);
			dispatch_semaphore_signal(semaphore);
		}
							 errorBlock:^(PNError *connectionError) {
								 NSLog(@"connectionError %@", connectionError);
								 dispatch_semaphore_signal(semaphore);
							 }];
	});
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
}

-(void)sendMessage:(NSString*)message toChannelWithName:(NSString*)channelName
{
	PNChannel *channel = [PNChannel channelWithName: channelName];
	NSDate *start = [NSDate date];
	__block BOOL isCompletionBlockCalled = NO;
	[PubNub sendMessage: message toChannel: channel withCompletionBlock:^(PNMessageState messageSendingState, id data)
	 {
		 if( messageSendingState == PNMessageSending )
			 return;
		 NSTimeInterval interval = -[start timeIntervalSinceNow];
		 NSLog(@"sendMessage interval %f", interval);
		 isCompletionBlockCalled = YES;
		 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %d instead of %d", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

		 STAssertFalse(messageSendingState==PNMessageSendingError, @"messageSendingState==PNMessageSendingError %@", data);
	 }];

	for( int j=0; /*j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1*/ isCompletionBlockCalled == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
}

- (void)test60SubscribeOnChannelsByTurns {
	[self resetConnection];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientUnsubscriptionDidCompleteNotification:)
							   name:kPNClientUnsubscriptionDidCompleteNotification
							 object:nil];

	NSMutableArray *arr = [NSMutableArray array];
	int i=0;
	for( ; i<20; i++ ) {
		NSString *channelName = [NSString stringWithFormat: @"%@ %d", [NSDate date], i];
		[arr addObject: channelName];
	}

	__block NSDate *start = [NSDate date];
	[PubNub subscribeOnChannels: [PNChannel channelsWithNames: arr]
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 [[TestSemaphor sharedInstance] lift:@"arr"];
		 NSTimeInterval interval = -[start timeIntervalSinceNow];
		 NSLog(@"subscribed arr %f, error %@", interval, subscriptionError);
		 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %d instead of %d", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

		 STAssertNil( subscriptionError, @"arr subscriptionError %@", subscriptionError);
	 }];
	STAssertTrue([[TestSemaphor sharedInstance] waitForKey: @"arr" timeout: [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1], @"completion block not called, arr");


	__block int requestFinishedCount = 0;
	start = [NSDate date];
	NSString *message = [NSString stringWithFormat: @"%@", arr];
	message = [arr description];
	message = [message substringToIndex: 500];
	//	int lenght = message.length;
	message = [message stringByReplacingOccurrencesOfString:@"\"" withString: @"\\\""];
	NSLog(@"message:\n| %@ |", message);

	for( int i=0; i<arr.count; i++ ) {
		__block BOOL isCompletionBlockCalled = NO;

		[PubNub sendMessage: message toChannel: [PNChannel channelWithName: arr[i]]
		withCompletionBlock:^(PNMessageState messageSendingState, id data) {
			if( messageSendingState == PNMessageSending) {
				start = [NSDate date];
				return;
			}
			requestFinishedCount++;
			isCompletionBlockCalled = YES;
			NSTimeInterval interval = -[start timeIntervalSinceNow];
			NSLog( @"test50SendMessageTimeout, index %d, time %f, %@", i, interval, (messageSendingState==PNMessageSendingError) ? data : @"" );
			//			STAssertTrue( interval < [PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout, @"Timeout [PubNub sharedInstance].configuration.subscriptionRequestTimeout no correct, %f instead of %f", interval, [PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout);
			//			STAssertTrue(messageSendingState==PNMessageSent, @"messageSendingState==PNMessageSent %@", data);
		}];
	}
	for( int j=0; requestFinishedCount < arr.count; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	//	STAssertTrue(isCompletionBlockCalled, @"Completion block not called");
	//	STAssertTrue(delegateFailMessageSendCalled, @"delegate not called");

	//	return;
	for( ; i<10; i++ ) {
		NSString *channelName = [NSString stringWithFormat: @"%@ %d", [NSDate date], i];
		NSArray *arr = [PNChannel channelsWithNames: @[channelName]];
		NSDate *start = [NSDate date];
		NSLog(@"Start subscribe to channel %@", channelName);
		__block NSArray *subscribedChannels = nil;
		[PubNub subscribeOnChannels: arr
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
			 [[TestSemaphor sharedInstance] lift:channelName];
			 subscribedChannels = channels;
			 NSTimeInterval interval = -[start timeIntervalSinceNow];
			 NSLog(@"subscribed %f, %@", interval, subscriptionError);
			 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %d instead of %d", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

			 STAssertNil( subscriptionError, @"channel %@, \nsubscriptionError %@", channelName, subscriptionError);
		 }];
		STAssertTrue([[TestSemaphor sharedInstance] waitForKey: channelName timeout: [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1], @"completion block not called, %@", channelName);

		for( int j=0; j<subscribedChannels.count; j++ ) {
			if( [[subscribedChannels[j] name] isEqualToString: channelName] == YES ) {
				[self sendMessage: channelName toChannelWithName: channelName];
				break;
			}
		}
	}

	NSMutableArray *arrChannel = [NSMutableArray arrayWithArray: [PubNub subscribedChannels]];
	NSLog(@"[PubNub subscribedChannels] %@", [PubNub subscribedChannels]);
	for( int i=0; /*[PubNub subscribedChannels].count > 0*/ i < arrChannel.count; i++) {
		__block PNChannel *channel = arrChannel[i];
		__block int blockCount = 0;
		NSLog(@"start unsubscribeFromChannels %@", channel);
		clientUnsubscriptionDidCompleteNotificationCount = 0;
		[PubNub unsubscribeFromChannels: @[channel] withPresenceEvent:YES andCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError) {
			NSLog(@"unsubscribeFromChannels %@", channel);
			NSLog(@"block isSubscribedOnChannel %d", [PubNub isSubscribedOnChannel: channel]);
			STAssertNil( unsubscribeError, @"unsubscribeError %@", unsubscribeError);
			blockCount++;
		}];
		for( int j=0; j<8 /*isBlockCalled == 0 || clientUnsubscriptionDidCompleteNotificationCount == 0*/; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		STAssertTrue(clientUnsubscriptionDidCompleteNotificationCount>0, @"notification not called");
		STAssertFalse(clientUnsubscriptionDidCompleteNotificationCount>1, @"notification called repeatedly, %d", clientUnsubscriptionDidCompleteNotificationCount);
		STAssertTrue(blockCount>0, @"block not called");
		STAssertFalse(blockCount>1, @"block called repeatedly, %d", blockCount);
	}
}

-(void)kPNClientUnsubscriptionDidCompleteNotification:(NSNotification*)notification {
	NSLog(@"kPNClientUnsubscriptionDidCompleteNotification %@", notification.userInfo);
//	NSLog(@"isSubscribedOnChannel %d", [PubNub isSubscribedOnChannel: (PNChannel*)notification.userInfo]);
	clientUnsubscriptionDidCompleteNotificationCount++;
}

@end
