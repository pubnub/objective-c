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
}

@property (nonatomic, retain) NSConditionLock *theLock;

@end


@implementation ClientStateTest

- (void)test01Init {
	[PubNub resetClient];
	clientState = @{@"firstName":@"John", @"lastName":@"Appleseed", @"age":@(240)};

	for( int j=0; j<1; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

	semaphoreNotification = dispatch_semaphore_create(0);
    [PubNub setDelegate:self];
	pnChannels = [PNChannel channelsWithNames:@[@"iosdevState", [NSString stringWithFormat: @"channelDate %@", [NSDate date]]]];

//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientMessageHistoryProcess:)
//							   name:kPNClientDidReceiveMessagesHistoryNotification
//							 object:nil];
//	[notificationCenter addObserver:self
//						   selector:@selector(handleClientMessageHistoryProcess:)
//							   name:kPNClientHistoryDownloadFailedWithErrorNotification
//							 object:nil];
	[self t10Connect];
	[self t20SubscribeOnChannels];
	[self t22RequestClientState];
	[self t910removeClientChannelSubscriptionStateObserver];
}

- (void)tearDown {
    [super tearDown];

    [[PNObservationCenter defaultCenter] removeClientConnectionStateObserver: self];
	[NSThread sleepForTimeInterval:1.0];
}


- (void)t10Connect {
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

- (void)t20SubscribeOnChannels {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	NSMutableDictionary *state = [NSMutableDictionary dictionary];
	for( int i=0; i<pnChannels.count; i++)
		[state setObject: clientState forKey: [pnChannels[i] name]];
//	state = [@{@"iosdev1":clientState, @"andoirddev1":clientState, @"wpdev1":clientState, @"ubuntudev1":clientState, @"11":clientState}  mutableCopy];
	NSLog(@"set state:\n%@", state);
	[PubNub subscribeOnChannels: pnChannels withClientState: state andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
		 dispatch_semaphore_signal(semaphore);
		 STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
		 STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
	 }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

- (void)t22RequestClientState {
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
}

- (void)t910removeClientChannelSubscriptionStateObserver {
    [[PNObservationCenter defaultCenter] removeClientChannelSubscriptionStateObserver: self];
}

@end
