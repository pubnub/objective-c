//
//  PNMessagesHistoryTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/27/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNMessagesHistory+Protected.h"
#import "PNMessagesHistory.h"

@interface PNMessagesHistory ()
- (id)initHistoryBetween:(PNDate *)startDate andEndDate:(PNDate *)endDate;
@end

@interface PNMessagesHistoryTest : SenTestCase

@end

@implementation PNMessagesHistoryTest

-(void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testHistoryBetween {
	PNDate *start = [PNDate dateWithToken: @(123)];
	PNDate *end = [PNDate dateWithToken: @(124)];
	PNMessagesHistory *history = [PNMessagesHistory historyBetween: start andEndDate: end];
	STAssertTrue( history.startDate == start, @"");
	STAssertTrue( history.endDate == end, @"");
}

-(void)testInitHistoryBetween {
	PNDate *start = [PNDate dateWithToken: @(123)];
	PNDate *end = [PNDate dateWithToken: @(124)];
	PNMessagesHistory *history = [[PNMessagesHistory alloc] initHistoryBetween: start andEndDate: end];
	STAssertTrue( history.startDate == start, @"");
	STAssertTrue( history.endDate == end, @"");
}

@end
