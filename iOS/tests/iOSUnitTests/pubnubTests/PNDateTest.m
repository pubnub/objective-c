//
//  PNDateTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/4/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNDate.h"

@interface PNDate (test)

- (id)initWithTimeToken:(NSNumber *)timeToken;

@end

@interface PNDateTest : SenTestCase

@end

@implementation PNDateTest

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:0.1];
}

-(void)testDateWithDate {
	NSDate *date = [NSDate date];
	PNDate *pnDate = [PNDate dateWithDate: date];
	STAssertTrue( pnDate != nil, @"");
	NSLog(@"dates:\n%@\n%@\n%f", pnDate.date, date, [pnDate.date timeIntervalSinceDate: date]);
	STAssertTrue( [pnDate.date timeIntervalSinceDate: date] > -1 && [pnDate.date timeIntervalSinceDate: date] < 1, @"");
}

-(void)testInitWithTimeToken {
	PNDate *pnDate = [[PNDate alloc] initWithTimeToken: @(123)];
	STAssertTrue( [pnDate.timeToken intValue] == 123, @"");
}

@end
