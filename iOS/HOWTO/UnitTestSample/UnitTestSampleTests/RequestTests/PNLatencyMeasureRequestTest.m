//
//  PNLatencyMeasureRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNLatencyMeasureRequestTest.h"
#import "PNLatencyMeasureRequest.h"

#import <OCMock/OCMock.h>
#import <OCMock/OCMArg.h>

@interface PNLatencyMeasureRequest ()

@property (nonatomic, assign) CFAbsoluteTime startTime;
@property (nonatomic, assign) CFAbsoluteTime endTime;

@end

@implementation PNLatencyMeasureRequestTest

- (void)setUp
{
    [super setUp];
    
    NSLog(@"setUp: %@", self.name);
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark - States tests

- (void)testMarkStartTime {
    
    PNLatencyMeasureRequest *req = [[PNLatencyMeasureRequest alloc] init];
    
    id mockReq = [OCMockObject partialMockForObject:[[PNLatencyMeasureRequest alloc] init]];
    [[mockReq expect] setStartTime:OCMOCK_ANY];
    
    [mockReq markStartTime];
    
    [mockReq verify];
}

- (void)testMarkEndTime {
    
}

- (void)testLatency {
    
}

#pragma mark - Interaction tests

- (void)testBandwidthToLoadResponse {
    
}

@end
