
//
//  ApnsToken.m
//  pubnub
//
//  Created by Valentin Tuller on 11/4/13.
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

@interface ApnsToken : SenTestCase <PNDelegate>{
	NSArray *pnChannels;
	BOOL pNClientPushNotificationEnableDidCompleteNotification;
	BOOL pNClientPushNotificationEnableDidFailNotification;

	BOOL pNClientPushNotificationDisableDidCompleteNotification;
	BOOL pNClientPushNotificationDisableDidFailNotification;
}

@end

@implementation ApnsToken

- (void)setUp
{
    [super setUp];
    [PubNub setDelegate:self];
	pnChannels = [PNChannel channelsWithNames:@[@"iosdev", @"andoirddev", @"wpdev", @"ubuntudev", @"1"]];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(kPNClientPushNotificationEnableDidCompleteNotification:)
												 name:kPNClientPushNotificationEnableDidCompleteNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(kPNClientPushNotificationEnableDidFailNotification:)
												 name:kPNClientPushNotificationEnableDidFailNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(kPNClientPushNotificationDisableDidCompleteNotification:)
												 name:kPNClientPushNotificationDisableDidCompleteNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(kPNClientPushNotificationDisableDidFailNotification:)
												 name:kPNClientPushNotificationDisableDidFailNotification
											   object:nil];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

//////////////////////////////////////////////////////////////////
- (void)kPNClientPushNotificationEnableDidCompleteNotification:(NSNotification *)__unused notification {
	NSLog(@"kPNClientPushNotificationEnableDidCompleteNotification");
	pNClientPushNotificationEnableDidCompleteNotification = YES;
}

- (void)kPNClientPushNotificationEnableDidFailNotification:(NSNotification *)__unused notification {
	NSLog(@"kPNClientPushNotificationEnableDidFailNotification");
	pNClientPushNotificationEnableDidFailNotification = YES;
}
//////////////////////
- (void)kPNClientPushNotificationDisableDidCompleteNotification:(NSNotification *)__unused notification {
	NSLog(@"kPNClientPushNotificationDisableDidCompleteNotification");
	pNClientPushNotificationDisableDidCompleteNotification = YES;
}

- (void)kPNClientPushNotificationDisableDidFailNotification:(NSNotification *)__unused notification {
	NSLog(@"kPNClientPushNotificationDisableDidFailNotification");
	pNClientPushNotificationDisableDidFailNotification = YES;
}
//////////////////////////////////////////////////////////////////

- (void)test10Connect
{
	[PubNub disconnect];

	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		//		[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];
		PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"pub-c-bb4a4d9b-21b1-40e8-a30b-04a22f5ef154" subscribeKey:@"sub-c-6b43405c-3694-11e3-a5ee-02ee2ddab7fe" secretKey: @"sec-c-ZmNlNzczNTEtOGUwNS00MmRjLWFkMjQtMjJiOTA2MjY2YjI5" cipherKey: nil];
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
	[self grantAllAccessRightsForApplicationAtPeriod: 15];
}

-(void)grantAllAccessRightsForApplicationAtPeriod:(NSUInteger)accessPeriodDuration {
	[PubNub grantAllAccessRightsForApplicationAtPeriod: accessPeriodDuration andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		NSLog(@"grantAllAccessRightsForApplicationAtPeriod ");
	}];
	for( int j=0; j<10; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
}

- (void)test20SubscribeOnChannels
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	[PubNub subscribeOnChannels: pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 dispatch_semaphore_signal(semaphore);
	 }];
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

