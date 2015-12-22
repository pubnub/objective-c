//
//  PNChannelGroupPresenceEventTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 12/16/15.
//
//

#import "PNBasicPresenceTestCase.h"

@interface PNChannelGroupPresenceEventTests : PNBasicPresenceTestCase
@end

@implementation PNChannelGroupPresenceEventTests

- (void)setUp {
    [super setUp];
    
    PNWeakify(self);
    [self performVerifiedAddChannels:@[@"a", [self otherClientChannelName]] toGroup:[self channelGroupName] withAssertions:^(PNAcknowledgmentStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
    }];
    [self setUpChannelGroupSubscription];
    if (
        (self.invocation.selector == @selector(testLeaveEvent)) &&
        (self.invocation.selector == @selector(testTimeoutEvent)) &&
        (self.invocation.selector == @selector(testStateChangeEvent))
        ) {
        PNWeakify(self);
        self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
            PNStrongify(self);
            XCTAssertNotNil(client);
            XCTAssertNotNil(status);
            XCTAssertEqualObjects(self.client, client);
            XCTAssertEqual(status.category, PNConnectedCategory);
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.statusCode, 200);
            XCTAssertTrue([status.subscribedChannels containsObject:[self otherClientChannelName]]);
            XCTAssertTrue([client.channels containsObject:[self otherClientChannelName]]);
            XCTAssertEqual(status.operation, PNSubscribeOperation);
            [self.subscribeExpectation fulfill];
            self.subscribeExpectation = nil;
        };
        [self PNTest_subscribeToChannels:@[[self otherClientChannelName]] withPresence:YES];
    } else if (self.invocation.selector == @selector(testJoinEvent)) {
        PNWeakify(self);
        self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
            PNStrongify(self);
            XCTAssertNotNil(client);
            XCTAssertNotNil(status);
            XCTAssertEqualObjects(self.client, client);
            XCTAssertEqual(status.category, PNDisconnectedCategory);
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.statusCode, 200);
            XCTAssertEqual(status.operation, PNUnsubscribeOperation);
            XCTAssertFalse([status.subscribedChannels containsObject:[self otherClientChannelName]]);
            XCTAssertFalse([client.channels containsObject:[self otherClientChannelName]]);
            [self.unsubscribeExpectation fulfill];
            self.unsubscribeExpectation = nil;
        };
        [self PNTest_unsubscribeFromChannels:@[[self otherClientChannelName]] withPresence:YES];
    }
}

- (PNConfiguration *)overrideClientConfiguration:(PNConfiguration *)configuration {
    if (self.invocation.selector == @selector(testTimeoutEvent)) {
        configuration.presenceHeartbeatValue = 5;
    }
    return configuration;
}

- (BOOL)isRecording{
    return YES;
}

- (void)tearDown {
    if (
        (self.invocation.selector == @selector(testJoinEvent)) &&
        (self.invocation.selector == @selector(testStateChangeEvent))
        ) {
        PNWeakify(self);
        self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
            PNStrongify(self);
            XCTAssertNotNil(client);
            XCTAssertNotNil(status);
            XCTAssertEqualObjects(self.client, client);
            XCTAssertEqual(status.category, PNDisconnectedCategory);
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.statusCode, 200);
            XCTAssertEqual(status.operation, PNUnsubscribeOperation);
            XCTAssertFalse([status.subscribedChannels containsObject:[self otherClientChannelName]]);
            XCTAssertFalse([client.channels containsObject:[self otherClientChannelName]]);
            [self.unsubscribeExpectation fulfill];
        };
        [self PNTest_unsubscribeFromChannels:@[[self otherClientChannelName]] withPresence:YES];
    }
    
    
    [super tearDown];
}

/**
 All tests according to events we have in: https://github.com/pubnub/pubnub-docs/blob/master/components/presence/design/overview.asciidoc
 */

