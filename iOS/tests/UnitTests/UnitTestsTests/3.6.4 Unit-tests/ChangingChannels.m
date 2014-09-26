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

#pragma mark - Tests

- (void)testConnect {
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
    
    if ([GCDWrapper isGroup:resGroup timeoutFiredValue:30]) {
        XCTFail(@"Timeout.");
    }

	BOOL isConnect = [[PubNub sharedInstance] isConnected];
	XCTAssertTrue( isConnect, @"not connected");

	[self subscribeToNumberOfChannels:2];
}

-(void)subscribeToNumberOfChannels:(NSUInteger)amountOfChannels {
    
    dispatch_group_t resGroup = dispatch_group_create();
    
	for(int i = 0; i < amountOfChannels; i++) {
        
		NSString *channelName = [NSString stringWithFormat: @"%@ %d", [NSDate date], i];
		NSArray *channels = [PNChannel channelsWithNames:@[channelName]];
        
		NSLog(@"Start subscribe to channel %@", channelName);
        
        dispatch_group_enter(resGroup);
        
        // subscription time cannot be more than subscriptionRequestTimeout
        
        NSDate *startDate = [NSDate date];
        
		[PubNub subscribeOnChannels:channels
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
             NSDate *finishDate = [NSDate date];
             
			 NSTimeInterval interval = [finishDate timeIntervalSinceDate:startDate];
			 NSLog(@"Subscribed %f, %@, %@", interval, channels, subscriptionError);
             
			 XCTAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout, @"Timeout error, %f instead of %f", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

			 if( subscriptionError == nil ) {
                 
				 XCTAssertNil( subscriptionError, @"subscriptionError %@", subscriptionError);
                 
				 BOOL isSubscribed = NO;
				 for( int j = 0; j < channels.count; j++ ) {
					 if ( [[channels[j] name] isEqualToString:channelName] == YES ) {
						 isSubscribed = YES;
						 break;
					 }
				 }
                 
				 XCTAssertTrue( isSubscribed == YES, @"Channel is not subscribed");
			 }
             
             dispatch_group_leave(resGroup);
		 }];
	}
    
    if ([GCDWrapper isGroup:resGroup timeoutFiredValue:120]) {
        XCTFail(@"Timeout fired.");
    }
}

@end
