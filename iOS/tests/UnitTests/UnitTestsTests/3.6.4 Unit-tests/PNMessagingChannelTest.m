//
//  PNMessagingChannelTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/7/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//
#import "PNServiceChannel.h"
#import "PNMessagingChannelTest.h"
#import "PNMessagingChannel.h"

#import "PNChannel.h"
#import "PNChannel+Protected.h"
#import "PNConnectionChannel.h"
#import "PNConnectionChannel+Protected.h"

#import "OCMock.h"

//#import <OCMock/OCMock.h>

#pragma mark - PNMessagingChannel private methods

@interface PNMessagingChannel ()

- (BOOL)canResubscribe;
- (void)leaveSubscribedChannelsByUserRequest:(BOOL)isLeavingByUserRequest;
- (void)handleLeaveRequestCompletionForChannels:(NSArray *)channels
                                   withResponse:(PNResponse *)response
                                  byUserRequest:(BOOL)isLeavingByUserRequest;
- (void)disablePresenceObservationForChannels:(NSArray *)channels sendRequest:(BOOL)shouldSendRequest;
- (NSArray *)channelsWithPresenceFromList:(NSArray *)channelsList;

@end

@interface PNMessagingChannelTest ()

<
PNConnectionChannelDelegate
>

@end

@implementation PNMessagingChannelTest {
    PNConfiguration *_configuration;
}

- (void)setUp
{
    [super setUp];
    
    _configuration = [PNConfiguration defaultConfiguration];
}

- (void)tearDown
{
    [super tearDown];
}

- (PNChannel *)mockChannel {
    id mockChannel = [OCMockObject mockForClass:[PNChannel class]];
    
    [[[mockChannel stub] andReturnValue:OCMOCK_VALUE((BOOL){YES})] isLinkedWithPresenceObservationChannel];
    [[mockChannel stub] presenceObserver];
    [[mockChannel stub] resetUpdateTimeToken];
    [[mockChannel stub] valueForKey:OCMOCK_ANY];
    
    return mockChannel;
}

#pragma mark - States tests

- (void)testMessageChannelWithDelegate {
    
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithConfiguration:_configuration
                                                                                 andDelegate:self];
    
    XCTAssertNotNil(messageChannel, @"Cannot create messageChannel");
}

- (void)testSubscribedChannels {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithConfiguration:_configuration
                                                                                 andDelegate:self];
    
    XCTAssertTrue([[messageChannel subscribedChannels] count] == 0, @"By default we shouldn't have subscribed channels");
}

- (void)testIsSubscribedForChannel {
    
    id mockChannel = [OCMockObject mockForClass:[PNChannel class]];
    
    [[[mockChannel stub] andReturnValue:OCMOCK_VALUE((BOOL){YES})] isLinkedWithPresenceObservationChannel];
    [[mockChannel stub] presenceObserver];
    [[mockChannel stub] resetUpdateTimeToken];
    [[mockChannel stub] valueForKey:OCMOCK_ANY];
    
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithConfiguration:_configuration
                                                                                 andDelegate:self];
    [messageChannel subscribeOnChannels:@[[self mockChannel]]];
    
    [mockChannel verify];
}

- (void)testCanResubscribe {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithConfiguration:_configuration
                                                                                 andDelegate:self];
    
    XCTAssertFalse([messageChannel canResubscribe], @"Cannot subscribe without any channel");
}

- (void)testIsPresenceObservationEnabledForChannel {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithConfiguration:_configuration
                                                                                 andDelegate:self];

    
    id mockChannel = [OCMockObject mockForClass:[PNChannel class]];
    
    [[mockChannel stub] presenceObserver];
    
    XCTAssertFalse([messageChannel isPresenceObservationEnabledForChannel:mockChannel], @"Observeration cannot be enabled for channel if it doesn't subscribed");
    
    [mockChannel verify];
}

#pragma mark - Interaction tests

- (void)testDisconnectWithReset {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithConfiguration:_configuration
                                                                                 andDelegate:self];

    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    
    
    [[mockChannel stub] purgeObservedRequestsPool];
    [[mockChannel stub] purgeStoredRequestsPool];
    [[mockChannel stub] clearScheduledRequestsQueue];
    
//    [mockChannel disconnectWithReset:YES];
    
    [mockChannel verify];
}

- (void)testSubscribeOnChannelsReject {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithConfiguration:_configuration
                                                                                 andDelegate:self];

	id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    [mockChannel subscribeOnChannels:@[[self mockChannel]]];

    [[mockChannel reject] scheduleRequest:OCMOCK_ANY
                  shouldObserveProcessing:YES];
    
    [mockChannel subscribeOnChannels:@[[self mockChannel]]];
    
    [mockChannel verify];
}