- (void)testJoinEvent {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        XCTAssertEqual(status.category, PNConnectedCategory);
        [self.subscribeExpectation fulfill];
        self.subscribeExpectation = nil;
    };
    self.otherClientPresenceEventAssertions = ^void (PubNub *client, PNPresenceEventResult *event) {
        PNStrongify(self);
        NSLog(@"------------------------");
        NSLog(@"event: %@", event.debugDescription);
        if (
            ![event.data.presenceEvent isEqualToString:@"join"] ||
            ![self.otherClient isEqual:client]
            ) {
            NSLog(@"------------------------");
            return;
        }
        XCTAssertEqualObjects(self.otherClient, client);
        XCTAssertNotNil(event);
        XCTAssertTrue(event.statusCode == 200, @"Status code is not right");
        
        XCTAssertEqual(event.operation, PNSubscribeOperation);
        
        XCTAssertEqualObjects(event.data.presence.occupancy, @3, @"Occupancy is not equal");
        XCTAssertEqualObjects(event.data.presence.uuid, @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C", @"Occupancy is not equal");
        XCTAssertEqualObjects(event.data.presence.timetoken, @1450298326, @"Timetoken is not the same.");
        XCTAssertEqualObjects(event.data.presenceEvent, @"join");
        XCTAssertEqualObjects(event.data.actualChannel, [self presenceSubscribableFromString:[self otherClientChannelName]]);
        XCTAssertEqualObjects(event.data.subscribedChannel, [self presenceSubscribableFromString:[self channelGroupName]], @"Subscribed channel are not equal.");
        XCTAssertEqualObjects(event.data.presence.actualChannel, [self otherClientChannelName]);
        XCTAssertEqualObjects(event.data.presence.subscribedChannel, [self channelGroupName]);
        XCTAssertEqualObjects(event.data.timetoken, @14502983262037275, @"Timetoken is not the same.");
        NSLog(@"------------------------");
        [self.presenceEventExpectation fulfill];
        self.presenceEventExpectation = nil;
    };
    self.presenceEventExpectation = [self expectationWithDescription:@"presenceEvent"];
    [self PNTest_subscribeToChannels:@[[self otherClientChannelName]] withPresence:YES];
}

- (void)testLeaveEvent {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        XCTAssertEqual(status.category, PNDisconnectedCategory);
        [self.unsubscribeExpectation fulfill];
    };
    self.otherClientPresenceEventAssertions = ^void (PubNub *client, PNPresenceEventResult *event) {
        PNStrongify(self);
        NSLog(@"------------------------");
        NSLog(@"event: %@", event.debugDescription);
        if (
            ![event.data.presenceEvent isEqualToString:@"leave"] ||
            ![self.otherClient isEqual:client]
            ) {
            NSLog(@"------------------------");
            return;
        }
        XCTAssertEqualObjects(self.otherClient, client);
        XCTAssertNotNil(event);
        XCTAssertTrue(event.statusCode == 200, @"Status code is not right");
        
        XCTAssertEqual(event.operation, PNSubscribeOperation);
        
        XCTAssertEqualObjects(event.data.presence.occupancy, @2, @"Occupancy is not equal");
        XCTAssertEqualObjects(event.data.presence.uuid, @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C", @"Occupancy is not equal");
        XCTAssertEqualObjects(event.data.presence.timetoken, @1450298493, @"Timetoken is not the same.");
        XCTAssertEqualObjects(event.data.presenceEvent, @"leave");
        XCTAssertEqualObjects(event.data.actualChannel, [self presenceSubscribableFromString:[self otherClientChannelName]]);
        XCTAssertEqualObjects(event.data.subscribedChannel, [self presenceSubscribableFromString:[self channelGroupName]], @"Subscribed channel are not equal.");
        XCTAssertEqualObjects(event.data.presence.actualChannel, [self otherClientChannelName]);
        XCTAssertEqualObjects(event.data.presence.subscribedChannel, [self channelGroupName]);
        XCTAssertEqualObjects(event.data.timetoken, @14502984939183990, @"Timetoken is not the same.");
        NSLog(@"------------------------");
        [self.presenceEventExpectation fulfill];
        self.presenceEventExpectation = nil;
    };
    self.presenceEventExpectation = [self expectationWithDescription:@"presenceEvent"];
    [self PNTest_unsubscribeFromChannels:@[[self otherClientChannelName]] withPresence:YES];
}

