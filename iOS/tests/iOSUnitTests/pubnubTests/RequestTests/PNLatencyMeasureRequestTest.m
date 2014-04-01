//
//  PNLatencyMeasureRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNLatencyMeasureRequestTest.h"
#import "PNLatencyMeasureRequest.h"

#import "PNResponse.h"

@interface PNLatencyMeasureRequest ()

@property (nonatomic, assign) CFAbsoluteTime startTime;
@property (nonatomic, assign) CFAbsoluteTime endTime;

@end

@implementation PNLatencyMeasureRequestTest
{
    PNLatencyMeasureRequest *_latMeasureRequest;
}
- (void)setUp
{
    [super setUp];
    
    _latMeasureRequest = [[PNLatencyMeasureRequest alloc] init];
    
    STAssertNotNil(_latMeasureRequest, @"Cannot initialize latencyMeasure");
}

- (void)tearDown
{
    // Tear-down code here.
    _latMeasureRequest = nil;
    [super tearDown];
}

#pragma mark - States tests

- (void)testMarkStartTime {
    
    [_latMeasureRequest markStartTime];
    
    STAssertTrue(_latMeasureRequest.startTime <= CFAbsoluteTimeGetCurrent() && _latMeasureRequest.startTime != 0, @"Start time marked incorrectly");
}

- (void)testMarkEndTime {
    [_latMeasureRequest markEndTime];
    STAssertTrue(_latMeasureRequest.endTime <= CFAbsoluteTimeGetCurrent() && _latMeasureRequest.endTime != 0, @"End time marked incorrectly");
}

- (void)testLatency {
    [_latMeasureRequest markStartTime];
    [_latMeasureRequest markEndTime];
    
    STAssertTrue(_latMeasureRequest.endTime - _latMeasureRequest.startTime == [_latMeasureRequest latency], @"Latency expected to be equal to a difference between end time and start time");
}

#pragma mark - Interaction tests
/*
- (void)testBandwidthToLoadResponse {
    
    id mockData = [OCMockObject mockForClass:[NSData class]];
    id mockResponse = [OCMockObject mockForClass:[PNResponse class]];
    
    [[[mockResponse stub] andReturn:mockData] content];
    [[mockData expect] length];
    
    [_latMeasureRequest bandwidthToLoadResponse:mockResponse];
    
    [mockResponse verify];
}
*/

@end
