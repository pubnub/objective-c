//
//  SendBigMessage.m
//  pubnub
//
//  Created by Valentin Tuller on 11/14/13.
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
#import "PNMessagePostRequest.h"

@interface PNReachability ()
@property (nonatomic, assign, getter = shouldCompressMessage) BOOL compressMessage;
@end

@interface SendBigMessage : SenTestCase <PNDelegate>

@end

@implementation SendBigMessage {
	NSArray *pnChannels;

	BOOL pNClientDidSendMessageNotification;
	BOOL pNClientMessageSendingDidFailNotification;

	NSDate *startSendMessage;
	NSDate *willSendMessage;
}


- (void)setUp
{
    [super setUp];
    [PubNub setDelegate:self];
	pnChannels = [PNChannel channelsWithNames:@[@"iosdev", @"andoirddev", @"wpdev", @"ubuntudev", @"1"]];

	// Handle message processing events
	[[NSNotificationCenter defaultCenter] addObserver:self
						   selector:@selector(kPNClientDidSendMessageNotification:)
							   name:kPNClientDidSendMessageNotification
							 object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
						   selector:@selector(kPNClientMessageSendingDidFailNotification:)
							   name:kPNClientMessageSendingDidFailNotification
							 object:nil];
}

- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
	willSendMessage = [NSDate date];
	NSTimeInterval interval = -[startSendMessage timeIntervalSinceNow];
	NSLog(@"willSendMessage interval %f", interval);
	PNLog(PNLogGeneralLevel, self, @"willSendMessage interval %f", interval);
	if( interval > 2 ) {
		NSLog(@"willSendMessage interval %f", interval);
	}
}


- (void)kPNClientDidSendMessageNotification:(NSNotification *)notification {
	NSLog(@"kPNClientDidSendMessageNotification");
	PNLog(PNLogGeneralLevel, self, @"kPNClientDidSendMessageNotification");
	pNClientDidSendMessageNotification = YES;
}
- (void)kPNClientMessageSendingDidFailNotification:(NSNotification *)notification {
    NSLog(@"kPNClientMessageSendingDidFailNotification");
	PNLog(PNLogGeneralLevel, self, @"kPNClientMessageSendingDidFailNotification");
	pNClientMessageSendingDidFailNotification = YES;
}


- (void)tearDown
{
    [super tearDown];
}

#pragma mark - PubNub client delegate methods


- (void)test10Connect
{
	[PubNub disconnect];
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		//		[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];
		PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"post-devbuild.pubnub.com" publishKey:@"pub-c-bb4a4d9b-21b1-40e8-a30b-04a22f5ef154" subscribeKey:@"sub-c-6b43405c-3694-11e3-a5ee-02ee2ddab7fe" secretKey: @"sec-c-ZmNlNzczNTEtOGUwNS00MmRjLWFkMjQtMjJiOTA2MjY2YjI5" cipherKey: @"cipherKey"];
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
		for( int j=0; j<10; j++ )
			[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	});
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];

	[PubNub grantAllAccessRightsForApplicationAtPeriod: 10 andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		STAssertNil( error, @"grantAllAccessRightsForApplicationAtPeriod %@", error);
	}];
	for( int j=0; j<10; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

	[self t20SubscribeOnChannels];
	[self t45SendMessageBigCompressed];
	[self t45SendMessageBig];
	[self t50RequestHistoryForChannel];
	[self t900UnsubscribeFromChannels];
}


