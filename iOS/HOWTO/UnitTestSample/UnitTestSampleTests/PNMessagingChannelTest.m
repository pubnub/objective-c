//
//  PNMessagingChannelTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/7/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNMessagingChannelTest.h"
#import "PNMessagingChannel.h"

#import "PNChannel.h"
#import "PNChannel+Protected.h"
#import "PNConnectionChannel.h"
#import "PNConnectionChannel+Protected.h"

#import <OCMock/OCMock.h>

@implementation PNMessagingChannelTest

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

- (void)testMessageChannelWithDelegate {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    
    STAssertNotNil(messageChannel, @"Cannot create messageChannel");
}

- (void)testSubscribedChannels {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    
    
    STAssertTrue([[messageChannel subscribedChannels] count] == 0, @"By default we shouldn't have subscribed channels");
}

- (void)testIsSubscribedForChannel {
    id mockChannel = [OCMockObject mockForClass:[PNChannel class]];
    
    [[[mockChannel stub] andReturnValue:OCMOCK_VALUE((BOOL){YES})] isUserDefinedPresenceObservation];
    [[mockChannel stub] presenceObserver];
    [[mockChannel stub] resetUpdateTimeToken];
    [[mockChannel stub] valueForKey:OCMOCK_ANY];
    
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    [messageChannel subscribeOnChannels:@[mockChannel]];
    
    [mockChannel verify];
}

- (void)testCanResubscribe {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    
    STAssertFalse([messageChannel canResubscribe], @"Cannot subscribe without any channel");
}

- (void)testUnsubscribeFromChannelsWithPresenceEvent {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];

    // Cannot use mock there, cause all methods are private to check correct behaviour
    // This test should be improved in the future
    
    STAssertTrue([[messageChannel unsubscribeFromChannelsWithPresenceEvent:YES] count] == 0, @"Cannot subscribe without any channel");
}

- (void)testIsPresenceObservationEnabledForChannel {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    
    id mockChannel = [OCMockObject mockForClass:[PNChannel class]];
    
    [[mockChannel stub] presenceObserver];
    
    STAssertFalse([messageChannel isPresenceObservationEnabledForChannel:mockChannel], @"Observeration cannot be enabled for channel if it doesn't subscribed");
    
    [mockChannel verify];
}

#pragma mark - Interaction tests

- (void)testDisconnectWithReset {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    
    [[mockChannel expect] purgeObservedRequestsPool];
    [[mockChannel expect] purgeStoredRequestsPool];
    [[mockChannel expect] clearScheduledRequestsQueue];
    
    [mockChannel disconnectWithReset:YES];
    
    [mockChannel verify];
}

- (void)testResubscribe {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    
    [[mockChannel expect] scheduleRequest:OCMOCK_ANY
                  shouldObserveProcessing:YES];
    
//    [[mockChannel expect] purgeObservedRequestsPool];
//    [[mockChannel expect] purgeStoredRequestsPool];
//    [[mockChannel expect] clearScheduledRequestsQueue];
    
    [mockChannel resubscribe];
    
    [mockChannel verify];
}

- (void)testRestoreSubscription {
    
}

- (void)testUpdateSubscription {
    
}

- (void)testSubscribeOnChannels {
    
}

- (void)testSubscribeOnChannelsWithPresenceEvent {
    
}

- (void)testUnsubscribeFromChannels {
    
}

- (void)testEnablePresenceObservationForChannels {
    
}

- (void)testDisablePresenceObservationForChannels {
    
}

@end
