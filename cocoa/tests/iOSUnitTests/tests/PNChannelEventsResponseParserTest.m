//
//  PNChannelEventsResponseParserTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/23/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNChannelEventsResponseParser.h"
#import "PNChannelEvents.h"
#import "PNPresenceEvent+Protected.h"
#import "PNPresenceEvent.h"
#import "PNResponse.h"
#import "PNChannel.h"

@interface PNChannel (test)

- (BOOL)isPresenceObserver;

@end


@interface PNChannelEventsResponseParser (test)

@property (nonatomic, strong) PNChannelEvents *events;
- (id)initWithResponse:(PNResponse *)response;

@end

@interface PNResponse (test)

@property (nonatomic, strong) id response;

@end

@interface PNChannelEventsResponseParserTest : SenTestCase

@end

@implementation PNChannelEventsResponseParserTest

-(void)setUp {
    [super setUp];
}

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testInit {
	NSMutableDictionary *eventDic = [NSMutableDictionary dictionary];
	[eventDic setObject: [NSNumber numberWithInt: 123] forKey: @"timestamp"];
	[eventDic setObject: @"uuid" forKey: @"uuid"];
	[eventDic setObject: [NSNumber numberWithInt: 100] forKey: @"occupancy"];
	[eventDic setObject: @"leave" forKey: @"action"];

	PNResponse *response = [[PNResponse alloc] init];
	response.response = @[ @[eventDic], @"123", @"ch1,ch2" ];
	PNChannelEventsResponseParser *parser = [[PNChannelEventsResponseParser alloc] initWithResponse: response];

	STAssertTrue( [parser.events.timeToken intValue] == 123, @"");
	STAssertTrue( parser.events.events.count == 1, @"");
	PNPresenceEvent *event = parser.events.events[0];
	STAssertTrue( event.type == PNPresenceEventLeave, @"");
	STAssertTrue( [event.date.timeToken intValue] == 123, @"");
	STAssertTrue( [event.uuid isEqualToString: @"uuid"], @"");
	STAssertTrue( event.occupancy == 100, @"");
	STAssertTrue( [event.channel.name isEqualToString: @"ch1"] == TRUE, @"");


	STAssertTrue( [parser parsedData] == parser.events && parser.events != nil, @"");
}



@end



