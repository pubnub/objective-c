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
#import "PNPrivateMacro.h"

typedef NS_OPTIONS(NSUInteger, PNConnectionStateFlag)  {

    // Channel trying to establish connection to PubNub services
    PNConnectionChannelConnecting = 1 << 0,

    // Channel reconnecting with same settings which was used during initialization
    PNConnectionChannelReconnect = 1 << 1,

    // Channel is resuming it's operation state
    PNConnectionChannelResuming = 1 << 2,

    // Channel is ready for work (connections established and requests queue is ready)
    PNConnectionChannelConnected = 1 << 3,

    // Channel is transferring to suspended state
    PNConnectionChannelSuspending = 1 << 4,

    // Channel is in suspended state
    PNConnectionChannelSuspended = 1 << 5,

    // Channel is disconnecting on user request (for example: leave request for all channels)
    PNConnectionChannelDisconnecting = 1 << 6,

    // Channel is ready, but was disconnected and waiting command for connection (or was unable to connect during
    // initialization). All requests queue is alive (if they wasn't flushed by user)
    PNConnectionChannelDisconnected = 1 << 7
};

@interface PNConnectionChannel ()

@property (nonatomic, strong) PNConnection *connection;
@property (nonatomic, strong) PNRequestsQueue *requestsQueue;

- (BOOL)shouldStoreRequest:(PNBaseRequest *)request;
@property (nonatomic, strong) NSMutableDictionary *observedRequests;
@property (nonatomic, strong) NSMutableDictionary *storedRequests;
@property (nonatomic, strong) NSMutableArray *storedRequestsList;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) unsigned long state;

@end

@interface PNConnectionChannelTest () <PNConnectionChannelDelegate>

@end

@implementation PNConnectionChannelTest

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

//- (void)testIsConnected {
//    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
//    STAssertFalse([connectionChannel isConnected], @"By default channel shouldn't be connected");
//}

#pragma mark - Interaction tests

//- (void)testConnect {
//    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
//    [connectionChannel connect];
//    
//    STAssertFalse([connectionChannel isConnected], @"Cannot connect without configuration");
//}

//- (void)testDisconnect {
//    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
//    
//    [connectionChannel disconnect];
//    
//    STAssertFalse([connectionChannel isConnected], @"Cannot connect without configuration");
//}

