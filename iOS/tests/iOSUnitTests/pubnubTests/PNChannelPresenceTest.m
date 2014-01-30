//
//  PNChannelPresenceTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNChannelPresence+Protected.h"
#import "PNChannelPresence.h"


@interface PNChannelPresence (test)

- (BOOL)isPresenceObserver;

@end

@interface PNChannelPresenceTest : SenTestCase {
//	PNChannelPresence *presence;
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
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testPresenceForChannel {
	PNChannel *channel = [PNChannel channelWithName: name];
	PNChannelPresence *presence = [PNChannelPresence presenceForChannel: channel];
	STAssertTrue( [presence isKindOfClass: [PNChannelPresence class]] == YES, @"");
	STAssertTrue( [presence.name isEqualToString: namePresence] == YES, @"");

	channel = [PNChannel channelWithName: namePresence];
	presence = [PNChannelPresence presenceForChannel: channel];
	STAssertTrue( [presence isKindOfClass: [PNChannelPresence class]] == YES, @"");
	STAssertTrue( [presence.name isEqualToString: namePresence] == YES, @"");
}

-(void)testPresenceForChannelWithName {
	PNChannelPresence *presence = [PNChannelPresence presenceForChannelWithName: name];
	STAssertTrue( [presence isKindOfClass: [PNChannelPresence class]] == YES, @"");
	STAssertTrue( [presence.name isEqualToString: namePresence] == YES, @"");

	presence = [PNChannelPresence presenceForChannelWithName: namePresence];
	STAssertTrue( [presence isKindOfClass: [PNChannelPresence class]] == YES, @"");
	STAssertTrue( [presence.name isEqualToString: namePresence] == YES, @"");
}

-(void)testIsPresenceObservingChannelName {
	STAssertTrue( [PNChannelPresence isPresenceObservingChannelName: name] == NO, @"");
	STAssertTrue( [PNChannelPresence isPresenceObservingChannelName: namePresence] == YES, @"");
}

-(void)testPresenceChannelsFromArray {
	PNChannel *channel = [PNChannel channelWithName: name];
	PNChannel *channelPresence = [PNChannel channelWithName: namePresence];
	NSArray *arr = [PNChannelPresence presenceChannelsFromArray: @[channel, channelPresence]];
	STAssertTrue( arr.count == 1, @"");
	STAssertTrue( arr[0] == channelPresence, @"");
}

-(void)testObservedChannel {
	PNChannelPresence *presence = [PNChannelPresence presenceForChannelWithName: namePresence];
	PNChannel *channel = [presence observedChannel];
	STAssertEqualObjects( channel.name, name, @"");
}

-(void)testIsPresenceObserver {
	PNChannelPresence *presence = [PNChannelPresence presenceForChannelWithName: namePresence];
	STAssertTrue( [presence isPresenceObserver] == YES, @"" );
}

@end
