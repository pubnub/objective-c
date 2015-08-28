//
//  PNPresenceEventTests.m
//  PubNub Tests
//
//  Created by Vadim Osovets on 8/27/15.
//
//
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "PNBasicSubscribeTestCase.h"

@interface PNPresenceEventTests : PNBasicSubscribeTestCase

@property (nonatomic) NSString *uniqueName;

@end

@implementation PNPresenceEventTests

- (void)setUp {
    [super setUp];
    
    self.uniqueName = @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA";
}

- (BOOL)isRecording{
    return NO;
}

#pragma mark - Simple tests without preparing steps

/**
 All testes according to events we have in: https://github.com/pubnub/pubnub-docs/blob/master/components/presence/design/overview.asciidoc
 */

- (void)testJoinEvent {
    PNWeakify(self);
    self.didReceivePresenceEventAssertions = ^void (PubNub *client, PNPresenceEventResult *event) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(event);
        XCTAssertTrue(event.statusCode == 200, @"Status code is not right");
        
        XCTAssertEqual(event.operation, PNSubscribeOperation);
        
        XCTAssertEqualObjects(event.data.presence.occupancy, @1, @"Occupancy is not equal");
        XCTAssertEqualObjects(event.data.presence.uuid, @"affcb408-f5c1-4e97-923a-143701f3b083", @"Occupancy is not equal");
        XCTAssertEqualObjects(event.data.presence.timetoken, @1440754948, @"Timetoken is not the same.");
        XCTAssertEqualObjects(event.data.presenceEvent, @"join");
        XCTAssertEqualObjects(event.data.subscribedChannel, @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA", @"Subscribed channel are not equal.");
        XCTAssertEqualObjects(event.data.timetoken, @14407549482844872, @"Timetoken is not the same.");
    };
    
    [self PNTest_subscribeToPresenceChannels:@[self.uniqueName] withEventExpectation:YES];
}

- (void)testLeaveEvent {
    PNWeakify(self);
    self.didReceivePresenceEventAssertions = ^void (PubNub *client, PNPresenceEventResult *event) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(event);
        XCTAssertTrue(event.statusCode == 200, @"Status code is not right");
        
        XCTAssertEqual(event.operation, PNSubscribeOperation);
        
        XCTAssertEqualObjects(event.data.presence.occupancy, @0, @"Occupancy are not equal");
        XCTAssertEqualObjects(event.data.presence.uuid, @"affcb408-f5c1-4e97-923a-143701f3b083", @"UUIDs are not equal");
        XCTAssertEqualObjects(event.data.presence.timetoken, @1440773488, @"Timetoken is not the same.");
        XCTAssertEqualObjects(event.data.presenceEvent, @"leave");
        XCTAssertEqualObjects(event.data.subscribedChannel, @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA", @"Subscribed channel are not equal.");
        XCTAssertEqualObjects(event.data.timetoken, @14407734890045162, @"Timetoken is not the same.");
    };
    
    [self PNTest_subscribeToPresenceChannels:@[self.uniqueName] withEventExpectation:YES];
}

- (void)testTimeoutEvent {
    PNWeakify(self);
    self.didReceivePresenceEventAssertions = ^void (PubNub *client, PNPresenceEventResult *event) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(event);
        XCTAssertTrue(event.statusCode == 200, @"Status code is not right");
        
        XCTAssertEqual(event.operation, PNSubscribeOperation);
        
        XCTAssertEqualObjects(event.data.presence.occupancy, @1, @"Occupancy are not equal");
        XCTAssertEqualObjects(event.data.presence.uuid, @"29624e62-59e4-48f1-9f80-46bbac8fbc2e", @"UUIDs are not equal");
        XCTAssertEqualObjects(event.data.presence.timetoken, @1440776740, @"Timetoken is not the same.");
        XCTAssertEqualObjects(event.data.presenceEvent, @"timeout");
        XCTAssertEqualObjects(event.data.subscribedChannel, @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA", @"Subscribed channel are not equal.");
        XCTAssertEqualObjects(event.data.timetoken, @14407767410944227, @"Timetoken is not the same.");
    };
    
    [self PNTest_subscribeToPresenceChannels:@[self.uniqueName] withEventExpectation:YES];
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
    
    [self PNTest_subscribeToPresenceChannels:@[self.uniqueName] withEventExpectation:YES];
}

@end
