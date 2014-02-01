//
//  PNChannelTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNChannel.h"
#import "PNChannel+Protected.h"
#import <OCMock/OCMock.h>
#import "PNChannelPresence.h"
#import "PNChannelPresence+Protected.h"
#import "PNChannelPresence.h"
#import "PNPresenceEvent+Protected.h"
#import "PNPresenceEvent.h"
#import "PNHereNow.h"
#import "PNHereNow+Protected.h"

@interface PNChannel (test)

@property (nonatomic, strong) NSMutableArray *participantsList;
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

@end



@interface PNChannelTest : SenTestCase {
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
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testChannelsWithNames {
	channels = [PNChannel channelsWithNames: names];
	STAssertTrue( channels.count == names.count, @"");
	for( int i=0; i<names.count; i++ ) {
		STAssertTrue( [[channels objectAtIndex: i] isKindOfClass: [PNChannel class]] == YES, @"" );
		STAssertTrue( [[[channels objectAtIndex: i] name] isEqualToString: names[i]] == YES, @"" );
	}
}

-(void)testChannelWithName {
	PNChannel *ch = [PNChannel channelWithName: namePresence];
	STAssertTrue( ch.linkedWithPresenceObservationChannel == YES, @"");

	ch = [PNChannel channelWithName: name];
	STAssertTrue( ch.linkedWithPresenceObservationChannel == NO, @"");
}

-(void)testChannelWithNameShouldUpdatePresenceObservingFlag {
	NSDictionary *cache = [PNChannel channelsCache];
	STAssertNotNil( cache, @"");
	PNChannel *ch = [PNChannel channelWithName: namePresence shouldObservePresence: YES shouldUpdatePresenceObservingFlag: YES];
	STAssertTrue( cache[namePresence] == ch, @"");
	STAssertTrue( ch.observePresence = TRUE, @"");
	STAssertTrue( [[ch presenceObserver] isKindOfClass: [PNChannelPresence class]], @"");

	[PNChannel purgeChannelsCache];
	STAssertTrue( [[PNChannel channelsCache] count] == 0, @"");

    ch = [PNChannel channelWithName: name shouldObservePresence: NO shouldUpdatePresenceObservingFlag: YES];
	STAssertNil( [ch presenceObserver], @"");
}

-(void)testLargestTimetokenFromChannels {
	STAssertEqualObjects( [PNChannel largestTimetokenFromChannels: channels], @"0", @"");
	[channels[3] setUpdateTimeToken: @"123"];
	STAssertEqualObjects( [PNChannel largestTimetokenFromChannels: channels], @"123", @"");
}

-(void)testInitWithName {
	PNChannel *ch = [[PNChannel alloc] initWithName: name];
	STAssertEqualObjects( ch.updateTimeToken, @"0", @"");
	STAssertEqualObjects( ch.name, name, @"");
	STAssertTrue( [[ch participantsList] isKindOfClass: [NSMutableArray class]] == TRUE, @"");
}

-(void)testObservedChannel {
	STAssertEquals( channel, [channel observedChannel], @"");
}

-(void)testSetUpdateTimeToken {
	channel.ableToResetTimeToken = NO;
	[channel setUpdateTimeToken: @"123"];
	STAssertEqualObjects( channel.updateTimeToken, @"0", @"");

	channel.ableToResetTimeToken = YES;
	[channel setUpdateTimeToken: @"123"];
	STAssertEqualObjects( channel.updateTimeToken, @"123", @"");
}

-(void)testResetUpdateTimeToken {
	channel.ableToResetTimeToken = YES;
	[channel setUpdateTimeToken: @"123"];
	STAssertEqualObjects( channel.updateTimeToken, @"123", @"");

	channel.ableToResetTimeToken = NO;
	[channel resetUpdateTimeToken];
	STAssertEqualObjects( channel.updateTimeToken, @"123", @"");

	channel.ableToResetTimeToken = YES;
	[channel resetUpdateTimeToken];
	STAssertEqualObjects( channel.updateTimeToken, @"0", @"");
}

-(void)testTimeTokenChangeLocked {
	[channel lockTimeTokenChange];
	STAssertTrue( [channel isTimeTokenChangeLocked] == YES, @"");
	[channel unlockTimeTokenChange];
	STAssertTrue( [channel isTimeTokenChangeLocked] == NO, @"");
}

-(void)testParticipants {
	STAssertEquals( [channel participants], [channel participantsList], @"");
}

-(void)testUpdateWithEvent {
	PNPresenceEvent *event = [[PNPresenceEvent alloc] init];
	event.occupancy = 3;
	event.uuid = @"udid";

	event.type = PNPresenceEventJoin;
	[channel updateWithEvent: event];
	STAssertTrue( [channel.participantsList indexOfObject: event.uuid] != NSNotFound, @"");

	event.type = PNPresenceEventChanged;
	event.occupancy = 300;
	[channel updateWithEvent: event];
	STAssertTrue( [channel.participantsList indexOfObject: @"unknown"] != NSNotFound, @"");

	event.type = PNPresenceEventChanged;
	event.occupancy = 1;
	[channel updateWithEvent: event];
	STAssertTrue( [channel.participantsList indexOfObject: @"unknown"] == NSNotFound, @"");

	event.type = PNPresenceEventLeave;
	[channel updateWithEvent: event];
	STAssertTrue( [channel.participantsList indexOfObject: event.uuid] == NSNotFound, @"");

	STAssertEqualsWithAccuracy( [[channel.presenceUpdateDate date] timeIntervalSinceNow], 0.0, 1, @"");
}

-(void)testUpdateWithParticipantsList {
	PNHereNow *hereNow = [[PNHereNow alloc] init];
	hereNow.participantsCount = 10;
	hereNow.participants = @[@"participant"];
	[channel updateWithParticipantsList: hereNow];

	STAssertEqualsWithAccuracy( [[channel.presenceUpdateDate date] timeIntervalSinceNow], 0.0, 1, @"");
	STAssertEquals( channel.participantsCount, hereNow.participantsCount, @"");
	STAssertTrue( [channel.participantsList indexOfObject: @"participant"] != NSNotFound, @"");
	STAssertTrue( channel.participantsList.count == 1, @"");
}

-(void)testEscapedName {
	STAssertTrue( [channel escapedName] != nil, @"");
}

-(void)testIsPresenceObserver {
	STAssertTrue( [channel isPresenceObserver] == NO, @"");
}

@end
