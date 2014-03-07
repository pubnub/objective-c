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
	BOOL _isError;
}

@end

@implementation Configuration

- (void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
	[super tearDown];
}

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
	configuration.useSecureConnection = NO;
	[configurations addObject: configuration];

	configuration = [PNConfiguration configurationForOrigin:@"punsub.pubnub.com"
												 publishKey:@"aasd sad ads"
											   subscribeKey:@"asdfadas asd"
												  secretKey:nil
												  cipherKey:@" asdashd asd fsdkl faskd asdkf kasldf "];
	configuration.useSecureConnection = YES;
	[configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"punsub1.pubnub.com"
												 publishKey:@"a a as a "
											   subscribeKey:@"a a as a "
												  secretKey:nil
												  cipherKey:@"chaos.pubnub.com"];
	configuration.useSecureConnection = NO;
	[configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
												 publishKey:@"ss s s sdgdaf"
											   subscribeKey:@"aaaaasdfaaaa"
												  secretKey:nil
												  cipherKey:@"enigma"];
	configuration.useSecureConnection = YES;
	[configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"pubsub2.pubnub.com"
												 publishKey:@"enigma"
											   subscribeKey:@"enigma"
												  secretKey:nil
												  cipherKey:@"chaos.pubnub.com"];
	configuration.useSecureConnection = NO;
	[configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"google.com.ua"
												 publishKey:@"enigma"
											   subscribeKey:@"enigma"
												  secretKey:nil
												  cipherKey:@"chaos.pubnub.com"];
	configuration.useSecureConnection = YES;
	[configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"google.com"
												 publishKey:@"enigma"
											   subscribeKey:@"enigma"
												  secretKey:nil
												  cipherKey:@"chaos.pubnub.com"];
	configuration.useSecureConnection = NO;
	[configurations addObject: configuration];
	////
	configuration = [PNConfiguration configurationForOrigin:@"mail.ru"
												 publishKey:@"enigma"
											   subscribeKey:@"enigma"
												  secretKey:nil
												  cipherKey:@"chaos.pubnub.com"];
	configuration.useSecureConnection = YES;
	[configurations addObject: configuration];

	[configurations addObject: [PNConfiguration defaultConfiguration]];
	//	////
	//	configuration = [PNConfiguration configurationForOrigin:@"adgads a dfa fasdfasdfaasfadsf"
	//												 publishKey:@"asdf sadhd dhajasdh"
	//											   subscribeKey:@"enigma"
	//												  secretKey:nil
	//												  cipherKey:@"enigma"];
	//	[configurations addObject: configuration];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientErrorNotification:)
							   name:kPNClientErrorNotification
							 object:nil];
}

-(void)kPNClientErrorNotification:(NSNotification*)notification {
	NSLog(@"kPNClientErrorNotification %@", notification);
	_isError = YES;
}

- (void)test10Connect {
	[PubNub resetClient];
	NSLog(@"end reset");
	for( int j=0; j<5; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

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

		_isError = NO;
		BOOL isConnect = [self connectWithConfiguration: configurations[i]];
		if( isConnect == NO || _isError == YES )
			continue;
		STAssertTrue( _isDidConnectToOrigin == YES || _isConnectionDidFailWithError == YES, @"not connect");
		NSLog(@"configurations\n%@\n|\n%@", configurations[i], [PubNub sharedInstance].configuration );
		if( [PubNub sharedInstance].configuration == nil )
			continue;
//		if( [configurations[i] isEqual: [PubNub sharedInstance].configuration] == NO ) {
//			NSLog(@"shouldUseSecureConnection %d, %d", [configurations[i] shouldUseSecureConnection], [[PubNub sharedInstance].configuration shouldUseSecureConnection]);
//			BOOL isEqual = [configurations[i] isEqual: [PubNub sharedInstance].configuration];
//			NSLog(@"shouldUseSecureConnection %d, %d", [configurations[i] shouldUseSecureConnection], [[PubNub sharedInstance].configuration shouldUseSecureConnection]);
//		}
		STAssertTrue( [configurations[i] isEqual: [PubNub sharedInstance].configuration], @"configurations are not equals, %@\n%@", configurations[i], [PubNub sharedInstance].configuration );

		__block BOOL isCompletionBlockCalled = NO;
		__block NSDate *start = [NSDate date];
		[PubNub subscribeOnChannels: [PNChannel channelsWithNames: @[@"channel"]]
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) 		 {
			 isCompletionBlockCalled = YES;
			NSTimeInterval interval = -[start timeIntervalSinceNow];
			PNLog(PNLogGeneralLevel, self, @"subscribeOnChannels %f", interval);
			STAssertTrue( interval < [PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout+1, @"timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout);
			 if( error != nil )
				 STAssertTrue( error.code == kPNInvalidSubscribeOrPublishKeyError || error.code == kPNAPIAccessForbiddenError, @"invalid error %@", error);
		 }];
		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+30 &&
			isCompletionBlockCalled == NO; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		STAssertTrue( isCompletionBlockCalled, @"block not called" );

		if( isCompletionBlockCalled == NO )
			continue;

		isCompletionBlockCalled = NO;

		[PubNub sendMessage: @"my message" toChannel: [PNChannel channelWithName: @"channel"]
		withCompletionBlock:^(PNMessageState messageSendingState, id data) {
			 if( messageSendingState == PNMessageSending )
				 return;
//			 dispatch_semaphore_signal(semaphore);
			 PNError *error = data;
			if( error != nil )
				STAssertTrue( error.code == kPNInvalidSubscribeOrPublishKeyError || error.code == kPNAPIAccessForbiddenError, @"invalid error %@", error);
		 }];
		for( int i=0; i<10; i++ )
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	}
}

- (void)pubnubClient:(PubNub *)client error:(PNError *)error {
	NSLog(@"pubnubClient error %@", error);
	_isError = YES;
}

//- (void)connectWithConfiguration:(PNConfiguration*)configuration
//=======
//			 isCompletionBlockCalled = YES;
//			 PNError *error = data;
//			 if( error != nil )
//				 STAssertTrue( error.code == kPNInvalidSubscribeOrPublishKeyError || error.code == kPNAPIAccessForbiddenError, @"invalid error %@", error);
//		 }];
//		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
//			isCompletionBlockCalled == NO; j++ )
//			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
//		STAssertTrue( isCompletionBlockCalled, @"block not called" );
//	}
//}

- (BOOL)connectWithConfiguration:(PNConfiguration*)configuration {
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		[PubNub setDelegate:self];
		[PubNub setConfiguration: configuration];
	});
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 /*&&
		_isDidConnectToOrigin == NO && _isConnectionDidFailWithError == NO*/; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	return _isDidConnectToOrigin;

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
