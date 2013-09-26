//
//  PNChaosTest.m
//  pubnub
//
//  Created by Valentin Tuller on 9/19/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import "W_ChaosTest.h"
#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNDataManager.h"
#import "PNConnection.h"
#import "PNNotifications.h"
#import "PNChannel.h"
#import "Swizzler.h"

@interface W_ChaosTest () <PNDelegate>
{
	BOOL connectedFinish;
	NSArray *pnChannels;
	BOOL subscribeOnChannelsFinish;
	BOOL participantsListForChannelFinish;
	BOOL notifyDidDisconnectWithErrorCalled;
}
@end

@implementation W_ChaosTest

-(NSNumber *)shouldReconnectPubNubClient:(id)object {
	return [NSNumber numberWithBool: YES];
}

- (void)handleConnectionErrorOnNetworkFailure {
	PNLog(PNLogGeneralLevel, nil, @"handleConnectionErrorOnNetworkFailure");
//	dispatch_semaphore_signal(semaphore);
	connectedFinish = YES;
}

- (void)handleConnectionErrorOnNetworkFailureWithError:(PNError *)error {
	PNLog(PNLogGeneralLevel, nil, @"handleConnectionErrorOnNetworkFailure: %@", error);
//	dispatch_semaphore_signal(semaphore);
	connectedFinish = YES;
}


//- (void)notifyDelegateClientWillDisconnectWithError:(PNError *)error {
//	PNLog(PNLogGeneralLevel, nil, @"notifyDelegateClientWillDisconnectWithError %@", error);
//}

- (void)notifyDelegateClientDidDisconnectWithError:(PNError *)error {
	PNLog(PNLogGeneralLevel, nil, @"notifyDelegateClientDidDisconnectWithError %@", error);
	notifyDidDisconnectWithErrorCalled = YES;
}


- (void)handleClientConnectionStateChange:(NSNotification *)notification {
    // Default field values
	connectedFinish = YES;
    BOOL connected = YES;
    PNError *connectionError = nil;
    NSString *origin = [PubNub sharedInstance].configuration.origin;

    if([notification.name isEqualToString:kPNClientDidConnectToOriginNotification] ||
       [notification.name isEqualToString:kPNClientDidDisconnectFromOriginNotification]) {

        origin = (NSString *)notification.userInfo;
        connected = [notification.name isEqualToString:kPNClientDidConnectToOriginNotification];
    }
    else if([notification.name isEqualToString:kPNClientConnectionDidFailWithErrorNotification]) {

        connected = NO;
        connectionError = (PNError *)notification.userInfo;
    }
}



-(void)setUp {
    [super setUp];
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

	[notificationCenter addObserver:self
						   selector:@selector(handleClientConnectionStateChange:)
							   name:kPNClientDidConnectToOriginNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientConnectionStateChange:)
							   name:kPNClientDidDisconnectFromOriginNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientConnectionStateChange:)
							   name:kPNClientConnectionDidFailWithErrorNotification
							 object:nil];
}

- (void)test10ConnectionChaos {
//	semaphore = dispatch_semaphore_create(0);
//	pnChannels = [PNChannel channelsWithNames:@[@"iosdev", @"andoirddev"]];
    [PubNub setDelegate:self];
	[PubNub disconnect];
	for( int i=0; (i<100/*[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1*/ &&
		notifyDidDisconnectWithErrorCalled == NO) && ([PubNub sharedInstance].isConnected == YES); i++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertFalse( [PubNub sharedInstance].isConnected, @"[PubNub sharedInstance].isConnected");

	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"chaos.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil];
	//	configuration.autoReconnectClient = NO;
	[PubNub setConfiguration: configuration];

	connectedFinish = NO;
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
		connectedFinish = YES;
        PNLog(PNLogGeneralLevel, nil, @"{BLOCK} PubNub client connected to: %@", origin);
    }
		 errorBlock:^(PNError *connectionError) {
			 PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
			 connectedFinish = YES;
	 }];
	for( int i=0; (i<320 && connectedFinish == NO); i++ ) {
		NSLog(@"Waiting to connectedFinish... %d", i);
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	}
	STAssertTrue( connectedFinish, @"conectedFinish must be YES");
}
//
//- (void)test10ConnectionChaos
//{
//	[PubNub disconnect];
//	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"chaos.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil];
////	configuration.autoReconnectClient = NO;
//	[PubNub setConfiguration: configuration];
//
////    semaphore = dispatch_semaphore_create(0);
//	conectedFinish = NO;
//
//    [PubNub connectWithSuccessBlock:^(NSString *origin) {
//
//        PNLog(PNLogGeneralLevel, nil, @"{BLOCK} PubNub client connected to: %@", origin);
//		conectedFinish = YES;
//		STFail(@"Client should not connect to %@", origin);
////        dispatch_semaphore_signal(semaphore);
//    }
//		 errorBlock:^(PNError *connectionError) {
//			 PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
//			 conectedFinish = YES;
////			 dispatch_semaphore_signal(semaphore);
//		STFail(@"Client should not return any error, error %@", connectionError);
//	}];
//	for( int i=0; i<10 && conectedFinish == NO; i++ )
//		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
//	STAssertFalse( conectedFinish, @"conectedFinish must be YES");
//}
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to subscribe because of error: %@", error);
	subscribeOnChannelsFinish = YES;
}

- (void)test20SubscribeOnChannels
{
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	subscribeOnChannelsFinish = NO;
	[PubNub subscribeOnChannels: pnChannels withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 subscribeOnChannelsFinish = YES;
	 }];
	for( int j=0; j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1 &&
		subscribeOnChannelsFinish == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( subscribeOnChannelsFinish, @"subscribeOnChannelsFinish must be YES");
}

//nonSubscriptionRequestTimeout
- (void)pubnubClient:(PubNub *)client didFailParticipantsListDownloadForChannel:(PNChannel *)channel withError:(PNError *)error {
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download participants list for channel %@ because of error: %@",
          channel, error);
	participantsListForChannelFinish = YES;
}
- (void)test30ParticipantsListForChannel
{
	participantsListForChannelFinish = NO;
	PNChannel *channel = [PNChannel channelsWithNames: @[@"channel"]][0];
	[PubNub requestParticipantsListForChannel: channel
						  withCompletionBlock: ^(NSArray *udids, PNChannel *channel, PNError *error)
	 {
		 participantsListForChannelFinish = YES;
	 }];
	for( int j=0; j<[PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout+1 &&
		participantsListForChannelFinish == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	STAssertTrue( participantsListForChannelFinish, @"subscribeOnChannelsFinish must be YES");
}

@end
