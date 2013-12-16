//
//  Configuration.m
//  pubnub
//
//  Created by Valentin Tuller on 11/13/13.
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

@interface Configuration : SenTestCase <PNDelegate> {
	NSMutableArray *configurations;
	BOOL _isDidConnectToOrigin;
	BOOL _isConnectionDidFailWithError;
}

@end

@implementation Configuration

- (void)setUp
{
    [super setUp];

	PNConfiguration *configuration = nil;
	configurations = [NSMutableArray array];

	configuration = [PNConfiguration configurationForOrigin:@"punsub123.pubnub.com"
												 publishKey:@"sdfga"
											   subscribeKey:@"sadasfsad"
												  secretKey:nil
												  cipherKey:@"my_key"];
	[configurations addObject: configuration];

	configuration = [PNConfiguration configurationForOrigin:@"punsub.pubnub.com"
												 publishKey:@"aasd sad ads"
											   subscribeKey:@"asdfadas asd"
												  secretKey:nil
												  cipherKey:@" asdashd asd fsdkl faskd asdkf kasldf "];
	[configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"punsub1.pubnub.com"
												 publishKey:@"a a as a "
											   subscribeKey:@"a a as a "
												  secretKey:nil
												  cipherKey:@"chaos.pubnub.com"];
	[configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
												 publishKey:@"ss s s sdgdaf"
											   subscribeKey:@"aaaaasdfaaaa"
												  secretKey:nil
												  cipherKey:@"enigma"];
	[configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"pubsub2.pubnub.com"
												 publishKey:@"enigma"
											   subscribeKey:@"enigma"
												  secretKey:nil
												  cipherKey:@"chaos.pubnub.com"];
	[configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"google.com.ua"
												 publishKey:@"enigma"
											   subscribeKey:@"enigma"
												  secretKey:nil
												  cipherKey:@"chaos.pubnub.com"];
	[configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"google.com"
												 publishKey:@"enigma"
											   subscribeKey:@"enigma"
												  secretKey:nil
												  cipherKey:@"chaos.pubnub.com"];
	[configurations addObject: configuration];
	//	////
	configuration = [PNConfiguration configurationForOrigin:@"mail.ru"
												 publishKey:@"enigma"
											   subscribeKey:@"enigma"
												  secretKey:nil
												  cipherKey:@"chaos.pubnub.com"];
	[configurations addObject: configuration];

	[configurations addObject: [PNConfiguration defaultConfiguration]];
	//	////
	//	configuration = [PNConfiguration configurationForOrigin:@"adgads a dfa fasdfasdfaasfadsf"
	//												 publishKey:@"asdf sadhd dhajasdh"
	//											   subscribeKey:@"enigma"
	//												  secretKey:nil
	//												  cipherKey:@"enigma"];
	//	[configurations addObject: configuration];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)test10Connect
{
	[PubNub disconnect];

	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		//		[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];
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
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];

	[self t20Cofiguration];
}

- (void)t20Cofiguration {
	for( int i=0; i<configurations.count; i++ ) {
		_isDidConnectToOrigin = NO;
		_isConnectionDidFailWithError = NO;

		if( [configurations[i] isEqual:[PubNub sharedInstance].configuration] == YES )
			continue;

		BOOL isConnect = [self connectWithConfiguration: configurations[i]];
		if( isConnect == NO )
			continue;
		STAssertTrue( _isDidConnectToOrigin == YES || _isConnectionDidFailWithError == YES, @"not connect");
		STAssertTrue( [configurations[i] isEqual: [PubNub sharedInstance].configuration ], @"configurations are not equals" );

		__block BOOL isCompletionBlockCalled = NO;
		[PubNub subscribeOnChannels: [PNChannel channelsWithNames: @[@"channel"]]
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
			 isCompletionBlockCalled = YES;
			 STAssertNil(subscriptionError, @"subscribeOnChannels subscriptionError %@", subscriptionError);
		 }];
		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
			isCompletionBlockCalled == NO; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		STAssertTrue( isCompletionBlockCalled, @"block not called" );

		if( isCompletionBlockCalled == NO )
			continue;

		isCompletionBlockCalled = NO;
		[PubNub sendMessage: @"my message" toChannel: [PNChannel channelWithName: @"channel"]
		withCompletionBlock:^(PNMessageState messageSendingState, id data)
		 {
			 if( messageSendingState == PNMessageSending )
				 return;
			 isCompletionBlockCalled = YES;
			 STAssertTrue( messageSendingState == PNMessageSent, @"sendMessage error %@", data);
		 }];
		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
			isCompletionBlockCalled == NO; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		STAssertTrue( isCompletionBlockCalled, @"block not called" );
	}
}

- (BOOL)connectWithConfiguration:(PNConfiguration*)configuration
{
	__block BOOL isCompletionBlockCalled = NO;
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		isCompletionBlockCalled = YES;
		[PubNub setDelegate:self];
		[PubNub setConfiguration: configuration];
	});
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		_isDidConnectToOrigin == NO && _isConnectionDidFailWithError == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"block not called" );
	return isCompletionBlockCalled;
}

-(void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
	NSLog(@"didConnectToOrigin %@", origin);
	_isDidConnectToOrigin = YES;
}

-(void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
	NSLog(@"connectionDidFailWithError %@", error);
	_isConnectionDidFailWithError = YES;
}


@end