-(void)test30EnablePushNotificationsOnChannels {
	__block BOOL isCompletionBlockCalled = NO;
	NSData *pushToken = nil;

	pNClientPushNotificationEnableDidCompleteNotification = NO;
	pNClientPushNotificationEnableDidFailNotification = NO;
	pushToken = [@"12345678123456" dataUsingEncoding: NSUTF8StringEncoding];
	[PubNub enablePushNotificationsOnChannels: pnChannels withDevicePushToken:pushToken andCompletionHandlingBlock:
	 ^(NSArray *channels, PNError *error) {
		 isCompletionBlockCalled = YES;
		 STAssertNotNil( error, @"enablePushNotificationsOnChannels must return error");
	 }];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 /*||
		(isCompletionBlockCalled == NO || pNClientPushNotificationEnableDidFailNotification == NO)*/; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	STAssertTrue( pNClientPushNotificationEnableDidFailNotification, @"notification not called");

	isCompletionBlockCalled = NO;
	pNClientPushNotificationEnableDidCompleteNotification = NO;
	pNClientPushNotificationEnableDidFailNotification = NO;
	[PubNub enablePushNotificationsOnChannels: pnChannels withDevicePushToken: nil andCompletionHandlingBlock:
	 ^(NSArray *channels, PNError *error) {
		 isCompletionBlockCalled = YES;
		 STAssertNotNil( error, @"enablePushNotificationsOnChannels must return error");
	 }];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 /*||
		(isCompletionBlockCalled == NO || pNClientPushNotificationEnableDidFailNotification == NO)*/; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	STAssertTrue( pNClientPushNotificationEnableDidFailNotification, @"notification not called");

	isCompletionBlockCalled = NO;
	pNClientPushNotificationEnableDidCompleteNotification = NO;
	pNClientPushNotificationEnableDidFailNotification = NO;
	pushToken = [@"12345678123456781234567812345678" dataUsingEncoding: NSUTF8StringEncoding];
	[PubNub enablePushNotificationsOnChannels: pnChannels withDevicePushToken:pushToken andCompletionHandlingBlock:
	 ^(NSArray *channels, PNError *error) {
		 isCompletionBlockCalled = YES;
		 STAssertNil( error, @"enablePushNotificationsOnChannels error %@", error);
	 }];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 /*||
		(isCompletionBlockCalled == NO || pNClientPushNotificationEnableDidCompleteNotification == NO)*/; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	STAssertTrue( pNClientPushNotificationEnableDidCompleteNotification, @"notification not called");
}

-(void)test40DisablePushNotificationsOnChannels {
	__block BOOL isCompletionBlockCalled = NO;
	NSData *pushToken = nil;

	isCompletionBlockCalled = NO;
	pNClientPushNotificationDisableDidCompleteNotification = NO;
	pNClientPushNotificationDisableDidFailNotification = NO;
	[PubNub disablePushNotificationsOnChannels: pnChannels withDevicePushToken: nil andCompletionHandlingBlock:
	 ^(NSArray *channels, PNError *error) {
		 isCompletionBlockCalled = YES;
		 STAssertNotNil( error, @"disablePushNotificationsOnChannels must return error");
	 }];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 /*||
		(isCompletionBlockCalled == NO || pNClientPushNotificationDisableDidFailNotification == NO)*/; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	STAssertTrue( pNClientPushNotificationDisableDidFailNotification, @"notification not called");

	isCompletionBlockCalled = NO;
	pNClientPushNotificationDisableDidCompleteNotification = NO;
	pNClientPushNotificationDisableDidFailNotification = NO;
	pushToken = [@"12345678123456781234567812345678" dataUsingEncoding: NSUTF8StringEncoding];
	[PubNub disablePushNotificationsOnChannels: pnChannels withDevicePushToken:pushToken andCompletionHandlingBlock:
	 ^(NSArray *channels, PNError *error) {
		 isCompletionBlockCalled = YES;
		 STAssertNil( error, @"disablePushNotificationsOnChannels error %@", error);
	 }];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 /*||
		(isCompletionBlockCalled == NO || pNClientPushNotificationDisableDidCompleteNotification == NO)*/; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	STAssertTrue( pNClientPushNotificationDisableDidCompleteNotification, @"notification not called");
}

@end
