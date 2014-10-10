//
//  PNChannelPresenceTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNChannelPresence+Protected.h"
#import "PNChannelPresence.h"


@interface PNChannelPresence (test)

- (BOOL)isPresenceObserver;

@end

@interface PNChannelPresenceTest : XCTestCase {
	NSString *name;
	NSString *namePresence;
}

@end

@implementation PNChannelPresenceTest

-(void)setUp {
    [super setUp];
    
	name = @"channel1";
	namePresence = @"channel1-pnpres";
}

-(void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
    [super tearDown];
}

-(void)testPresenceForChannel {
	PNChannel *channel = [PNChannel channelWithName: name];
	PNChannelPresence *presence = [PNChannelPresence presenceForChannel: channel];
	XCTAssertTrue( [presence isKindOfClass: [PNChannelPresence class]] == YES, @"");
	XCTAssertTrue( [presence.name isEqualToString: namePresence] == YES, @"");

	channel = [PNChannel channelWithName: namePresence];
	presence = [PNChannelPresence presenceForChannel: channel];
	XCTAssertTrue( [presence isKindOfClass: [PNChannelPresence class]] == YES, @"");
	XCTAssertTrue( [presence.name isEqualToString: namePresence] == YES, @"");
}

-(void)testPresenceForChannelWithName {
	PNChannelPresence *presence = [PNChannelPresence presenceForChannelWithName: name];
	XCTAssertTrue( [presence isKindOfClass: [PNChannelPresence class]] == YES, @"");
	XCTAssertTrue( [presence.name isEqualToString: namePresence] == YES, @"");

	presence = [PNChannelPresence presenceForChannelWithName: namePresence];
	XCTAssertTrue( [presence isKindOfClass: [PNChannelPresence class]] == YES, @"");
	XCTAssertTrue( [presence.name isEqualToString: namePresence] == YES, @"");
}

-(void)testIsPresenceObservingChannelName {
	XCTAssertTrue( [PNChannelPresence isPresenceObservingChannelName: name] == NO, @"");
	XCTAssertTrue( [PNChannelPresence isPresenceObservingChannelName: namePresence] == YES, @"");
}

-(void)testPresenceChannelsFromArray {
	PNChannel *channel = [PNChannel channelWithName: name];
	PNChannel *channelPresence = [PNChannel channelWithName: namePresence];
	NSArray *arr = [PNChannelPresence presenceChannelsFromArray: @[channel, channelPresence]];
	XCTAssertTrue( arr.count == 1, @"");
	XCTAssertTrue( arr[0] == channelPresence, @"");
}

-(void)testObservedChannel {
	PNChannelPresence *presence = [PNChannelPresence presenceForChannelWithName: namePresence];
	PNChannel *channel = [presence observedChannel];
	XCTAssertEqualObjects( channel.name, name, @"");
}

-(void)testIsPresenceObserver {
	PNChannelPresence *presence = [PNChannelPresence presenceForChannelWithName: namePresence];
	XCTAssertTrue( [presence isPresenceObserver] == YES, @"" );
}

@end
