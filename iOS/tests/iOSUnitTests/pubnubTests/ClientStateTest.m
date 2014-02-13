//
//  PNBaseRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
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
#import "PNConnection.h"
#import "TestSemaphor.h"
#import "Swizzler.h"
#import "PNConnectionBadJson.h"
#import "PNMessageHistoryRequest.h"


@interface ClientStateTest : SenTestCase

@end


@interface ClientStateTest ()

@property (nonatomic, assign) NSUInteger retryCount;

@end

@interface ClientStateTest () <PNDelegate>
{
	NSArray *pnChannels;
	dispatch_semaphore_t semaphoreNotification;
	NSArray *pnChannelsForReverse;
	NSDictionary *clientState;

	SwizzleReceipt *receiptReconnect;
	int _reconnectCount;
	NSNumber *_reconnectNumber;

	int countkPNClientDidReceiveClientStateNotification;
	int countkPNClientStateRetrieveDidFailWithErrorNotification;

	int countkPNClientDidUpdateClientStateNotification;
	int countkPNClientStateUpdateDidFailWithErrorNotification;
}

@property (nonatomic, retain) NSConditionLock *theLock;

@end


@implementation ClientStateTest

- (void)test01Init {
	[PubNub resetClient];
	[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

	clientState = @{@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)};
	countkPNClientDidReceiveClientStateNotification = 0;
	countkPNClientStateRetrieveDidFailWithErrorNotification = 0;
	countkPNClientDidUpdateClientStateNotification = 0;
	countkPNClientStateUpdateDidFailWithErrorNotification = 0;

	semaphoreNotification = dispatch_semaphore_create(0);
    [PubNub setDelegate:self];
	pnChannels = [PNChannel channelsWithNames:@[@"iosdevState", @"ch1", @"adasfasdf", @"1 12 12133", [NSString stringWithFormat: @"channelDate %@", [NSDate date]]]];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientDidReceiveClientStateNotification:)
							   name:kPNClientDidReceiveClientStateNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientStateRetrieveDidFailWithErrorNotification:)
							   name:kPNClientStateRetrieveDidFailWithErrorNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientDidUpdateClientStateNotification:)
							   name:kPNClientDidUpdateClientStateNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(kPNClientStateUpdateDidFailWithErrorNotification:)
							   name:kPNClientStateUpdateDidFailWithErrorNotification
							 object:nil];
	[self connect];
	[self subscribeOnChannels];
	[self requestClientState];

	countkPNClientDidUpdateClientStateNotification = 0;
	countkPNClientStateUpdateDidFailWithErrorNotification = 0;
	[self updateClientStateBlock: clientState isExpectError: NO];
	STAssertTrue( countkPNClientDidUpdateClientStateNotification == pnChannels.count, @"");
	STAssertTrue( countkPNClientStateUpdateDidFailWithErrorNotification == 0, @"");

	[self requestClientState];

	countkPNClientDidUpdateClientStateNotification = 0;
	countkPNClientStateUpdateDidFailWithErrorNotification = 0;
	[self updateClientState: clientState];
	STAssertTrue( countkPNClientDidUpdateClientStateNotification == pnChannels.count, @"");
	STAssertTrue( countkPNClientStateUpdateDidFailWithErrorNotification == 0, @"");

	countkPNClientDidUpdateClientStateNotification = 0;
	countkPNClientStateUpdateDidFailWithErrorNotification = 0;
	[self updateClientStateBlock: @{@"arrForError":@[@(123), @(124)]} isExpectError: YES];
	STAssertTrue( countkPNClientDidUpdateClientStateNotification == 0, @"");
	STAssertTrue( countkPNClientStateUpdateDidFailWithErrorNotification == pnChannels.count, @"");

	[self requestClientState];

	[self removeClientChannelSubscriptionStateObserver];
}

- (void)tearDown {
    [super tearDown];

    [[PNObservationCenter defaultCenter] removeClientConnectionStateObserver: self];
	[NSThread sleepForTimeInterval:1.0];
}


- (void)connect {
	[PubNub disconnect];

	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		[PubNub setDelegate:self];
		PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"presence-beta.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil];
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
}

- (void)subscribeOnChannels {
	countkPNClientDidUpdateClientStateNotification = 0;
	countkPNClientStateUpdateDidFailWithErrorNotification = 0;

	NSMutableDictionary *state = [NSMutableDictionary dictionary];
	for( int i=0; i<pnChannels.count; i++)
		[state setObject: clientState forKey: [pnChannels[i] name]];
//	state = [@{@"iosdev1":clientState, @"andoirddev1":clientState, @"wpdev1":clientState, @"ubuntudev1":clientState, @"11":clientState}  mutableCopy];
	NSLog(@"set state:\n%@", state);
	[PubNub subscribeOnChannels: pnChannels withClientState: state andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
		 STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
		 STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
	 }];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
}

