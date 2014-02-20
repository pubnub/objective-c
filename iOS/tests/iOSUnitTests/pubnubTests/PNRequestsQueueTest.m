//
//  PNRequestsQueueTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNRequestsQueue.h"

@interface PNRequestsQueue (test)
@property (nonatomic, strong) NSMutableArray *query;
@end

@interface PNRequestsQueueTest : SenTestCase

@end

@implementation PNRequestsQueueTest

-(void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testInit {
	PNRequestsQueue *queue = [[PNRequestsQueue alloc] init];
	STAssertTrue( [queue.query isKindOfClass: [NSMutableArray class]], @"");
	STAssertTrue( queue != nil, @"");
	STAssertTrue( queue.query == [queue requestsQueue], @"");
}

@end
