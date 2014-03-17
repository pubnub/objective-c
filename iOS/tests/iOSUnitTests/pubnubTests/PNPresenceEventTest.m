//
//  PNPresenceEventTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNPresenceEvent+Protected.h"
#import "PNPresenceEvent.h"
#import "PNClient.h"
#import "PNDate.h"

@interface PNPresenceEventTest : SenTestCase

@end

@implementation PNPresenceEventTest

-(void)setUp {
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

-(void)tearDown {
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testPresenceEventForResponse {
	NSMutableDictionary *presenceResponse = [NSMutableDictionary dictionary];
	[presenceResponse setObject: [NSNumber numberWithInt: 123] forKey: @"timestamp"];
	[presenceResponse setObject: @"uuid" forKey: @"uuid"];
	[presenceResponse setObject: [NSNumber numberWithInt: 100] forKey: @"occupancy"];

	[presenceResponse setObject: @"leave" forKey: @"action"];

	PNPresenceEvent *event = [PNPresenceEvent presenceEventForResponse: presenceResponse];
	STAssertTrue( event.type == PNPresenceEventLeave, @"");
	STAssertTrue( [event.date.timeToken intValue] == 123, @"");
	STAssertTrue( [event.client.identifier isEqualToString: @"uuid"], @"");
	STAssertTrue( event.occupancy == 100, @"");
}

-(void)testInitWithResponse {
	NSMutableDictionary *presenceResponse = [NSMutableDictionary dictionary];
	[presenceResponse setObject: [NSNumber numberWithInt: 123] forKey: @"timestamp"];
	[presenceResponse setObject: @"uuid" forKey: @"uuid"];
	[presenceResponse setObject: [NSNumber numberWithInt: 100] forKey: @"occupancy"];

	[presenceResponse setObject: @"leave" forKey: @"action"];

	PNPresenceEvent *event = [[PNPresenceEvent alloc] initWithResponse: presenceResponse];
	STAssertTrue( event.type == PNPresenceEventLeave, @"");
	STAssertTrue( [event.date.timeToken intValue] == 123, @"");
	STAssertTrue( [event.client.identifier isEqualToString: @"uuid"], @"");
	STAssertTrue( event.occupancy == 100, @"");
}

-(void)testIsPresenceEventObject {
	NSMutableDictionary *presenceResponse = [NSMutableDictionary dictionary];
	[presenceResponse setObject: [NSNumber numberWithInt: 123] forKey: @"timestamp"];
	[presenceResponse setObject: [NSNumber numberWithInt: 100] forKey: @"occupancy"];
	STAssertTrue( [PNPresenceEvent isPresenceEventObject: presenceResponse] == YES, @"");
}

@end