- (void)t1estSubscribeOnChannelsExpect {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithConfiguration:_configuration
                                                                                 andDelegate:self];

	id mockChannel = [OCMockObject partialMockForObject:messageChannel];

//    the method scheduleRequest not need now
    [[mockChannel expect] scheduleRequest:OCMOCK_ANY
                  shouldObserveProcessing:YES];

    [mockChannel subscribeOnChannels: @[[self mockChannel]] ];

    [mockChannel verify];
}

- (void)testSubscribeOnChannelsWithPresenceEventReject {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithConfiguration:_configuration
                                                                                 andDelegate:self];
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    [mockChannel subscribeOnChannels:@[[self mockChannel]] withCatchUp:YES andClientState: nil];

    [[mockChannel reject] scheduleRequest:OCMOCK_ANY
                  shouldObserveProcessing:YES];
    
    [mockChannel subscribeOnChannels:@[[self mockChannel]] withCatchUp:YES andClientState: nil];

    [mockChannel verify];
}

- (void)t1estSubscribeOnChannelsWithPresenceEventExpect {
    
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithConfiguration:_configuration
                                                                                 andDelegate:self];
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    
//    the method scheduleRequest not need now
    [[mockChannel expect] scheduleRequest:OCMOCK_ANY
                  shouldObserveProcessing:YES];
    
    [mockChannel subscribeOnChannels: @[[self mockChannel]] withCatchUp:YES andClientState: nil];

    [mockChannel verify];
}

- (void)testEnablePresenceObservationForChannels {
    
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithConfiguration:_configuration
                                                                                 andDelegate:self];
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    
    [[[mockChannel expect] ignoringNonObjectArgs] enablePresenceObservationForChannels:[OCMArg any]];
    
    [mockChannel enablePresenceObservationForChannels:@[[self mockChannel]]];
    
    [mockChannel verify];
}

- (void)testDisablePresenceObservationForChannels {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithConfiguration:_configuration
                                                                                 andDelegate:self];
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    
    [[mockChannel expect] disablePresenceObservationForChannels:OCMOCK_ANY sendRequest:YES];
    
    [mockChannel disablePresenceObservationForChannels:@[[self mockChannel]]];
    
    [mockChannel verify];
}


#pragma mark - PNConnectionDelegates

- (void)connectionChannelConfigurationDidFail:(PNConnectionChannel *)channel{
}
- (void)connectionChannel:(PNConnectionChannel *)channel didConnectToHost:(NSString *)host{
}
- (void)connectionChannel:(PNConnectionChannel *)channel didReconnectToHost:(NSString *)host{
}
- (void)connectionChannel:(PNConnectionChannel *)channel connectionDidFailToOrigin:(NSString *)host
                withError:(PNError *)error{
}
- (void)connectionChannelWillSuspend:(PNConnectionChannel *)channel{
}
- (void)connectionChannelDidSuspend:(PNConnectionChannel *)channel{
}
- (void)connectionChannelWillResume:(PNConnectionChannel *)channel{
}
- (void)connectionChannelDidResume:(PNConnectionChannel *)channel requireWarmUp:(BOOL)isWarmingUpRequired{
}
- (BOOL)connectionChannelCanConnect:(PNConnectionChannel *)channel{
    return YES;
}
- (BOOL)connectionChannelShouldRestoreConnection:(PNConnectionChannel *)channel{
    return YES;
}
- (void)connectionChannelConfigurationDidFail11:(PNConnectionChannel *)channel{
}
- (NSString *)clientIdentifier{
    return @"rr";
}
- (BOOL)isPubNubServiceAvailable:(BOOL)shouldUpdateInformation{
    return YES;
}
- (void)connectionChannel:(PNConnectionChannel *)channel didDisconnectFromOrigin:(NSString *)host{
}
- (void)connectionChannel:(PNConnectionChannel *)channel willDisconnectFromOrigin:(NSString *)host
                withError:(PNError *)error{
}

- (void)connectionChannel:(PNConnectionChannel *)channel checkCanConnect:(void (^)(BOOL))checkCompletionBlock {
    
}



@end






//    PNServiceChannel *channel = [PNServiceChannel serviceChannelWithConfiguration:_configuration andDelegate:self];
//    id mock = [OCMockObject partialMockForObject:channel];

//    PubNub *client = [PubNub connectingClientWithConfiguration:_configuration andDelegate:self];
//    id mockChannel = [OCMockObject partialMockForObject:client];



