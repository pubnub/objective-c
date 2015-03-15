//
//  PNChannelConstructor.m
//  pubnub
//
//  Created by Valentin Tuller on 11/1/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface PNChannelConstructor : XCTestCase

@end

@implementation PNChannelConstructor

- (void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
    [super tearDown];
}

- (void)test10Connect
{
	[PubNub disconnect];
	//    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
	//	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: @"key"];
	////	//	configuration.autoReconnectClient = NO;
	//	[PubNub setConfiguration: configuration];

//	handleClientConnectionStateChange = NO;
	__block BOOL isMessageSended = NO;
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
		[PubNub connect];
		[PubNub subscribeOn:@[[PNChannel channelWithName:@"my-channel" shouldObservePresence:NO]]
	   withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error){

		   if (state == PNSubscriptionProcessSubscribedState) {

			   [PubNub subscribeOn:@[[PNChannel channelWithName:@"my-channel" shouldObservePresence:YES]]];

			   /*PNMessage *helloMessage = */[PubNub sendMessage:@"Hello PubNub"
													   toChannel: [PNChannel channelWithName:@"my-channel"]
											 withCompletionBlock:^(PNMessageState messageSendingState, id data)
											  {
//												  dispatch_semaphore_signal(semaphore);
												  if( messageSendingState == PNMessageSent )
													  isMessageSended = YES;
											  }];

//			   [PubNub sendMessage:@"Hi there" toChannel:[PNChannel channelWithName:@"my-channel"]];
		   }
	   }];
	});
	for( int i=0; i<100 && isMessageSended == NO; i++ )
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];

	XCTAssertTrue( isMessageSended, @"message not sended");
}

@end
