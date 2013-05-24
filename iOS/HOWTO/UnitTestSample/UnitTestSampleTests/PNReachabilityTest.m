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
    STAssertNotNil(_reachability, @"Cannot initialize reachability");
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
    
    STAssertFalse([_reachability isServiceAvailable], @"Service is not available");
}

- (void)testRefreshReachabilityState {
    /*
     Test scenario:
     - start reachabililty
     - expected available service
     */
    [_reachability refreshReachabilityState];
    STAssertTrue([_reachability isServiceAvailable], @"Service is not available");
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

- (void)testStartServiceReachabilityMonitoring {
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
    STAssertTrue([_reachability isServiceAvailable], @"Service reachability is not available");
    [_reachability stopServiceReachabilityMonitoring];
    
    // TODO: investigate error reason.
    // seems we don't change status of reachability just after start, so probably stop method called just after start is now working correct also.
}

- (void)testStopServiceReachabilityMonitoring {
    /*
     Test scenario:
     - create stubs for PubNub and configuration
     - start monitoring
     - stop monitoring
     - expected service is not available
     */
    
    // mock PubNub and PNConfiguration for this test
    /*id mockPubNub = [OCMockObject mockForClass:[PubNub class]];
    id mockConfig = [OCMockObject mockForClass:[PNConfiguration class]];
    
    [[[mockPubNub stub] andReturn:mockConfig] configuration];
    [[[mockConfig stub] andReturn:@"pubsub.pubnub.com"] origin];
    
    [[PubNub sharedInstance] setConfiguration:mockConfig];
    
    [_reachability startServiceReachabilityMonitoring];
    [_reachability stopServiceReachabilityMonitoring];
     */
    
    STAssertFalse([_reachability isServiceAvailable], @"Service is not available");
}

@end
