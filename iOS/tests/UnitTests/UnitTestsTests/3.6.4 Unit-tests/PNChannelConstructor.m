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


- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [PubNub disconnect];
}

- (void)tearDown {
    [PubNub disconnect];
    
    [super tearDown];
}

- (void)test10Connect
{
	[PubNub disconnect];
    
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

			   [PubNub sendMessage:@"Hello PubNub"
													   toChannel: [PNChannel channelWithName:@"my-channel"]
											 withCompletionBlock:^(PNMessageState messageSendingState, id data)
											  {
												  if( messageSendingState == PNMessageSent )
													  isMessageSended = YES;
											  }];

		   }
	   }];
	});
	for( int i=0; i<100 && isMessageSended == NO; i++ )
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];

	XCTAssertTrue( isMessageSended, @"message not sended");
}

@end
