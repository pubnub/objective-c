//
//  CatchupTest.m
//  pubnub
//
//  Created by Valentin Tuller on 10/21/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNNotifications.h"


@interface CatchupTest : XCTestCase <PNDelegate> {
	NSArray *_pnChannels;
	BOOL isPNClientDidReceivePresenceEventNotification;
	BOOL isHandleClientPresenceObservationEnablingProcess;
}

@end

@implementation CatchupTest

- (void)tearDown {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [PubNub disconnect];
    
    [super tearDown];
}

- (void)setUp
{
    [super setUp];
    
    [PubNub setDelegate:self];
    NSMutableArray *channelNames = [NSMutableArray arrayWithArray:@[[NSString stringWithFormat: @"%@", [NSDate date]]]];
    [[channelNames copy] enumerateObjectsUsingBlock:^(NSString *channelName,
                                                      NSUInteger channelNameIdx,
                                                      BOOL *channelNameEnumeratorStop) {
        
        if ([channelName rangeOfString:@":"].location != NSNotFound) {
            
            [channelNames replaceObjectAtIndex:channelNameIdx
                                    withObject:[channelName stringByReplacingOccurrencesOfString:@":" withString:@"-"]];
        }
    }];
    
	_pnChannels = [PNChannel channelsWithNames:channelNames];

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

	[notificationCenter addObserver:self
						   selector:@selector(handleClientPresenceObservationEnablingProcess:)
							   name:kPNClientPresenceEnablingDidCompleteNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientPresenceObservationEnablingProcess:)
							   name:kPNClientPresenceEnablingDidFailNotification
							 object:nil];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientDidReceivePresenceEvent:)
							   name:kPNClientDidReceivePresenceEventNotification
							 object:nil];

}

- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification {
    NSLog(@"NSNotification handleClientDidReceivePresenceEvent: %@", notification);
	isPNClientDidReceivePresenceEventNotification = YES;
}

- (void)handleClientPresenceObservationEnablingProcess:(NSNotification *)notification {
    NSLog(@"NSNotification handleClientPresenceObservationEnablingProcess: %@", notification);
	isHandleClientPresenceObservationEnablingProcess = YES;
}


- (void)test10Connect
{
    GCDGroup *resGroup = [GCDGroup group];
    
    [resGroup enter];
    
    [PubNub setDelegate:self];
    PNConfiguration *configuration = [PNConfiguration defaultTestConfiguration];
    [PubNub setConfiguration:configuration];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        [resGroup leave];
    } errorBlock:^(PNError *connectionError) {
        XCTFail(@"connectionError %@", connectionError);
    }];
    
    if ([GCDWrapper isGCDGroup:resGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout fired during connect");
        resGroup = nil;
        
        return;
    }
    
    [resGroup enter];

	[PubNub subscribeOn:_pnChannels
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
         [resGroup leave];
		 XCTAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
		 XCTAssertEqualObjects( @(_pnChannels.count), @(channels.count), @"pnChannels.count %lu, channels.count %lu", (unsigned long)_pnChannels.count, (unsigned long)channels.count);
	 }];
    
    if ([GCDWrapper isGCDGroup:resGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout fired during connect");
    }
    
    resGroup = nil;
}

-(void)test20Catchup {
	NSString *clientIdentifier = [NSString stringWithFormat: @"%@", [NSDate date]];
    
	isPNClientDidReceivePresenceEventNotification = NO;
	isHandleClientPresenceObservationEnablingProcess = NO;
    
    [PubNub setClientIdentifier:clientIdentifier shouldCatchup:YES];

    [GCDWrapper sleepForSeconds:5];
    
    XCTAssertFalse( isPNClientDidReceivePresenceEventNotification, @"notification DidReceivePresence must should not come");
    XCTAssertFalse( isHandleClientPresenceObservationEnablingProcess, @"notification HandleClientPresence must should not come");
    NSString *newIdentifier = [PubNub clientIdentifier];
    XCTAssertEqualObjects( clientIdentifier, newIdentifier, @"identifiers must be equal");
}

@end
