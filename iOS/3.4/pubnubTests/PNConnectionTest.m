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

@interface PNConnection ()

+ (NSMutableDictionary *)connectionsPool;
+ (PNConnection *)connectionFromPoolWithIdentifier:(NSString *)identifier;
+ (void)storeConnection:(PNConnection *)connection withIdentifier:(NSString *)identifier;
- (void)closeStreams;
- (void)resumeWakeUpTimer;
- (void)handleRequestSendingCancelation;

@end

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
    
    STAssertTrue([connection isDisconnected], @"Should beDisconnected after initializing");
}

#pragma mark - Interaction tests

- (void)testDestroyConnection {
    PNConnection *connection = [PNConnection connectionWithIdentifier:@"MyTestIdentifier"];
    
    [PNConnection destroyConnection:connection];
    STAssertNil([PNConnection connectionFromPoolWithIdentifier:@"MyTestIdentifier"], @"Shouldn't be disconnected by default");
}

- (void)testCloseAllConnections {
    __unused PNConnection *connection = [PNConnection connectionWithIdentifier:@"MyTestIdentifier"];
    
    [PNConnection closeAllConnections];
    STAssertNil([PNConnection connectionFromPoolWithIdentifier:@"MyTestIdentifier"], @"Shouldn't be disconnected by default");    
}

- (void)testScheduleNextRequestExecution {
    PNConnection *connection = [PNConnection connectionWithIdentifier:@"MyTestIdentifier"];
    
    id mockConnection = [OCMockObject partialMockForObject:connection];
    
    [[mockConnection expect] isConnected];
    [mockConnection scheduleNextRequestExecution];
    
    [mockConnection verify];
}

- (void)testUnscheduleRequestsExecution {
    PNConnection *connection = [PNConnection connectionWithIdentifier:@"MyTestIdentifier"];
    
    id mockConnection = [OCMockObject partialMockForObject:connection];
    
    [[mockConnection expect] handleRequestSendingCancelation];
    
    [mockConnection unscheduleRequestsExecution];
    [mockConnection verify];
}

- (void)testReconnect {
    PNConnection *connection = [PNConnection connectionWithIdentifier:@"MyTestIdentifier"];
    
    id mockConnection = [OCMockObject partialMockForObject:connection];
    
    [[mockConnection expect] resumeWakeUpTimer];
    
    [mockConnection reconnect];
    [mockConnection verify];
}

- (void)testDisconnectConnection {
    PNConnection *connection = [PNConnection connectionWithIdentifier:@"MyTestIdentifier"];
    
    id mockConnenction = [OCMockObject partialMockForObject:connection];
    
    [[mockConnenction expect] disconnectByUserRequest:(BOOL)YES];
    
    [mockConnenction disconnect];
    
    [mockConnenction verify];
}

@end
