//
//  PNConnectionChannelTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/7/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNConnectionChannelTest.h"
#import "PNConnectionChannel.h"
#import "PNConnectionChannel+Protected.h"

#import <OCMock/OCMock.h>

#import "PNConnection.h"
#import "PNSubscribeRequest.h"
#import "PNChannel.h"
#import "PNRequestsQueue.h"

@interface PNConnectionChannel ()

@property (nonatomic, strong) PNConnection *connection;
@property (nonatomic, strong) PNRequestsQueue *requestsQueue;

- (BOOL)shouldStoreRequest:(PNBaseRequest *)request;

@end

@interface PNConnectionChannelTest () <PNConnectionChannelDelegate>

@end

@implementation PNConnectionChannelTest

- (void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
	[super tearDown];
}


#pragma mark - States tests

- (void)testConnectionChannelWithTypeAndDelegate {
    PNConnectionChannel *connectionChannel = [PNConnectionChannel connectionChannelWithType:PNConnectionChannelMessaging andDelegate:self];
    STAssertNotNil(connectionChannel, @"Couldn't create connection with message type and delegate");
    
    connectionChannel = [PNConnectionChannel connectionChannelWithType:PNConnectionChannelService andDelegate:self];
    STAssertNotNil(connectionChannel, @"Couldn't create connection with service type and delegate");
}

- (void)testInitWithTypeAndDelegate {
    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
    STAssertNotNil(connectionChannel, @"Couldn't create connection with message type and delegate");
    
    connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelService andDelegate:self];
    STAssertNotNil(connectionChannel, @"Couldn't create connection with service type and delegate");
}

- (void)testIsConnected {
    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
    STAssertFalse([connectionChannel isConnected], @"By default channel shouldn't be connected");
}

#pragma mark - Interaction tests

- (void)testConnect {
    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
    [connectionChannel connect];
    
    STAssertFalse([connectionChannel isConnected], @"Cannot connect without configuration");
}

- (void)testDisconnect {
    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
    
    [connectionChannel disconnect];
    
    STAssertFalse([connectionChannel isConnected], @"Cannot connect without configuration");
}

- (void)testScheduleRequestShouldObserveProcessing {
    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
    
    id mockChannel = [OCMockObject partialMockForObject:connectionChannel];
    
    [[mockChannel expect] scheduleNextRequest];
    [[[mockChannel stub] andReturnValue:OCMOCK_VALUE((BOOL){YES})] shouldStoreRequest:OCMOCK_ANY];
    
    PNChannel *channel = [PNChannel channelWithName:@"MyTestChannel"];
    PNSubscribeRequest *mockRequest = [PNSubscribeRequest subscribeRequestForChannel:channel byUserRequest:YES withClientState: nil];
    
    [mockChannel scheduleRequest:mockRequest shouldObserveProcessing:YES];
    
    [mockChannel verify];
}

// All methods below just redirect to PNConnection private property of PNConnectionChannel

- (void)testScheduleNextRequest {
    // init connection
    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
    
    // create mock for private property
    id mockConnect = [OCMockObject partialMockForObject:[PNConnection connectionWithIdentifier:@"MyTestConnect"]];
    
    [[mockConnect expect] scheduleNextRequestExecution];
    [connectionChannel setConnection:mockConnect];
    
    [connectionChannel scheduleNextRequest];
    
    [mockConnect verify];
}

- (void)testUnscheduleNextRequest {
    // init connection
    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
    
    // create mock for private property
    id mockConnect = [OCMockObject partialMockForObject:[PNConnection connectionWithIdentifier:@"MyTestConnect"]];
    
    [[mockConnect expect] unscheduleRequestsExecution];
    [connectionChannel setConnection:mockConnect];
    
    [connectionChannel unscheduleNextRequest];
    
    [mockConnect verify];
}

- (void)testUnscheduleRequest {
    // init connection
    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
    
    // create mock for private property
    id mockRequestQueue = [OCMockObject partialMockForObject:[[PNRequestsQueue alloc] init]];
    
    [[mockRequestQueue expect] removeRequest:OCMOCK_ANY];
    [connectionChannel setRequestsQueue:mockRequestQueue];
    
    [connectionChannel unscheduleRequest:nil];
    
    [mockRequestQueue verify];
}

- (void)testClearScheduledRequestsQueue {
    // init connection
    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
    
    // create mock for private property
    id mockRequestQueue = [OCMockObject partialMockForObject:[[PNRequestsQueue alloc] init]];
    
    [[mockRequestQueue expect] removeAllRequests];
    [connectionChannel setRequestsQueue:mockRequestQueue];
    
    [connectionChannel clearScheduledRequestsQueue];
    
    [mockRequestQueue verify];
    
    [connectionChannel setRequestsQueue:nil];
}

#pragma mark - PNConnectionChannel Delegate
- (BOOL)connectionChannelCanConnect:(PNConnectionChannel *)channel {
    return YES;
}

- (void)connectionChannelConfigurationDidFail:(PNConnectionChannel *)channel {}
- (void)connectionChannelWillSuspend:(PNConnectionChannel *)channel {}
- (void)connectionChannelWillResume:(PNConnectionChannel *)channel {}
- (void)connectionChannelDidSuspend:(PNConnectionChannel *)channel {}
- (void)connectionChannelDidResume:(PNConnectionChannel *)channel {}

- (void)connectionChannel:(PNConnectionChannel *)channel
         didConnectToHost:(NSString *)host {}

- (void)connectionChannel:(PNConnectionChannel *)channel
       didReconnectToHost:(NSString *)host {}

- (void)connectionChannel:(PNConnectionChannel *)channel
connectionDidFailToOrigin:(NSString *)host
                withError:(PNError *)error {}

- (void)connectionChannel:(PNConnectionChannel *)channel
  didDisconnectFromOrigin:(NSString *)host {}

- (void)connectionChannel:(PNConnectionChannel *)channel
 willDisconnectFromOrigin:(NSString *)host
                withError:(PNError *)error {}

@end
