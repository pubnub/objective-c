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

#pragma mark - PNMessagingChannel private methods

@interface PNMessagingChannel ()

- (void)leaveSubscribedChannelsByUserRequest:(BOOL)isLeavingByUserRequest;
- (void)handleLeaveRequestCompletionForChannels:(NSArray *)channels
                                   withResponse:(PNResponse *)response
                                  byUserRequest:(BOOL)isLeavingByUserRequest;

@end

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

- (PNChannel *)mockChannel {
    id mockChannel = [OCMockObject mockForClass:[PNChannel class]];
    
    // TODO: implement here everything we need to test PNMessageChannel
    [[[mockChannel stub] andReturnValue:OCMOCK_VALUE((BOOL){YES})] isUserDefinedPresenceObservation];
    [[mockChannel stub] presenceObserver];
    [[mockChannel stub] resetUpdateTimeToken];
    [[mockChannel stub] valueForKey:OCMOCK_ANY];
    
    return mockChannel;
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
    
    // subscribe to mock channel before we can resubscribe successfully
    [mockChannel subscribeOnChannels:@[[self mockChannel]]];

    [mockChannel resubscribe];
    
    [mockChannel verify];
}

- (void)testRestoreSubscription {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    
    [[mockChannel expect] scheduleRequest:OCMOCK_ANY
                  shouldObserveProcessing:YES];
    
    // subscribe to mock channel before we can restore successfully
    [mockChannel subscribeOnChannels:@[[self mockChannel]]];
    
    [mockChannel restoreSubscription:YES];
    
    [mockChannel verify];
}

- (void)testUpdateSubscription {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    
    [[mockChannel expect] scheduleRequest:OCMOCK_ANY
                  shouldObserveProcessing:YES];
    
    // subscribe to mock channel before we can restore successfully
    [mockChannel subscribeOnChannels:@[[self mockChannel]]];
    
    [mockChannel updateSubscription];
    
    [mockChannel verify];
}

- (void)testSubscribeOnChannels {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    
    [[mockChannel expect] scheduleRequest:OCMOCK_ANY
                  shouldObserveProcessing:YES];
    
    [mockChannel subscribeOnChannels:@[[self mockChannel]]];
    
    [mockChannel verify];
}

- (void)testSubscribeOnChannelsWithPresenceEvent {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    
    [[mockChannel expect] scheduleRequest:OCMOCK_ANY
                  shouldObserveProcessing:YES];
    
    // TODO: determine do we need to cover precense event conditions
    [mockChannel subscribeOnChannels:@[[self mockChannel]] withPresenceEvent:YES];
    
    [mockChannel verify];
}

- (void)testUnsubscribeFromChannels {
    // Clear here:
    // we have set of subscribed channel only after we receive response from server
    // it seems now we don't receive anything, cause we are working outside of PubNub client
    // so checking of unsubscribe should be stubbed completely
    
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    
    [[mockChannel expect] leaveSubscribedChannelsByUserRequest:YES];
    
    [mockChannel unsubscribeFromChannelsWithPresenceEvent:YES];
    
    [mockChannel verify];
}

- (void)testEnablePresenceObservationForChannels {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    
    [[mockChannel expect] subscribeOnChannels:OCMOCK_ANY withPresenceEvent:NO];
    
    [mockChannel enablePresenceObservationForChannels:@[[self mockChannel]]];
    
    [mockChannel verify];
}

- (void)testDisablePresenceObservationForChannels {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    
    [[mockChannel expect] unsubscribeFromChannels:OCMOCK_ANY withPresenceEvent:NO];
    
    [mockChannel disablePresenceObservationForChannels:@[[self mockChannel]]];
    
    [mockChannel verify];
}

@end
