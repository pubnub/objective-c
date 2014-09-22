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

// used from PNConnection.m

// Default origin host connection port
__unused static UInt32 const kPNOriginConnectionPort = 80;

// Default origin host SSL connection port
static UInt32 const kPNOriginSSLConnectionPort = 443;

@interface PNConnection () <PNConnectionDelegate>

+ (NSMutableDictionary *)connectionsPool;
+ (PNConnection *)connectionFromPoolWithIdentifier:(NSString *)identifier;
+ (void)storeConnection:(PNConnection *)connection withIdentifier:(NSString *)identifier;
- (void)closeStreams;
- (void)resumeWakeUpTimer;
- (void)handleRequestSendingCancelation;

// Stream configuration
- (CFMutableDictionaryRef)streamSecuritySettings;

- (void)configureReadStream:(CFReadStreamRef)readStream;
- (void)configureWriteStream:(CFWriteStreamRef)writeStream;

- (void)retrieveSystemProxySettings;

@property (nonatomic, strong) NSDictionary *proxySettings;

@end

@interface PNConnectionTest ()

<
PNConnectionDelegate
>

@end

@implementation PNConnectionTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (PNConfiguration *)configuration {
    PNConfiguration *configuration = [PNConfiguration defaultConfiguration];
    configuration.useSecureConnection = YES;
    
    return [PNConfiguration defaultConfiguration];
}

#pragma mark - States tests

- (void)testConnectionWithIdentifier {
    PNConnection *connection = [PNConnection connectionWithConfiguration:[PNConfiguration defaultConfiguration] andIdentifier:@"MyTestIdentifier"];
    
    STAssertNotNil(connection, @"Couldn't create connection with identifier");
}

- (void)testConnect {
    PNConnection *connection = [PNConnection connectionWithConfiguration:[PNConfiguration defaultConfiguration] andIdentifier:@"MyTestIdentifier"];

    id mockConnection = [OCMockObject partialMockForObject:connection];
    
    [[mockConnection expect] isConnected];
    
    [mockConnection setDelegate:self];
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
    PNConnection *connection = [PNConnection connectionWithConfiguration:[PNConfiguration defaultConfiguration] andIdentifier:@"MyTestIdentifier"];
    id mockConnenction = [OCMockObject partialMockForObject:connection];
    
    [[mockConnenction expect] disconnectByInternalRequest];
    
    [mockConnenction disconnect];
    
    [mockConnenction verify];
}

#pragma mark - Configuration tests

- (void)testConfigureReadStream {
    PNConnection *connection = [PNConnection connectionWithConfiguration:[PNConfiguration defaultConfiguration] andIdentifier:@"MyTestIdentifier"];
    
    id mockConnenction = [OCMockObject partialMockForObject:connection];
    
    CFReadStreamRef _socketReadStream;
    CFWriteStreamRef _socketWriteStream;
    
    // Create stream pair on socket which is connected to specified remote host
    CFStreamCreatePairWithSocketToHost(CFAllocatorGetDefault(), (__bridge CFStringRef)(self.configuration.origin),
                                       kPNOriginSSLConnectionPort, &_socketReadStream, &_socketWriteStream);
    
    [[mockConnenction expect] streamSecuritySettings];
    
    [mockConnenction configureReadStream:_socketReadStream];
    [mockConnenction configureWriteStream:_socketWriteStream];
    
    [mockConnenction verify];
}

- (void)testSystemProxySettings {
    PNConnection *connection = [PNConnection connectionWithConfiguration:[PNConfiguration defaultConfiguration] andIdentifier:@"MyTestIdentifier"];

    [PubNub setConfiguration:[self configuration]];
    
    id mockConnenction = [OCMockObject partialMockForObject:connection];
    
    [[mockConnenction expect] proxySettings];
    
    [mockConnenction retrieveSystemProxySettings];
    
    [mockConnenction verify];
}

#pragma mark - PNConnectionDelegate

- (BOOL)connectionCanConnect:(PNConnection *)connection {
	return YES;
}

- (void)connection:(PNConnection *)connection didConnectToHost:(NSString *)hostName {

}

@end
