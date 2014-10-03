//
//  PNChannelTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNChannel.h"
#import "PNChannel+Protected.h"
#import "PNChannelPresence.h"
#import "PNChannelPresence+Protected.h"
#import "PNChannelPresence.h"
#import "PNPresenceEvent+Protected.h"
#import "PNPresenceEvent.h"
#import "PNHereNow.h"
#import "PNHereNow+Protected.h"
#import "PNClient+Protected.h"
#import "PNClient.h"

@interface PNChannel (test)

@property (nonatomic, strong) NSMutableDictionary *participantsList;
@property (nonatomic, assign, getter = isAbleToResetTimeToken) BOOL ableToResetTimeToken;

+ (NSDictionary *)channelsCache;
+ (void)purgeChannelsCache;
- (id)initWithName:(NSString *)channelName;
- (PNChannel *)observedChannel;

@end



@interface PNPresenceEvent (test)

@property (nonatomic, assign) NSUInteger occupancy;
@property (nonatomic, assign) PNPresenceEventType type;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) PNClient *client;

@end



@interface PNChannelTest : XCTestCase {
	NSArray *channels;
	NSArray *names;
	PNChannel *channel;
	NSString *name;
	NSString *namePresence;
}

@end

@implementation PNChannelTest

-(void)setUp {
    [super setUp];
	name = @"channel1";
	namePresence = @"channel1-pnpres";
    channel = [PNChannel channelWithName: name shouldObservePresence: YES shouldUpdatePresenceObservingFlag: YES];
	names = @[@"ch1", @"ch2", @"ch3", @"ch4", @"ch5"];
	channels = [PNChannel channelsWithNames: names];
}

-(void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
    [super tearDown];
}

-(void)testChannelsWithNames {
	channels = [PNChannel channelsWithNames: names];
	XCTAssertTrue( channels.count == names.count, @"");
	for( int i=0; i<names.count; i++ ) {
		XCTAssertTrue( [[channels objectAtIndex: i] isKindOfClass: [PNChannel class]] == YES, @"" );
		XCTAssertTrue( [[[channels objectAtIndex: i] name] isEqualToString: names[i]] == YES, @"" );
	}
}

-(void)testChannelWithName {
	PNChannel *ch = [PNChannel channelWithName: namePresence];
	XCTAssertTrue( ch.linkedWithPresenceObservationChannel == YES, @"");

	ch = [PNChannel channelWithName: name];
	XCTAssertTrue( ch.linkedWithPresenceObservationChannel == NO, @"");
}

-(void)testChannelWithNameShouldUpdatePresenceObservingFlag {
	NSDictionary *cache = [PNChannel channelsCache];
	XCTAssertNotNil( cache, @"");
	PNChannel *ch = [PNChannel channelWithName: namePresence shouldObservePresence: YES shouldUpdatePresenceObservingFlag: YES];
	XCTAssertTrue( cache[namePresence] == ch, @"");
	XCTAssertTrue( ch.observePresence = TRUE, @"");
	XCTAssertTrue( [[ch presenceObserver] isKindOfClass: [PNChannelPresence class]], @"");

	[PNChannel purgeChannelsCache];
	XCTAssertTrue( [[PNChannel channelsCache] count] == 0, @"");

    ch = [PNChannel channelWithName: name shouldObservePresence: NO shouldUpdatePresenceObservingFlag: YES];
	XCTAssertNil( [ch presenceObserver], @"");
}

-(void)testLargestTimetokenFromChannels {
	XCTAssertEqualObjects( [PNChannel largestTimetokenFromChannels: channels], @"0", @"");
	[channels[3] setUpdateTimeToken: @"123"];
	XCTAssertEqualObjects( [PNChannel largestTimetokenFromChannels: channels], @"123", @"");
}

