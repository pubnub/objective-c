//
//  PNConnectionTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/7/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNConnectionTest.h"

#import <OCMock/OCMock.h>

#import "PNConnection.h"
#import "PNConnection+Protected.h"

@implementation PNConnectionTest

- (void)setUp
{
    [super setUp];
    
    NSLog(@"setUp: %@", self.name);
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

#pragma mark - States tests

- (void)testConnectionWithIdentifier {
    PNConnection *connection = [PNConnection connectionWithIdentifier:@"MyTestIdentifier"];
    
    STAssertNotNil(connection, @"Couldn't create connection with identifier");
}

- (void)testConnect {
    PNConnection *connection = [PNConnection connectionWithIdentifier:@"MyTestIdentifier"];
    id mockConnection = [OCMockObject partialMockForObject:connection];
    
    [[mockConnection expect] isConnected];
    
    [mockConnection connect];
    
    [mockConnection verify];
}

- (void)testIsConnected {
    PNConnection *connection = [PNConnection connectionWithIdentifier:@"MyTestIdentifier"];
    
    STAssertFalse([connection isConnected], @"Shouldn't be connected by default");
}

- (void)testIsDisconnected {
    PNConnection *connection = [PNConnection connectionWithIdentifier:@"MyTestIdentifier"];
    
    STAssertFalse([connection isDisconnected], @"Shouldn't be disconnected by default");
}

#pragma mark - Interaction tests

- (void)testDestroyConnectionInteraction {
    
}

- (void)testCloseAllConnectionsInteraction {
    
}

- (void)testScheduleNextRequestExecutionInteraction {
    
}

- (void)testUnscheduleRequestsExecutionInteraction {
    
}

- (void)testReconnectInteraction {
    
}

- (void)testCloseConnectionInteraction {
    
}

@end
