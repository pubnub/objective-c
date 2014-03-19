//
//  HeartbeatTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/12/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PubNub.h"
#import "PNConfiguration.h"
#import "PNConstants.h"
#import "PNBaseRequest.h"
#import "PNWriteBuffer.h"
#import "PNConfiguration.h"
#import "PubNub+Protected.h"
#import "PNHeartbeatRequest.h"

@interface HeartbeatTest : SenTestCase <PNDelegate> {
	NSDate *dateLastPresence;
	NSDate *dateLastHeartbeat;
	int presenceInterval;
	int countPresence;
	int countHeartbeat;
}

@end

@implementation HeartbeatTest

-(void)tearDown {
    [super tearDown];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[NSThread sleepForTimeInterval:0.1];
}

-(void)presenceEvent:(NSNotification*)notification {
	if( [PubNub sharedInstance].isConnected == NO )
		return;

//	NSLog(@"presenceEvent %@", notification);
	NSTimeInterval interval = -[dateLastPresence timeIntervalSinceNow];
	if( interval < 1 )
		return;

	NSLog(@"dateLastPresence %@, now %@", dateLastPresence, [NSDate date]);
	STAssertTrue( interval > presenceInterval-1 && interval < presenceInterval+2, @"interval %f, presenceInterval %d", interval, presenceInterval);
	NSLog(@"presenceEvent interval %f, presenceInterval %d", interval, presenceInterval);
//	STAssertTrue( interval > presenceInterval-1 && interval < presenceInterval+2, @"interval %f, presenceInterval %d", interval, presenceInterval);
	countPresence++;
	dateLastPresence = [NSDate date];
}

- (void)test10Connect {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presenceEvent:) name: @"presenceEvent" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendRequest:) name:@"didSendRequest" object:nil];

	presenceInterval = /*kPNHeartbeatRequestTimeoutOffset + */11;
	[self check];

	presenceInterval = 21;
	[self check];

	presenceInterval = 31;
	[self check];
}

-(void)check {
	[PubNub disconnect];

	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil authorizationKey: @"a3"];
		configuration.useSecureConnection = NO;
		configuration.presenceHeartbeatTimeout = presenceInterval*2;
		configuration.presenceHeartbeatInterval = presenceInterval;
		[PubNub setConfiguration: configuration];

		[PubNub connectWithSuccessBlock:^(NSString *origin) {
			[PubNub subscribeOnChannels: [PNChannel channelsWithNames:@[@"channel"]] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
				 dispatch_semaphore_signal(semaphore);
				dateLastPresence = [NSDate date];
				countPresence = 0;
				dateLastHeartbeat = [NSDate date];
				countHeartbeat = 0;
			 }];
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
	for( int j=0; j<70; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( countPresence >= 2, @"countPresence %d (interval %d)", countPresence, presenceInterval);
	STAssertTrue( countHeartbeat >= 2, @"countPresence %d (interval %d)", countHeartbeat, presenceInterval);
}

-(void)didSendRequest:(NSNotification*)notification {
	NSLog(@"didSendRequest %@", notification.object);
	PNBaseRequest *request = notification.object;
	PNWriteBuffer *buffer = [request buffer];
	NSString *string = [NSString stringWithUTF8String: (char*)buffer.buffer];
	if( string == nil )
		string = [buffer description];
	STAssertTrue( string != nil, @"");
//	NSLog(@"didSendRequest buffer:\n%@", string);
    NSString *authorizationKey = [PubNub sharedInstance].configuration.authorizationKey;
    if ([authorizationKey length] > 0)
        authorizationKey = [NSString stringWithFormat:@"auth=%@", authorizationKey];
	if( authorizationKey.length > 0 )
		STAssertTrue( [string rangeOfString: authorizationKey].location != NSNotFound, @"");
// GET /v2/presence/sub-key/demo/channel/channel/heartbeat?uuid=1b72581b-c2ab-4705-94e4-1c96c74bcf99&heartbeat=22&auth=a3 HTTP/1.1\r\nHost: pubsub.pubnub.com\r\nV: 3.6.1\r\nUser-Agent: Obj-C-iOS\r\nAccept: */*\r\nAccept-Encoding: gzip, deflate\r\n
    //@/v2/presence/sub-key/demo/channel/channel/heartbeat?uuid=1b72581b-c2ab-4705-94e4-1c96c74bcf99&pnexpires=22&auth=a3"	0x08ed24d0

	if( [request isKindOfClass: [PNHeartbeatRequest class]] == YES ) {

		NSString *expect = [NSString stringWithFormat:@"/v2/presence/sub-key/%@/channel/%@/heartbeat?uuid=%@&heartbeat=%d&auth=%@",
				[[PubNub sharedInstance].configuration.subscriptionKey percentEscapedString],
				@"channel",
				[request performSelector: @selector(clientIdentifier)], presenceInterval*2,
//				([request authorizationField] ? [NSString stringWithFormat:@"&%@", [request authorizationField]] : @"")
				[PubNub sharedInstance].configuration.authorizationKey	];
		STAssertTrue( [string rangeOfString: expect].location != NSNotFound, @"string\n%@\nexpect\n%@", string, expect);
		NSTimeInterval interval = -[dateLastHeartbeat timeIntervalSinceNow];
		NSLog(@"dateLastHeartbeat %@, now %@", dateLastHeartbeat, [NSDate date]);
		STAssertTrue( interval > presenceInterval-2 && interval < presenceInterval+2, @"interval %f, presenceInterval %d", interval, presenceInterval);
		NSLog(@"presenceEvent interval %f", interval);
		countHeartbeat++;
		dateLastHeartbeat = [NSDate date];
	}
}



@end
