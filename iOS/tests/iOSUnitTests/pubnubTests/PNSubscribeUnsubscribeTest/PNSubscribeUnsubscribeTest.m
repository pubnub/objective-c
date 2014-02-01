//
//  PNSubscribeUnsubscribeTest.m
//  pubnub
//
//  Created by Valentin Tuller on 9/26/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "PNSubscribeUnsubscribeTest.h"
#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"

@interface PNSubscribeUnsubscribeTest () <PNDelegate>
{
	NSArray *pnChannels1;
	NSArray *pnChannels2;
}
@end

@implementation PNSubscribeUnsubscribeTest

- (void)setUp
{
    [super setUp];
    [PubNub setDelegate:self];
	pnChannels1 = [PNChannel channelsWithNames:@[@"iosdev1", @"andoirddev1", @"wpdev1", @"ubuntudev1", [NSString stringWithFormat:@"%@", [NSDate date]]]];
	pnChannels2 = [PNChannel channelsWithNames:@[@"iosdev2", @"andoirddev2", @"wpdev2", @"ubuntudev2", [NSString stringWithFormat:@"%@ - 1", [NSDate date]]]];

//	[PubNub resetClient];
	[PubNub disconnect];
	[PubNub setDelegate: self];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: @"gagd" cipherKey: @"key"];
	//	//	configuration.autoReconnectClient = NO;
	[PubNub setConfiguration: configuration];

    [PubNub connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, nil, @"{BLOCK} PubNub client connected to: %@", origin);
        dispatch_semaphore_signal(semaphore);
    }
                         errorBlock:^(PNError *connectionError) {
							 PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
							 dispatch_semaphore_signal(semaphore);
							 STFail(@"connectionError %@", connectionError);
                         }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)subscribeOnChannels:(NSArray*)pnChannels withPresenceEvent:(BOOL)presenceEvent
{
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	NSLog(@"subscribeOnChannels");
	__block BOOL isCompletionBlockCalled = NO;
	[PubNub subscribeOnChannels: pnChannels withPresenceEvent: presenceEvent andCompletionHandlingBlock: ^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 NSLog(@"subscribeOnChannels end");
//		 dispatch_semaphore_signal(semaphore);
		 isCompletionBlockCalled = YES;
		 STAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
		 if( pnChannels.count != channels.count ) {
			 NSLog( @"pnChannels.count \n%@\n%@", pnChannels, channels);
		 }
		 STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
	 }];
    // Run loop
	NSLog(@"subscribeOnChannels runloop");
	for( int i=0; i<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		isCompletionBlockCalled == NO; i++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
}

- (void)unsubscribeOnChannels:(NSArray*)pnChannels withPresenceEvent:(BOOL)presenceEvent
{
	NSLog(@"unsubscribeOnChannels");
//	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	__block BOOL isCompletionBlockCalled = NO;
	[PubNub unsubscribeFromChannels: pnChannels
				  withPresenceEvent: presenceEvent
		 andCompletionHandlingBlock:^(NSArray *channels, PNError *unsubscribeError)
	 {
		 NSLog(@"unsubscribeOnChannels end");
		 // Check whether "unsubscribeError" is nil or not (if not, than handle error)
//		 dispatch_semaphore_signal(semaphore);
		 isCompletionBlockCalled = YES;
		 STAssertNil( unsubscribeError, @"unsubscribeError %@", unsubscribeError);
		 STAssertEquals( pnChannels.count, channels.count, @"pnChannels.count %d, channels.count %d", pnChannels.count, channels.count);
	 }];
    // Run loop
	NSLog(@"unsubscribeOnChannels runloop");
	for( int i=0; i<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		isCompletionBlockCalled == NO; i++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( isCompletionBlockCalled, @"completion block not called");
}

- (void)test10SubscribeOnChannels
{
	[self subscribeOnChannels: pnChannels1 withPresenceEvent: YES];
	[self unsubscribeOnChannels: pnChannels1 withPresenceEvent: NO];

	[self subscribeOnChannels: pnChannels2 withPresenceEvent: NO];
	[self unsubscribeOnChannels: pnChannels1 withPresenceEvent: YES];
	[self unsubscribeOnChannels: pnChannels2 withPresenceEvent: NO];
	[self unsubscribeOnChannels: pnChannels1 withPresenceEvent: YES];

	[self subscribeOnChannels: pnChannels1 withPresenceEvent: YES];
	[self unsubscribeOnChannels: pnChannels1 withPresenceEvent: NO];
	[self subscribeOnChannels: pnChannels1 withPresenceEvent: NO];
	[self unsubscribeOnChannels: pnChannels1 withPresenceEvent: NO];
	[self unsubscribeOnChannels: pnChannels2 withPresenceEvent: YES];

	[self subscribeOnChannels: pnChannels2 withPresenceEvent: NO];
	[self unsubscribeOnChannels: pnChannels2 withPresenceEvent: YES];
	[self subscribeOnChannels: pnChannels2 withPresenceEvent: YES];
	[self unsubscribeOnChannels: pnChannels2 withPresenceEvent: NO];
}

@end