- (void)t20SubscribeOnChannels
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	[PubNub subscribeOnChannels: pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 dispatch_semaphore_signal(semaphore);
		 STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
		 STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
	 }];
    // Run loop
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}
-(void)t45SendMessageBigCompressed
{
	NSMutableString *message = [NSMutableString stringWithString: @""];
	for( int j=0; j<6; j++ ) {
		for( int i=0; i<pnChannels.count; i++ )	{
			pNClientDidSendMessageNotification = NO;
			pNClientMessageSendingDidFailNotification = NO;
			startSendMessage = [NSDate date];
			willSendMessage = nil;
			__block PNMessageState state = PNMessageSendingError;
			[message appendFormat: @"message block <big text: asd adskfjasf dkjlasdlfkjasdfk jlasdf kljasdf jlasd fjasdlfkj lasdkj aslkfj salj faslkj fsj asdlkfj aslj fsaldjf asljkf asdkl; as;ldj fasl;jkf aslfjk asljdf  aslkjdfh asdasljdhf fsdgdjagafdakfl> %d_%d", i, j];
			NSLog(@"send message %d_%d with size %lu", i, j, (unsigned long)message.length);
			PNLog(PNLogGeneralLevel, self, @"send message %d_%d with size %d", i, j, message.length);

			state = PNMessageSending;

			PNMessage *messageObject = [PNMessage messageWithObject:message forChannel:pnChannels[i] compressed: NO error: nil];
			PNMessagePostRequest *request = [PNMessagePostRequest postMessageRequestWithMessage: messageObject];
			NSUInteger normalSize = [[request POSTBody] length];

			messageObject = [PNMessage messageWithObject:message forChannel:pnChannels[i] compressed: YES error: nil];
			request = [PNMessagePostRequest postMessageRequestWithMessage: messageObject];
			NSUInteger compressedSize = [[request POSTBody] length];
			STAssertTrue( compressedSize < normalSize, @"");
			NSLog(@"compressedSize %lu/ normalSize %lu",(unsigned long)compressedSize, (unsigned long)normalSize);

			[PubNub sendMessage: message toChannel:pnChannels[i] compressed: YES withCompletionBlock:^(PNMessageState messageSendingState, id data) {
				 state = messageSendingState;
				 if( state != PNMessageSending ) {
					 NSTimeInterval interval = -[willSendMessage timeIntervalSinceNow];
					 NSLog(@"sendMessage interval %f", interval);
					 PNLog(PNLogGeneralLevel, self, @"sendMessage interval %f", interval);
					 if( interval >= [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 )
						 PNLog(PNLogGeneralLevel, self, @"SendMessage timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

					 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
				 }
			 }];

			for( int j=0; j < 12/*j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&*/
				/*(state == PNMessageSending || (pNClientDidSendMessageNotification == NO && pNClientMessageSendingDidFailNotification == NO))*/; j++ )
				[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
			STAssertTrue( state != PNMessageSending, @"" );
			STAssertTrue( pNClientDidSendMessageNotification == YES || pNClientMessageSendingDidFailNotification == YES, @"notification not called");

			if( message.length <= 5352 )
				STAssertTrue( pNClientDidSendMessageNotification == YES && state == PNMessageSent, @"message not sent, size %d", message.length);
			else
				STAssertTrue( pNClientMessageSendingDidFailNotification == YES && state == PNMessageSendingError, @"message's methods not called, size %d", message.length);
		}
	}
}

-(void)t45SendMessageBig
{
	NSMutableString *message = [NSMutableString stringWithString: @""];
	for( int j=0; j<6; j++ ) {
		for( int i=0; i<pnChannels.count; i++ )	{
			pNClientDidSendMessageNotification = NO;
			pNClientMessageSendingDidFailNotification = NO;
			startSendMessage = [NSDate date];
			willSendMessage = nil;
			__block PNMessageState state = PNMessageSendingError;
			[message appendFormat: @"message block <big text: asd adskfjasf dkjlasdlfkjasdfk jlasdf kljasdf jlasd fjasdlfkj lasdkj aslkfj salj faslkj fsj asdlkfj aslj fsaldjf asljkf asdkl; as;ldj fasl;jkf aslfjk asljdf  aslkjdfh asdasljdhf fsdgdjagafdakfl> %d_%d", i, j];
			NSLog(@"send message %d_%d with size %lu", i, j, (unsigned long)message.length);
			PNLog(PNLogGeneralLevel, self, @"send message %d_%d with size %d", i, j, message.length);

			state = PNMessageSending;
			[PubNub sendMessage: message toChannel:pnChannels[i]
			withCompletionBlock:^(PNMessageState messageSendingState, id data)
			 {
				 state = messageSendingState;
				 if( state != PNMessageSending ) {
					 NSTimeInterval interval = -[willSendMessage timeIntervalSinceNow];
					 NSLog(@"sendMessage interval %f", interval);
					 PNLog(PNLogGeneralLevel, self, @"sendMessage interval %f", interval);
					 if( interval >= [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 )
						PNLog(PNLogGeneralLevel, self, @"SendMessage timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

					 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
				 }
			 }];

			for( int j=0; /*j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&*/
				(state == PNMessageSending || (pNClientDidSendMessageNotification == NO && pNClientMessageSendingDidFailNotification == NO)); j++ )
				[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

			if( message.length < 4*1024 )
				STAssertTrue( pNClientDidSendMessageNotification == YES && state == PNMessageSent, @"message not sent, size %d", message.length);
			if( message.length >= 5*1024 )
				STAssertTrue( pNClientMessageSendingDidFailNotification == YES && state == PNMessageSendingError, @"message's methods not called, size %d", message.length);
		}
	}
}

-(NSArray*)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate limit:(NSUInteger)limit reverseHistory:(BOOL)shouldReverseMessageHistory
{
	//	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	__block NSArray *history;
	__block BOOL isCompletionBlockCalled = NO;
	NSDate *start = [NSDate date];
	[PubNub requestHistoryForChannel:channel from:startDate to:endDate limit:limit reverseHistory:NO
				 withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *startDate, PNDate *endDate, PNError *error)
	 {
		 isCompletionBlockCalled = YES;
		 history = messages;

		 NSTimeInterval interval = -[start timeIntervalSinceNow];
		 NSLog(@"requestHistoryForChannel interval %f", interval);
		 PNLog(PNLogGeneralLevel, self, @"requestHistoryForChannel interval %f", interval);
		 if( interval > [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1)
			 PNLog(PNLogGeneralLevel, self, @"History timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);
		 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

		 STAssertNil( error, @"error %@", error);
	 }];

	for( int j=0; /*j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&*/
		isCompletionBlockCalled == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
	return history;
}

-(void)t50RequestHistoryForChannel
{
	for( int i=0; i<pnChannels.count; i++ )
	{
		PNDate *startDate = [PNDate dateWithDate:[NSDate dateWithTimeIntervalSinceNow:(-3600.0f)]];
		PNDate *endDate = [PNDate dateWithDate:[NSDate date]];
		int limit = 34;
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: limit reverseHistory: YES];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: limit reverseHistory: NO];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: endDate limit: 0 reverseHistory: NO];
		[self requestHistoryForChannel: pnChannels[i] from: startDate to: nil limit: 0 reverseHistory: NO];
	}
}

-(void)t900UnsubscribeFromChannels
{
	__block BOOL isCompletionBlockCalled = NO;
	[PubNub unsubscribeFromChannels: pnChannels
				  withPresenceEvent:YES
		 andCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError)
	 {
		 isCompletionBlockCalled = YES;
		 STAssertNil( unsubscribeError, @"unsubscribeError %@", unsubscribeError);
		 STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
	 }];

	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		isCompletionBlockCalled == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
}

@end
