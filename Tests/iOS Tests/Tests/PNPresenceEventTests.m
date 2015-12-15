//
//  PNPresenceEventTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 12/5/2015.
//
//

#import "PNBasicPresenceTestCase.h"



@interface PNPresenceEventTests : PNBasicPresenceTestCase

@property (nonatomic) NSString *uniqueName;

@end

@implementation PNPresenceEventTests

- (void)setUp {
    [super setUp];
    
    self.uniqueName = [self otherClientChannelName];
    [self.otherClient addListener:self];
//    sleep(2);
    if (self.invocation.selector == @selector(testLeaveEvent)) {
        PNWeakify(self);
        self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
            PNStrongify(self);
            XCTAssertNotNil(client);
            XCTAssertNotNil(status);
            XCTAssertEqualObjects(self.client, client);
            XCTAssertEqual(status.category, PNConnectedCategory);
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.statusCode, 200);
            XCTAssertEqual(status.operation, PNSubscribeOperation);
            [self.subscribeExpectation fulfill];
        };
        [self PNTest_subscribeToChannels:@[[self otherClientChannelName]] withPresence:YES];
    } else if (self.invocation.selector == @selector(testTimeoutEvent)) {
        PNWeakify(self);
        self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
            PNStrongify(self);
            XCTAssertNotNil(client);
            XCTAssertNotNil(status);
            XCTAssertEqualObjects(self.client, client);
            XCTAssertEqual(status.category, PNConnectedCategory);
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.statusCode, 200);
            XCTAssertEqual(status.operation, PNSubscribeOperation);
            [self.subscribeExpectation fulfill];
        };
        [self PNTest_subscribeToChannels:@[[self otherClientChannelName]] withPresence:YES];
    }
}

- (PNConfiguration *)overrideClientConfiguration:(PNConfiguration *)configuration {
    if (self.invocation.selector == @selector(testTimeoutEvent)) {
        configuration.presenceHeartbeatValue = 5;
    }
    return configuration;
}

- (BOOL)isRecording{
    return NO;
}

- (void)tearDown {
    if (self.invocation.selector == @selector(testJoinEvent)) {
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
    };
    self.otherClientPresenceEventAssertions = ^void (PubNub *client, PNPresenceEventResult *event) {
        PNStrongify(self);
        NSLog(@"------------------------");
        NSLog(@"event: %@", event.debugDescription);
        if (![event.data.presenceEvent isEqualToString:@"join"]) {
            NSLog(@"------------------------");
            return;
        }
        XCTAssertEqualObjects(self.otherClient, client);
        XCTAssertNotNil(event);
        XCTAssertTrue(event.statusCode == 200, @"Status code is not right");
        
        XCTAssertEqual(event.operation, PNSubscribeOperation);
        
        XCTAssertEqualObjects(event.data.presence.occupancy, @3, @"Occupancy is not equal");
        XCTAssertEqualObjects(event.data.presence.uuid, @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C", @"Occupancy is not equal");
        XCTAssertEqualObjects(event.data.presence.timetoken, @1450138038, @"Timetoken is not the same.");
        XCTAssertEqualObjects(event.data.presenceEvent, @"join");
        XCTAssertEqualObjects(event.data.subscribedChannel, @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA", @"Subscribed channel are not equal.");
        XCTAssertEqualObjects(event.data.timetoken, @14501380388803916, @"Timetoken is not the same.");
        NSLog(@"------------------------");
        [self.presenceEventExpectation fulfill];
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
        if (![event.data.presenceEvent isEqualToString:@"leave"]) {
            NSLog(@"------------------------");
            return;
        }
        XCTAssertEqualObjects(self.otherClient, client);
        XCTAssertNotNil(event);
        XCTAssertTrue(event.statusCode == 200, @"Status code is not right");
        
        XCTAssertEqual(event.operation, PNSubscribeOperation);
        
        XCTAssertEqualObjects(event.data.presence.occupancy, @1, @"Occupancy is not equal");
        XCTAssertEqualObjects(event.data.presence.uuid, @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C", @"Occupancy is not equal");
        XCTAssertEqualObjects(event.data.presence.timetoken, @1450192206, @"Timetoken is not the same.");
        XCTAssertEqualObjects(event.data.presenceEvent, @"leave");
        XCTAssertEqualObjects(event.data.subscribedChannel, [self otherClientChannelName], @"Subscribed channel are not equal.");
        XCTAssertEqualObjects(event.data.timetoken, @14501923950307194, @"Timetoken is not the same.");
        NSLog(@"------------------------");
        [self.presenceEventExpectation fulfill];
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
        XCTAssertEqualObjects(event.data.presence.uuid, @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C", @"Occupancy is not equal");
        XCTAssertEqualObjects(event.data.presence.timetoken, @1450194732, @"Timetoken is not the same.");
        XCTAssertEqualObjects(event.data.presenceEvent, @"timeout");
        XCTAssertEqualObjects(event.data.subscribedChannel, @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA", @"Subscribed channel are not equal.");
        XCTAssertEqualObjects(event.data.timetoken, @14501947328057316, @"Timetoken is not the same.");
        NSLog(@"------------------------");
        [self.presenceEventExpectation fulfill];
    };
    self.presenceEventExpectation = [self expectationWithDescription:@"presenceEvent"];
    [self PNTest_subscribeToChannels:@[[self otherClientChannelName]] withPresence:YES];
}

- (void)testStateChangeEvent {
    PNWeakify(self);
    self.didReceivePresenceEventAssertions = ^void (PubNub *client, PNPresenceEventResult *event) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(event);
        XCTAssertTrue(event.statusCode == 200, @"Status code is not right");
        
        XCTAssertEqual(event.operation, PNSubscribeOperation);
        
        XCTAssertEqualObjects(event.data.presence.uuid, @"29624e62-59e4-48f1-9f80-46bbac8fbc2e", @"UUIDs are not equal");
        XCTAssertEqualObjects(event.data.presence.timetoken, @1440778413, @"Timetoken is not the same.");
        XCTAssertEqualObjects(event.data.presenceEvent, @"state-change");
        XCTAssertEqualObjects(event.data.subscribedChannel, @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA", @"Subscribed channel are not equal.");
        
        XCTAssertEqualObjects(event.data.presence.state, @{@"test" : @"test"}, @"State are not equal");
        
        XCTAssertEqualObjects(event.data.timetoken, @14407784131674496, @"Timetoken is not the same.");
    };
    
    [self PNTest_subscribeToPresenceChannels:@[self.uniqueName]];
}

- (void)testIntervalEvent {
    PNWeakify(self);

    self.didReceivePresenceEventAssertions = ^void (PubNub *client, PNPresenceEventResult *event) {
        
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(event);
        XCTAssertTrue(event.statusCode == 200, @"Status code is not right");
        
        XCTAssertEqual(event.operation, PNSubscribeOperation);
        
        XCTAssertNil(event.data.presence.uuid, @"UUID should be nil");
        XCTAssertEqualObjects(event.data.presenceEvent, @"interval");
        XCTAssertEqualObjects(event.data.subscribedChannel, @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA", @"Subscribed channel are not equal.");
        
        XCTAssertEqualObjects(event.data.timetoken, @14411068884747343, @"Timetoken is not the same.");
    };
    
    [self PNTest_subscribeToPresenceChannels:@[self.uniqueName]];
}

@end
