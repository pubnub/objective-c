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
    
    STAssertTrue([messageChannel isSubscribedForChannel:mockChannel], @"We should subscribed for channel");
}

- (void)testCanResubscribe {
    
}

- (void)testUnsubscribeFromChannelsWithPresenceEvent {
    
}

- (void)testIsPresenceObservationEnabledForChannel {
    
}

#pragma mark - Interaction tests

- (void)testDisconnectWithResetInteraction {
    
}

- (void)testResubscribeInteraction {
    
}

- (void)testRestoreSubscriptionInteraction {
    
}

- (void)testUpdateSubscriptionInteraction {
    
}

- (void)testSubscribeOnChannelsInteraction {
    
}

- (void)testSubscribeOnChannelsWithPresenceEventInteraction {
    
}

- (void)testUnsubscribeFromChannelsInteraction {
    
}

- (void)testUnsubscribeFromChannelsWithPresenceEventInteraction {
    
}

- (void)testEnablePresenceObservationForChannelsInteraction {
    
}

- (void)testDisablePresenceObservationForChannelsInteraction {
    
}

@end
