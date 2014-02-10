
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

#import "PNPushNotificationsRemoveRequest.h"
#import "PNPushNotificationsEnabledChannelsRequest.h"
#import "PNPushNotificationsStateChangeRequest.h"

//<96cce5c5 b331e0dc 5c9b8985 b020b6a6 77d2ec22 9c527d27 0f9b5b0a fdc0b44f>
//96cce5c5b331e0dc5c9b8985b020b6a677d2ec229c527d270f9b5b0afdc0b44f
#define kToken		@"96cce5c5b331e0dc5c9b8985b020b6a677d2ec229c527d270f9b5b0afdc0b44f"

@interface ApnsToken : SenTestCase <PNDelegate>{
	NSArray *pnChannels;
	BOOL pNClientPushNotificationEnableDidCompleteNotification;
	BOOL pNClientPushNotificationEnableDidFailNotification;

	BOOL pNClientPushNotificationDisableDidCompleteNotification;
	BOOL pNClientPushNotificationDisableDidFailNotification;
	int pNClientPushNotificationChannelsRetrieveDidCompleteNotification;
}

@end

@implementation ApnsToken

- (void)setUp
{
    [super setUp];
    [PubNub setDelegate:self];
	pnChannels = [PNChannel channelsWithNames:@[@"iosdev", @"andoirddev"]];

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
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(kPNClientPushNotificationChannelsRetrieveDidCompleteNotification:)
												 name:kPNClientPushNotificationChannelsRetrieveDidCompleteNotification
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
	NSLog(@"kPNClientPushNotificationEnableDidFailNotification %@", notification);
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

- (void)kPNClientPushNotificationChannelsRetrieveDidCompleteNotification:(NSNotification *)__unused notification {
	NSLog(@"kPNClientPushNotificationChannelsRetrieveDidCompleteNotification");
	pNClientPushNotificationChannelsRetrieveDidCompleteNotification++;
}
//////////////////////////////////////////////////////////////////

- (void)test10Connect {
	[PubNub disconnect];

	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		//		[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];
		PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"pub-c-bb4a4d9b-21b1-40e8-a30b-04a22f5ef154" subscribeKey:@"sub-c-6b43405c-3694-11e3-a5ee-02ee2ddab7fe" secretKey: @"sec-c-ZmNlNzczNTEtOGUwNS00MmRjLWFkMjQtMjJiOTA2MjY2YjI5" cipherKey: nil authorizationKey: @"authorization_key"];
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

	[PubNub grantAllAccessRightsForApplicationAtPeriod: 10 andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		STAssertNil( error, @"grantAllAccessRightsForApplicationAtPeriod %@", error);
	}];
	for( int j=0; j<10; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	[self t15PushTokenLowercase];
	[self t20SubscribeOnChannels];
	[self t30EnablePushNotificationsOnChannels];
	[self t35SendMessage];
	[self t40DisablePushNotificationsOnChannels];
	[PubNub revokeAccessRightsForApplication];

	[PubNub grantAllAccessRightsForChannels: pnChannels forPeriod: 10 withCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		STAssertNil( error, @"grantAllAccessRightsForChannels %@", error);
	}];
	for( int j=0; j<10; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	[self t15PushTokenLowercase];
	[self t20SubscribeOnChannels];
	[self t30EnablePushNotificationsOnChannels];
	[self t35SendMessage];
	[self t40DisablePushNotificationsOnChannels];
	[PubNub revokeAccessRightsForChannels: pnChannels];

	for( int i=0; i<pnChannels.count; i++)
		[PubNub grantAllAccessRightsForChannel: pnChannels[i] forPeriod: 10 client: @"authorization_key"];
	for( int j=0; j<10; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	[self t15PushTokenLowercase];
	[self t20SubscribeOnChannels];
	[self t30EnablePushNotificationsOnChannels];
	[self t35SendMessage];
	[self t40DisablePushNotificationsOnChannels];
	for( int i=0; i<pnChannels.count; i++)
		[PubNub revokeAccessRightsForChannel: pnChannels[i] client: @"authorization_key"];
}

-(void)t35SendMessage {
	for( int i=0; i<pnChannels.count; i++ )	{
		__block PNMessageState state = PNMessageSending;
		NSString *message = [NSString stringWithFormat: @"Hello PubNub %d", i];
		[PubNub sendMessage: message toChannel:pnChannels[i] withCompletionBlock:^(PNMessageState messageSendingState, id data) {
			state = messageSendingState;
			STAssertFalse(messageSendingState==PNMessageSendingError, @"messageSendingState==PNMessageSendingError %@", data);
		}];

		for( int j=0; state == PNMessageSending; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		STAssertTrue( state == PNMessageSent, @"error");
	}
}


-(void)t15PushTokenLowercase {
	NSString *pushUpperCase = @"PuSh UpperCase 123ABCDE";
	PNPushNotificationsRemoveRequest *requestRemove = [PNPushNotificationsRemoveRequest requestWithDevicePushToken: [pushUpperCase dataUsingEncoding:NSUTF8StringEncoding]];
	STAssertTrue( [[requestRemove resourcePath] isEqualToString: [[requestRemove resourcePath] lowercaseString]] == YES, @"");

	PNPushNotificationsEnabledChannelsRequest *requestEnabled = [PNPushNotificationsEnabledChannelsRequest requestWithDevicePushToken: [pushUpperCase dataUsingEncoding:NSUTF8StringEncoding]];
	STAssertTrue( [[requestEnabled resourcePath] isEqualToString: [[requestEnabled resourcePath] lowercaseString]] == YES, @"");

	PNPushNotificationsStateChangeRequest *requestChange = [PNPushNotificationsStateChangeRequest requestWithDevicePushToken: [pushUpperCase dataUsingEncoding:NSUTF8StringEncoding] toState: @"" forChannels: @[]];
	STAssertTrue( [[requestChange resourcePath] isEqualToString: [[requestChange resourcePath] lowercaseString]] == YES, @"");
}

- (void)t20SubscribeOnChannels {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	[PubNub subscribeOnChannels: pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
		 dispatch_semaphore_signal(semaphore);
	 }];
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

-(void)t30EnablePushNotificationsOnChannels {
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
	pushToken = [self dataFromHex: kToken];
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

-(void)t40DisablePushNotificationsOnChannels {
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
	pNClientPushNotificationChannelsRetrieveDidCompleteNotification = 0;
	pushToken = [self dataFromHex: kToken];
	[PubNub requestPushNotificationEnabledChannelsForDevicePushToken: pushToken withCompletionHandlingBlock:
	 ^(NSArray *channels, PNError *error) {
		 isCompletionBlockCalled = YES;
		 STAssertNil( error, @"requestPushNotificationEnabledChannelsForDevicePushToken error %@", error);
		 STAssertTrue( channels.count == pnChannels.count, @"channel's arrays are not equal, \n %@, \n %@", pnChannels, channels);
		 NSLog( @"channel with push: \n %@, \n %@", pnChannels, channels);
	 }];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	STAssertTrue( pNClientPushNotificationChannelsRetrieveDidCompleteNotification==1, @"notification must be called once");

	isCompletionBlockCalled = NO;
	pNClientPushNotificationDisableDidCompleteNotification = NO;
	pNClientPushNotificationDisableDidFailNotification = NO;
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

	isCompletionBlockCalled = NO;
	pNClientPushNotificationChannelsRetrieveDidCompleteNotification = 0;
	pushToken = [self dataFromHex: kToken];
	[PubNub requestPushNotificationEnabledChannelsForDevicePushToken: pushToken withCompletionHandlingBlock:
	 ^(NSArray *channels, PNError *error) {
		 isCompletionBlockCalled = YES;
		 STAssertNil( error, @"requestPushNotificationEnabledChannelsForDevicePushToken error %@", error);
		 STAssertTrue( channels.count == 0, @"channel's array are not empty, \n %@", channels);
		 NSLog( @"channel with push: \n %@", channels);
	 }];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	STAssertTrue( pNClientPushNotificationChannelsRetrieveDidCompleteNotification==1, @"notification must be called once");
}

-(NSData*)dataFromHex:(NSString*)command {
	command = [command stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSMutableData *commandToSend= [[NSMutableData alloc] init];
	unsigned char whole_byte;
	char byte_chars[3] = {'\0','\0','\0'};
	for (int i = 0; i < ([command length] / 2); i++) {
		byte_chars[0] = [command characterAtIndex:i*2];
		byte_chars[1] = [command characterAtIndex:i*2+1];
		whole_byte = strtol(byte_chars, NULL, 16);
		[commandToSend appendBytes:&whole_byte length:1];
	}
	NSLog(@"%@", commandToSend);
	return commandToSend;
}

@end
