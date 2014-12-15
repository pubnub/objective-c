//
//  AbbreviatedPresenceTest.m
//  pubnub
//
//  Created by Valentin Tuller on 10/23/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//
/* Test descripition:
 This test should work only when Presence and Access Manager features
 enabled for developer account.
 
 It should check following scenario:
  - connect to pubsub; For configuration we setup 20 sec as a presence heartbeat timeout;
  - grant all access rights;
  - subscribe to channes with observing events
  - check that we receive two Presence events: join and timeout
 */

// TODO: it should be moved to Functional test suite

#import <XCTest/XCTest.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNClient.h"
#import "PNPresenceEvent.h"
#import "GCDWrapper.h"

static NSUInteger const kTestTimout = 60;
static NSUInteger const kTestPresenceHeartbeatTimeout = 20;

@interface AbbreviatedPresenceTest : XCTestCase <PNDelegate> {
	dispatch_group_t _resGroup;
}

@end

@implementation AbbreviatedPresenceTest

- (void)setUp
{
    [super setUp];
    [PubNub setDelegate:self];
    
    _resGroup = dispatch_group_create();

	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self
						   selector:@selector(handleClientDidReceivePresenceEvent:)
							   name:kPNClientDidReceivePresenceEventNotification
							 object:nil];
}

- (void)testAbbreviatedPresence
{
	[PubNub disconnect];

	[PubNub setDelegate:self];
    
    // Vadim's keys
	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:kTestPNOriginHost publishKey:kTestPNPublishKey subscribeKey:kTestPNSubscriptionKey

                                                                   secretKey:kTestPNSecretKey cipherKey: nil];
    
    configuration.presenceHeartbeatTimeout = kTestPresenceHeartbeatTimeout;
    
	[PubNub setConfiguration:configuration];

    dispatch_group_enter(_resGroup);

	[PubNub connectWithSuccessBlock:^(NSString *origin) {

		NSLog(@"\n\n\n\n\n\n\n{BLOCK} PubNub client connected to: %@", origin);
        
        dispatch_group_leave(_resGroup);
	} errorBlock:^(PNError *connectionError) {
							 NSLog(@"connectionError %@", connectionError);
							 XCTFail(@"connectionError %@", connectionError);
                             dispatch_group_leave(_resGroup);
    }];

    if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:30]) {
        XCTFail(@"Timeout received");
    }
    
    dispatch_group_enter(_resGroup);
    
	[PubNub grantAllAccessRightsForApplicationAtPeriod:10 andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		XCTAssertNil( error, @"grantAllAccessRightsForApplicationAtPeriod %@", error);
        dispatch_group_leave(_resGroup);
	}];
    
    if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:30]) {
        XCTFail(@"Timeout received");
    }
    
	BOOL isConnect = [[PubNub sharedInstance] isConnected];
	XCTAssertTrue( isConnect, @"not connected");

    dispatch_group_enter(_resGroup);
    
    // we are expecting two presence events:
    // join and timeout
    dispatch_group_enter(_resGroup);
    dispatch_group_enter(_resGroup);
    
	[PubNub subscribeOnChannels: @[[PNChannel channelWithName: @"zzz" shouldObservePresence: YES shouldUpdatePresenceObservingFlag: YES]]
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
            
            NSLog(@"channels: %@", channels);
            dispatch_group_leave(_resGroup);
	 }];

    if ([GCDWrapper isGroup:_resGroup timeoutFiredValue:kTestTimout]) {
        XCTFail(@"Timeout received");
    }
}

- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification {
    // Retrieve reference on presence event which was received
	NSLog(@"clientDidReceivePresenceEvent %@", notification);
    
    PNPresenceEvent *event = (PNPresenceEvent *)notification.userInfo;
    
        if (event.type == PNPresenceEventJoin) {
            dispatch_group_leave(_resGroup);
        } else if (event.type == PNPresenceEventTimeout) {
            dispatch_group_leave(_resGroup);
        }
}

@end
