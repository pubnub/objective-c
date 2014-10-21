//
//  PNReachabilityTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/3/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//
#import <XCTest/XCTest.h>
#import "PNReachability.h"
#import "PubNub+Protected.h"

#import <OCMock/OCMock.h>

#import <SystemConfiguration/SystemConfiguration.h>

@interface PNReachability ()

@property (nonatomic, assign) SCNetworkReachabilityRef serviceReachability;

@end

@interface PubNub ()

- (BOOL)shouldKeepTimeTokenOnChannelsListChange;

@end

@interface PNReachabilityTest : XCTestCase

@end

@implementation PNReachabilityTest {
    PNReachability *_reachability;
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    _reachability = [PNReachability serviceReachability];
    
    XCTAssertNotNil(_reachability, @"Cannot initialize reachability");
}

- (void)tearDown
{
    // Tear-down code here.
    _reachability = nil;
    
    [[PubNub sharedInstance] setConfiguration:[PNConfiguration defaultConfiguration]];
    
    [super tearDown];
}

#pragma mark - States tests

- (void)testSeviceNotAvailable {
    /*
     Test scenario:
     - start reachabililty
     - expected available service
     */
    
    XCTAssertFalse([_reachability isServiceAvailable], @"Service is not available");
}

- (void)testRefreshReachabilityState {
    /*
     Test scenario:
     - start reachabililty
     - expected available service
     */
    [_reachability refreshReachabilityState];
    XCTAssertTrue([_reachability isServiceAvailable], @"Service is not available");
}

- (void)testStartServiceReachabilityMonitoringFalse {
    /*
     Test scenario:
        - start reachabililty
        - expected avaialble service
     */
    id mockReachability = [OCMockObject partialMockForObject:_reachability];
    
    [[mockReachability expect] stopServiceReachabilityMonitoring];
    [mockReachability startServiceReachabilityMonitoring];
    
    [mockReachability verify];
}

@end