- (void)testTimeoutEvent {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        XCTAssertEqual(status.category, PNConnectedCategory);
        [self.subscribeExpectation fulfill];
        self.client = nil;
    };
    self.otherClientPresenceEventAssertions = ^void (PubNub *client, PNPresenceEventResult *event) {
        PNStrongify(self);
        NSLog(@"------------------------");
        NSLog(@"event: %@", event.debugDescription);
        if (
            ![event.data.presenceEvent isEqualToString:@"timeout"] ||
            ![self.otherClient isEqual:client]
            ) {
            NSLog(@"------------------------");
            return;
        }
        XCTAssertEqualObjects(self.otherClient, client);
        XCTAssertNotNil(event);
        XCTAssertTrue(event.statusCode == 200, @"Status code is not right");
        
        XCTAssertEqual(event.operation, PNSubscribeOperation);
        
        XCTAssertEqualObjects(event.data.presence.occupancy, @2, @"Occupancy is not equal");
        XCTAssertEqualObjects(event.data.presence.uuid, @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C", @"UUID is not equal");
        XCTAssertEqualObjects(event.data.presence.timetoken, @1450298581, @"Timetoken is not the same.");
        XCTAssertEqualObjects(event.data.actualChannel, [self presenceSubscribableFromString:[self otherClientChannelName]]);
        XCTAssertEqualObjects(event.data.subscribedChannel, [self presenceSubscribableFromString:[self channelGroupName]], @"Subscribed channel are not equal.");
        XCTAssertEqualObjects(event.data.presence.actualChannel, [self otherClientChannelName]);
        XCTAssertEqualObjects(event.data.presence.subscribedChannel, [self channelGroupName]);
        XCTAssertEqualObjects(event.data.presenceEvent, @"timeout");
        XCTAssertEqualObjects(event.data.timetoken, @14502985810279040, @"Timetoken is not the same.");
        NSLog(@"------------------------");
        [self.presenceEventExpectation fulfill];
    };
    self.presenceEventExpectation = [self expectationWithDescription:@"presenceEvent"];
    [self PNTest_subscribeToChannels:@[[self otherClientChannelName]] withPresence:YES];
}

#warning should PNPresenceEventResult have a null occupancy field?
- (void)testStateChangeEvent {
    NSDictionary *expectedState = @{@"foo" : @"bar"};
    PNWeakify(self);
    self.otherClientPresenceEventAssertions = ^void (PubNub *client, PNPresenceEventResult *event) {
        PNStrongify(self);
        NSLog(@"------------------------");
        NSLog(@"event: %@", event.debugDescription);
        if (
            ![event.data.presenceEvent isEqualToString:@"state-change"] ||
            ![self.otherClient isEqual:client]
            ) {
            NSLog(@"------------------------");
            return;
        }
        XCTAssertEqualObjects(self.otherClient, client);
        XCTAssertNotNil(event);
        XCTAssertTrue(event.statusCode == 200, @"Status code is not right");
        
        XCTAssertEqual(event.operation, PNSubscribeOperation);
        
        //        XCTAssertEqualObjects(event.data.presence.occupancy, @2, @"Occupancy is not equal");
        XCTAssertEqualObjects(event.data.presence.uuid, @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C", @"UUID is not equal");
        XCTAssertEqualObjects(event.data.presence.timetoken, @1450298651, @"Timetoken is not the same.");
        XCTAssertEqualObjects(event.data.presenceEvent, @"state-change");
        XCTAssertEqualObjects(event.data.actualChannel, [self presenceSubscribableFromString:[self otherClientChannelName]]);
        XCTAssertEqualObjects(event.data.subscribedChannel, [self presenceSubscribableFromString:[self channelGroupName]], @"Subscribed channel are not equal.");
        XCTAssertEqualObjects(event.data.presence.actualChannel, [self otherClientChannelName]);
        XCTAssertEqualObjects(event.data.presence.subscribedChannel, [self channelGroupName]);
        XCTAssertEqualObjects(event.data.presence.state, expectedState, @"State are not equal");
        XCTAssertEqualObjects(event.data.timetoken, @14502986513160817, @"Timetoken is not the same.");
        NSLog(@"------------------------");
        [self.presenceEventExpectation fulfill];
    };
    self.presenceEventExpectation = [self expectationWithDescription:@"presenceEvent"];
    XCTestExpectation *stateExpectation = [self expectationWithDescription:@"stateExpectation"];
    [self.client setState:expectedState forUUID:self.client.uuid onChannel:[self otherClientChannelName] withCompletion:^(PNClientStateUpdateStatus *status) {
        NSLog(@"state status: %@", status.debugDescription);
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNSetStateOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertNotNil(status.data.state);
        XCTAssertEqualObjects(status.data.state, expectedState);
        [stateExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

@end
