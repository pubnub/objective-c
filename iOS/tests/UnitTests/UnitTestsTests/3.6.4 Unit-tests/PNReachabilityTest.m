//
//  PNReachabilityTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/3/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNReachabilityTest.h"
#import "PNReachability.h"
#import "PubNub+Protected.h"

#import <OCMock/OCMock.h>

#import <SystemConfiguration/SystemConfiguration.h>

@interface PNReachability ()

@property (nonatomic, assign) SCNetworkReachabilityRef serviceReachability;

@end

@implementation PNReachabilityTest {
    PNReachability *_reachability;
}

- (void)setUp
{
    [super setUp];
    
    NSLog(@"setUp: %@", self.name);
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

#pragma mark - Interaction tests

- (void)testStartStopServiceReachabilityMonitoring {
    /*
     Test scenario:
     - create stubs for PubNub and configuration
     - start reachability monitoring
     - expected available service
     */
    
    // mock PubNub and PNConfiguration for this test
    id mockPubNub = [OCMockObject mockForClass:[PubNub class]];
    id mockConfig = [OCMockObject mockForClass:[PNConfiguration class]];
    
    [[[mockPubNub stub] andReturn:mockConfig] configuration];
    [[[mockConfig stub] andReturn:@"127.0.0.1"] origin];
    
    [[PubNub sharedInstance] setConfiguration:mockConfig];
    
    [_reachability startServiceReachabilityMonitoring];
    XCTAssertTrue([_reachability isServiceAvailable], @"Service reachability is not available");
    [_reachability stopServiceReachabilityMonitoring];
}

@end
