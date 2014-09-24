//
//  ChangingChannels.m
//  pubnub
//
//  Created by Valentin Tuller on 10/21/13.
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


#import <XCTest/XCTest.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"

@interface ChangingChannels : XCTestCase <PNDelegate>

@end

@implementation ChangingChannels

- (void)setUp
{
    [super setUp];
    [PubNub setDelegate:self];
}

- (void)tearDown {
	[super tearDown];
}

- (void)test10Connect {
	[PubNub disconnect];

    [PubNub setDelegate:self];
    
    dispatch_group_t resGroup = dispatch_group_create();
    
    dispatch_group_enter(resGroup);
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"demo" subscribeKey:@"demo" secretKey: nil cipherKey: nil];
    [PubNub setConfiguration: configuration];

    [PubNub connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, nil, @"\n\n\n\n\n\n\n{BLOCK} PubNub client connected to: %@", origin);
        dispatch_group_leave(resGroup);
    }
                         errorBlock:^(PNError *connectionError) {
                             PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
                             XCTFail(@"connectionError %@", connectionError);
                            dispatch_group_leave(resGroup);
                         }];
    
    [GCDWrapper waitGroup:resGroup];

	BOOL isConnect = [[PubNub sharedInstance] isConnected];
	XCTAssertTrue( isConnect, @"not connected");

	[self t20SubscribeOnChannelsByTurns];
}

-(void)t20SubscribeOnChannelsByTurns {
    
    dispatch_group_t resGroup = dispatch_group_create();
    
	for( int i = 0; i<90; i++ ) {
        
		NSString *channelName = [NSString stringWithFormat: @"%@ %d", [NSDate date], i];
		NSArray *arr = [PNChannel channelsWithNames: @[channelName]];
		NSDate *start = [NSDate date];
        
		NSLog(@"Start subscribe to channel %@", channelName);
        
        dispatch_group_enter(resGroup);
        
		[PubNub subscribeOnChannels: arr
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
			 NSTimeInterval interval = -[start timeIntervalSinceNow];
			 NSLog(@"subscribed %f, %@, %@", interval, channels, subscriptionError);
			 XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %d instead of %d", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

			 if( subscriptionError == nil ) {
				 XCTAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
				 BOOL isSubscribed = NO;
				 for( int j=0; j<channels.count; j++ ) {
					 if( [[channels[j] name] isEqualToString: channelName] == YES ) {
						 isSubscribed = YES;
						 break;
					 }
				 }
				 XCTAssertTrue( isSubscribed == YES, @"Channel no subecribed");
			 }
             
             dispatch_group_leave(resGroup);
		 }];
        
		XCTAssertTrue(![GCDWrapper isGroup:resGroup
                        timeoutFiredValue:[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1], @"timout fired.");
	}
}

@end
