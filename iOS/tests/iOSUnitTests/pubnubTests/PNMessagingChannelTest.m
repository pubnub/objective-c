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

- (BOOL)canResubscribe;
- (void)leaveSubscribedChannelsByUserRequest:(BOOL)isLeavingByUserRequest;
- (void)handleLeaveRequestCompletionForChannels:(NSArray *)channels
                                   withResponse:(PNResponse *)response
                                  byUserRequest:(BOOL)isLeavingByUserRequest;
- (void)disablePresenceObservationForChannels:(NSArray *)channels sendRequest:(BOOL)shouldSendRequest;
- (NSArray *)channelsWithPresenceFromList:(NSArray *)channelsList;

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
    
    [[[mockChannel stub] andReturnValue:OCMOCK_VALUE((BOOL){YES})] isLinkedWithPresenceObservationChannel];
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
    
    [[[mockChannel stub] andReturnValue:OCMOCK_VALUE((BOOL){YES})] isLinkedWithPresenceObservationChannel];
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
    
    [[mockChannel stub] purgeObservedRequestsPool];
    [[mockChannel stub] purgeStoredRequestsPool];
    [[mockChannel stub] clearScheduledRequestsQueue];
    
    [mockChannel disconnectWithReset:YES];
    
    [mockChannel verify];
}

- (void)testSubscribeOnChannelsReject {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];

	id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    [mockChannel subscribeOnChannels:@[[self mockChannel]]];

	mockChannel = [OCMockObject partialMockForObject:messageChannel];
    [[mockChannel reject] scheduleRequest:OCMOCK_ANY
                  shouldObserveProcessing:YES];
    
    [mockChannel subscribeOnChannels:@[[self mockChannel]]];
    
    [mockChannel verify];
}

- (void)testSubscribeOnChannelsExpect {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];

	id mockChannel = [OCMockObject partialMockForObject:messageChannel];
	PNChannel *ch = [PNChannel channelWithName: [NSString stringWithFormat: @"channel %@", [NSDate date]]];

    [[mockChannel expect] scheduleRequest:OCMOCK_ANY
                  shouldObserveProcessing:YES];

    [mockChannel subscribeOnChannels: @[ch] ];

    [mockChannel verify];
}

- (void)testSubscribeOnChannelsWithPresenceEventReject {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    [mockChannel subscribeOnChannels:@[[self mockChannel]] withPresenceEvent:YES];

    mockChannel = [OCMockObject partialMockForObject:messageChannel];
    [[mockChannel reject] scheduleRequest:OCMOCK_ANY
                  shouldObserveProcessing:YES];
    
    [mockChannel subscribeOnChannels:@[[self mockChannel]] withPresenceEvent:YES];
    
    [mockChannel verify];
}

- (void)testSubscribeOnChannelsWithPresenceEventExpect {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
	PNChannel *ch = [PNChannel channelWithName: [NSString stringWithFormat: @"channel %@", [NSDate date]]];

    [[mockChannel expect] scheduleRequest:OCMOCK_ANY
                  shouldObserveProcessing:YES];

    [mockChannel subscribeOnChannels:@[ch] withPresenceEvent:YES];

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
    
//    [[mockChannel expect] subscribeOnChannels:OCMOCK_ANY withPresenceEvent:NO];
    [[mockChannel expect] channelsWithPresenceFromList:OCMOCK_ANY];
    
    [mockChannel enablePresenceObservationForChannels:@[[self mockChannel]]];
    
    [mockChannel verify];
}

- (void)testDisablePresenceObservationForChannels {
    PNMessagingChannel *messageChannel = [PNMessagingChannel messageChannelWithDelegate:nil];
    id mockChannel = [OCMockObject partialMockForObject:messageChannel];
    
    [[mockChannel expect] disablePresenceObservationForChannels:OCMOCK_ANY sendRequest:YES];
    
    [mockChannel disablePresenceObservationForChannels:@[[self mockChannel]]];
    
    [mockChannel verify];
}

@end
