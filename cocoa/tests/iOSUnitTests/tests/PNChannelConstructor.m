//
//  PNChannelConstructor.m
//  pubnub
//
//  Created by Valentin Tuller on 11/1/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface PNChannelConstructor : SenTestCase

@end

@implementation PNChannelConstructor

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
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
		[PubNub subscribeOnChannel:[PNChannel channelWithName:@"my-channel" shouldObservePresence:NO]
	   withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error){

		   if (state == PNSubscriptionProcessSubscribedState) {

			   [PubNub subscribeOnChannel:[PNChannel channelWithName:@"my-channel" shouldObservePresence:YES]];

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

	STAssertTrue( isMessageSended, @"message not sended");
}

@end