- (void)testScheduleRequestShouldObserveProcessing {
    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
    
    id mockChannel = [OCMockObject partialMockForObject:connectionChannel];
    
    [[mockChannel expect] scheduleNextRequest];
    [[[mockChannel stub] andReturnValue:OCMOCK_VALUE((BOOL){YES})] shouldStoreRequest:OCMOCK_ANY];
    
    PNChannel *channel = [PNChannel channelWithName:@"MyTestChannel"];
    PNSubscribeRequest *mockRequest = [PNSubscribeRequest subscribeRequestForChannel:channel byUserRequest:YES];
    
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
///////////////////////////////////////////////////////////////////////////////////////////////////////

-(void)testConnectionChannelWithType {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	STAssertTrue( channel.delegate == self, @"");
	STAssertTrue( [channel.observedRequests isKindOfClass: [NSMutableDictionary class]] == YES, @"");
	STAssertTrue( [channel.storedRequests isKindOfClass: [NSMutableDictionary class]] == YES, @"");
	STAssertTrue( [channel.storedRequestsList isKindOfClass: [NSMutableArray class]] == YES, @"");
	STAssertTrue( [channel.name isEqualToString: @"PNMessagingConnectionIdentifier"] == YES, @"");
	STAssertTrue( [channel.requestsQueue isKindOfClass: [PNRequestsQueue class]] == YES, @"");
	STAssertTrue( channel.requestsQueue.delegate == channel, @"");
	STAssertTrue( PNBitsIsOn( channel.state, PNConnectionChannelDisconnected, PNConnectionChannelConnecting, BITS_LIST_TERMINATOR) == YES, @"" );
	STAssertTrue( [channel.connection isKindOfClass: [PNConnection class]], @"");
}

-(void)testConnect {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	[channel connect];
	STAssertTrue( PNBitsIsOn( channel.state, PNConnectionChannelDisconnected, PNConnectionChannelConnecting, BITS_LIST_TERMINATOR) == YES, @"" );
	STAssertTrue( [channel.connection isKindOfClass: [PNConnection class]], @"");
}

-(void)testIsConnecting {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOff( &state, PNConnectionChannelDisconnected, PNConnectionChannelConnecting);
	channel.state = state;
	STAssertTrue( [channel isConnecting] == NO, @"" );

	state = channel.state;
	PNBitsOn( &state, PNConnectionChannelDisconnected, PNConnectionChannelConnecting);
	channel.state = state;
	STAssertTrue( [channel isConnecting] == YES, @"" );
}

-(void)testIsReconnecting {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOff( &state, PNConnectionChannelConnecting, PNConnectionChannelReconnect);
	channel.state = state;
	STAssertTrue( [channel isReconnecting] == NO, @"" );

	state = channel.state;
	PNBitsOn( &state, PNConnectionChannelConnecting, PNConnectionChannelReconnect);
	channel.state = state;
	STAssertTrue( [channel isReconnecting] == YES, @"" );
}

-(void)testIsConnected {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOff( &state, PNConnectionChannelConnected);
	channel.state = state;
	STAssertTrue( [channel isConnected] == NO, @"" );

	state = channel.state;
	PNBitsOff( &state, PNConnectionChannelConnecting, PNConnectionChannelReconnect);
	PNBitOn( &state, PNConnectionChannelConnected);
	channel.state = state;
	STAssertTrue( [channel isConnected] == YES, @"" );
}

-(void)testDisconnect {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
//	unsigned long state = channel.state;
//	PNBitsOff( &state, PNConnectionChannelConnected);
//	channel.state = state;
	[channel disconnect];
	STAssertTrue( channel.state == 128, @"");
}

-(void)testIsDisconnecting {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOff( &state, PNConnectionChannelConnected, PNConnectionChannelDisconnecting);
	channel.state = state;
	STAssertTrue( [channel isDisconnecting] == NO, @"" );

	state = channel.state;
	PNBitsOn( &state, PNConnectionChannelConnected, PNConnectionChannelDisconnecting);
	channel.state = state;
	STAssertTrue( [channel isDisconnecting] == YES, @"" );
}

-(void)testIsDisconnected {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitOn( &state, PNConnectionChannelDisconnected);
	PNBitsOff( &state, PNConnectionChannelConnecting);
	channel.state = state;
	STAssertTrue( [channel isDisconnected] == YES, @"" );

	state = 0;
	PNBitOn( &state, PNConnectionChannelSuspended);
	PNBitOff( &state, PNConnectionChannelConnecting);
	channel.state = state;
	STAssertTrue( [channel isDisconnected] == YES, @"" );
}

-(void)testSuspend {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	[channel suspend];
	STAssertTrue( channel.state == 160, @"");
}

-(void)testIsSuspending {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOn( &state, PNConnectionChannelConnected, PNConnectionChannelSuspending);
	channel.state = state;
	STAssertTrue( [channel isSuspending] == YES, @"" );

	channel.state = 0;
	STAssertTrue( [channel isSuspending] == NO, @"" );
}

-(void)testIsSuspended {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOn( &state, PNConnectionChannelConnected, PNConnectionChannelSuspending);
	channel.state = state;
	STAssertTrue( [channel isSuspended] == YES, @"" );

	channel.state = 0;
	STAssertTrue( [channel isSuspended] == NO, @"" );
}

-(void)testResume {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	[channel resume];
	STAssertTrue( channel.state == 8, @"");
}

-(void)testIsResuming {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOn( &state, PNConnectionChannelDisconnected, PNConnectionChannelResuming);
	channel.state = state;
	STAssertTrue( [channel isResuming] == YES, @"" );

	channel.state = 0;
	STAssertTrue( [channel isResuming] == NO, @"" );

	STAssertTrue( [channel shouldScheduleRequest: nil] == YES, @"");
}

-(void)testPurgeObservedRequestsPool {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	[channel.observedRequests setObject: @"object" forKey: @"key"];
	STAssertTrue( channel.observedRequests.count > 0, @"");
	[channel purgeObservedRequestsPool];
	STAssertTrue( channel.observedRequests.count == 0, @"");
}


@end