- (void)requestClientState {
	countkPNClientDidReceiveClientStateNotification = 0;
	countkPNClientStateRetrieveDidFailWithErrorNotification = 0;

	for( int i = 0; i<pnChannels.count; i++ ) {
		__block BOOL isCompletionBlockCalled = NO;
		__block NSDate *start = [NSDate date];
		PNChannel *channel = pnChannels[i];
		[PubNub requestClientState: [PubNub sharedInstance].clientIdentifier forChannel: channel withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
			isCompletionBlockCalled = YES;
			NSTimeInterval interval = -[start timeIntervalSinceNow];
			NSLog(@"requestClientState %f, %@", interval, client);
			STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %d instead of %d", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

			STAssertNil( error, @"requestClientState error %@", error);

			STAssertTrue( [channel.name isEqualToString: client.channel.name] == YES, @"invalid channel name");
			STAssertTrue( client.data != nil && [client.data isEqualToDictionary: clientState], @"invalid client.data %@", client.data);
		}];
		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	}
	STAssertTrue( countkPNClientDidReceiveClientStateNotification == pnChannels.count, @"");
	STAssertTrue( countkPNClientStateRetrieveDidFailWithErrorNotification == 0, @"");
}


- (void)updateClientStateBlock:(NSDictionary*)state isExpectError:(BOOL)isExpectError{

	for( int i = 0; i<pnChannels.count; i++ ) {
		__block BOOL isCompletionBlockCalled = NO;
		__block NSDate *start = [NSDate date];
		PNChannel *channel = pnChannels[i];
		[PubNub updateClientState: [PubNub sharedInstance].clientIdentifier state: state  forChannel: channel withCompletionHandlingBlock:^(PNClient *client, PNError *error) {
			isCompletionBlockCalled = YES;
			NSTimeInterval interval = -[start timeIntervalSinceNow];
			NSLog(@"updateClientState %f, %@", interval, client);
			STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %d instead of %d", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

			if( isExpectError == NO ) {
				STAssertNil( error, @"updateClientState error %@", error);
				STAssertTrue( [channel.name isEqualToString: client.channel.name] == YES, @"invalid channel name");
				STAssertTrue( client.data != nil && [client.data isEqualToDictionary: clientState], @"invalid client.data %@", client.data);
			}
			else
				STAssertNotNil( error, @"updateClientState empty error");

		}];
		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
		STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	}
}

- (void)updateClientState:(NSDictionary*)state {
	countkPNClientDidUpdateClientStateNotification = 0;
	countkPNClientStateUpdateDidFailWithErrorNotification = 0;

	for( int i = 0; i<pnChannels.count; i++ ) {
		PNChannel *channel = pnChannels[i];
		[PubNub updateClientState: [PubNub sharedInstance].clientIdentifier state: state  forChannel: channel];
		for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	}
	STAssertTrue( countkPNClientDidUpdateClientStateNotification == pnChannels.count, @"");
	STAssertTrue( countkPNClientStateUpdateDidFailWithErrorNotification == 0, @"");
}


- (void)removeClientChannelSubscriptionStateObserver {
    [[PNObservationCenter defaultCenter] removeClientChannelSubscriptionStateObserver: self];
}


-(void)kPNClientDidReceiveClientStateNotification:(NSNotification*)notification {
	NSLog(@"kPNClientDidReceiveClientStateNotification %@", notification);
	countkPNClientDidReceiveClientStateNotification++;
}
-(void)kPNClientStateRetrieveDidFailWithErrorNotification:(NSNotification*)notification {
	NSLog(@"kPNClientStateRetrieveDidFailWithErrorNotification %@", notification);
	countkPNClientStateRetrieveDidFailWithErrorNotification++;
}

-(void)kPNClientDidUpdateClientStateNotification:(NSNotification*)notification {
	NSLog(@"kPNClientDidUpdateClientStateNotification %@", notification);
	countkPNClientDidUpdateClientStateNotification++;
}
-(void)kPNClientStateUpdateDidFailWithErrorNotification:(NSNotification*)notification {
	NSLog(@"kPNClientStateUpdateDidFailWithErrorNotification %@", notification);
	countkPNClientStateUpdateDidFailWithErrorNotification++;
}

@end