-(void)testInitWithName {
	PNChannel *ch = [[PNChannel alloc] initWithName: name];
	XCTAssertEqualObjects( ch.updateTimeToken, @"0", @"");
	XCTAssertEqualObjects( ch.name, name, @"");
	XCTAssertTrue( [[ch participantsList] isKindOfClass: [NSMutableDictionary class]] == TRUE, @"");
}

-(void)testObservedChannel {
	XCTAssertEqualObjects( channel, [channel observedChannel], @"");
}

-(void)testSetUpdateTimeToken {
	channel.ableToResetTimeToken = NO;
	[channel setUpdateTimeToken: @"123"];
	XCTAssertEqualObjects( channel.updateTimeToken, @"0", @"");

	channel.ableToResetTimeToken = YES;
	[channel setUpdateTimeToken: @"123"];
	XCTAssertEqualObjects( channel.updateTimeToken, @"123", @"");
}

-(void)testResetUpdateTimeToken {
	channel.ableToResetTimeToken = YES;
	[channel setUpdateTimeToken: @"123"];
	XCTAssertEqualObjects( channel.updateTimeToken, @"123", @"");

	channel.ableToResetTimeToken = NO;
	[channel resetUpdateTimeToken];
	XCTAssertEqualObjects( channel.updateTimeToken, @"123", @"");

	channel.ableToResetTimeToken = YES;
	[channel resetUpdateTimeToken];
	XCTAssertEqualObjects( channel.updateTimeToken, @"0", @"");
}

-(void)testTimeTokenChangeLocked {
	[channel lockTimeTokenChange];
	XCTAssertTrue( [channel isTimeTokenChangeLocked] == YES, @"");
	[channel unlockTimeTokenChange];
	XCTAssertTrue( [channel isTimeTokenChangeLocked] == NO, @"");
}

-(void)testParticipants {
	XCTAssertTrue( [[channel participants] isEqualToArray: [[channel participantsList] allValues]], @"");
}

-(void)testUpdateWithEvent {
	PNPresenceEvent *event = [[PNPresenceEvent alloc] init];
	event.occupancy = 3;
	PNClient *client = [[PNClient alloc] initWithIdentifier: @"id" channel: nil andData: nil];
	event.client = client;
	event.type = PNPresenceEventJoin;
	[channel updateWithEvent: event];
	XCTAssertTrue( [channel.participantsList objectForKey: event.client.identifier] == client, @"");

	event.type = PNPresenceEventChanged;
	event.occupancy = 300;
	[channel updateWithEvent: event];
	XCTAssertTrue( [channel.participantsList count] == 2, @"");

	event.type = PNPresenceEventChanged;
	event.occupancy = 1;
	[channel updateWithEvent: event];
	XCTAssertTrue( [channel.participantsList count] == 1, @"");

	event.type = PNPresenceEventLeave;
	[channel updateWithEvent: event];
	XCTAssertTrue( [channel.participantsList objectForKey: event.client.identifier] == nil, @"");
	XCTAssertEqualWithAccuracy( [[channel.presenceUpdateDate date] timeIntervalSinceNow], 0.0, 1, @"");
}

-(void)testUpdateWithParticipantsList {
	PNHereNow *hereNow = [[PNHereNow alloc] init];
	hereNow.participantsCount = 10;
	PNClient *client = [[PNClient alloc] initWithIdentifier: @"id" channel: nil andData: nil];
	hereNow.participants = @[client];
	[channel updateWithParticipantsList: hereNow];

	XCTAssertEqualWithAccuracy( [[channel.presenceUpdateDate date] timeIntervalSinceNow], 0.0, 1, @"");
	XCTAssertTrue( channel.participantsCount == hereNow.participantsCount, @"");
	XCTAssertTrue( channel.participantsList.count == 1, @"");
}

-(void)testEscapedName {
	XCTAssertTrue( [channel escapedName] != nil, @"");
}

-(void)testIsPresenceObserver {
	XCTAssertTrue( [channel isPresenceObserver] == NO, @"");
}

@end
