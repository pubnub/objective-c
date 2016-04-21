//
//  PNSubscribeLoopTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/21/16.
//
//

#import "PNSubscribeLoopTestCase.h"

@interface PNSubscribeLoopTestCase ()
@property (nonatomic, strong) XCTestExpectation *setUpExpectation;
@property (nonatomic, strong) XCTestExpectation *tearDownExpectation;
@end

@implementation PNSubscribeLoopTestCase

- (void)setUp {
    [super setUp];
    [self.client addListener:self];
    if (![self shouldRunSetUp]) {
        return;
    }
    self.setUpExpectation = [self expectationWithDescription:@"setUp"];
    if (self.subscribedChannels.count) {
        [self.client subscribeToChannels:self.subscribedChannels withPresence:self.shouldSubscribeWithPresence];
    }
    if (self.subscribedChannelGroups.count) {
        [self.client subscribeToChannelGroups:self.subscribedChannelGroups withPresence:self.shouldSubscribeWithPresence];
    }
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)tearDown {
    if ([self shouldRunTearDown]) {
        self.tearDownExpectation = [self expectationWithDescription:@"tearDown"];
        [self.client unsubscribeFromAll];
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
            XCTAssertNil(error);
        }];
    }
    [self.client removeListener:self];
    [super tearDown];
}

#pragma mark - Subscribed Channels

- (NSArray<NSString *> *)subscribedChannels {
    return @[];
}

- (NSArray<NSString *> *)subscribedChannelGroups {
    return @[];;
}

- (BOOL)shouldSubscribeWithPresence {
    return NO;
}

- (BOOL)shouldRunSetUp {
    return YES;
}

- (BOOL)shouldRunTearDown {
    return YES;
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    NSLog(@"status: %@", status.debugDescription);
    if (status.operation == PNSubscribeOperation) {
        XCTAssertEqualObjects(self.client.channels, self.subscribedChannels);
        PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
        XCTAssertEqualObjects(subscribeStatus.subscribedChannels, self.subscribedChannels);
        XCTAssertEqualObjects(subscribeStatus.subscribedChannelGroups, self.subscribedChannelGroups);
        //        XCTAssertEqualObjects(subscribeStatus.data.timetoken, @14612663455086844);
        //        XCTAssertEqualObjects(subscribeStatus.data.subscribedChannel, self.subscribedChannels.firstObject);
        //        XCTAssertEqualObjects(subscribeStatus.data.actualChannel, self.subscribedChannels.firstObject);
        [self.setUpExpectation fulfill];
    } else if (status.operation == PNUnsubscribeOperation) {
        XCTAssertEqualObjects(self.client.channels, @[]);
        PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
        XCTAssertEqualObjects(subscribeStatus.subscribedChannels, @[]);
        //        XCTAssertEqualObjects(subscribeStatus.data.timetoken, @12);
        //        XCTAssertEqualObjects(subscribeStatus.data.subscribedChannel, self.subscribedChannels.firstObject);
        //        XCTAssertEqualObjects(subscribeStatus.data.actualChannel, self.subscribedChannels.firstObject);
        [self.tearDownExpectation fulfill];
    }
    
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    
}

@end
