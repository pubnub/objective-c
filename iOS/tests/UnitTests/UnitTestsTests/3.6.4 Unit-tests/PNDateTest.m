//
//  PNDateTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/4/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNDate.h"

@interface PNDate (test)

- (id)initWithTimeToken:(NSNumber *)timeToken;

@end

@interface PNDateTest : XCTestCase

@end

@implementation PNDateTest

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:0.1];
}

-(void)testDateWithDate {
	NSDate *date = [NSDate date];
	PNDate *pnDate = [PNDate dateWithDate: date];
	XCTAssertTrue( pnDate != nil, @"");
	NSLog(@"dates:\n%@\n%@\n%f", pnDate.date, date, [pnDate.date timeIntervalSinceDate: date]);
	XCTAssertTrue( [pnDate.date timeIntervalSinceDate: date] > -1 && [pnDate.date timeIntervalSinceDate: date] < 1, @"");
}

-(void)testInitWithTimeToken {
	PNDate *pnDate = [[PNDate alloc] initWithTimeToken: @(123)];
	XCTAssertTrue( [pnDate.timeToken intValue] == 123, @"");
}

@end
