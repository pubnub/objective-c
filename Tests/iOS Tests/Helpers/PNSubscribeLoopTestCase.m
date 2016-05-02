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
@property (nonatomic, assign) BOOL isSettingUp;
@property (nonatomic, assign) BOOL isTearingDown;
@end

@implementation PNSubscribeLoopTestCase

- (void)setUp {
    [super setUp];
    self.isSettingUp = YES;
    self.isTearingDown = NO;
    [self.client addListener:self];
    if (![self shouldRunSetUp]) {
        self.isSettingUp = NO;
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
        self.isSettingUp = NO;
    }];
}

- (void)tearDown {
    if ([self shouldRunTearDown]) {
        self.isTearingDown = YES;
        self.tearDownExpectation = [self expectationWithDescription:@"tearDown"];
        [self.client unsubscribeFromAll];
        [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
            XCTAssertNil(error);
        }];
    }
    [self.client removeListener:self];
    self.isTearingDown = NO;
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

#pragma mark - Helpers

- (BOOL)expectedSubscribeChannelsMatches:(NSArray<NSString *> *)actualChannels {
    if (
        !actualChannels &&
        !self.subscribedChannels
        ) {
        return YES;
    }
    NSArray *finalExpectedChannels = self.subscribedChannels;
    if (self.shouldSubscribeWithPresence) {
        NSMutableArray<NSString *> *updatedExpectedChannels = [NSMutableArray array];
        for (NSString *channel in finalExpectedChannels) {
            [updatedExpectedChannels addObject:channel];
            NSString *presenceChannel = [channel stringByAppendingString:@"-pnpres"];
            [updatedExpectedChannels addObject:presenceChannel];
        }
        finalExpectedChannels = updatedExpectedChannels.mutableCopy;
    }
    NSSet *expectedChannelsSet = [NSSet setWithArray:finalExpectedChannels];
    NSSet *actualChannelsSet = [NSSet setWithArray:actualChannels];
    
    return [expectedChannelsSet isEqualToSet:actualChannelsSet];
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    if (self.isSettingUp) {
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqualObjects(self.client.channels, self.subscribedChannels);
        PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
//        XCTAssertEqualObjects(subscribeStatus.subscribedChannels, self.subscribedChannels);
        XCTAssertTrue([self expectedSubscribeChannelsMatches:subscribeStatus.subscribedChannels]);
        XCTAssertEqualObjects(subscribeStatus.subscribedChannelGroups, self.subscribedChannelGroups);
        //        XCTAssertEqualObjects(subscribeStatus.data.timetoken, @14612663455086844);
        //        XCTAssertEqualObjects(subscribeStatus.data.subscribedChannel, self.subscribedChannels.firstObject);
        //        XCTAssertEqualObjects(subscribeStatus.data.actualChannel, self.subscribedChannels.firstObject);
        [self.setUpExpectation fulfill];
        return; // return after setUp
    } else if (self.isTearingDown) {
        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        XCTAssertEqual(status.category, PNDisconnectedCategory);
        XCTAssertEqualObjects(self.client.channels, @[]);
        PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
        XCTAssertEqualObjects(subscribeStatus.subscribedChannels, @[]);
        //        XCTAssertEqualObjects(subscribeStatus.data.timetoken, @12);
        //        XCTAssertEqualObjects(subscribeStatus.data.subscribedChannel, self.subscribedChannels.firstObject);
        //        XCTAssertEqualObjects(subscribeStatus.data.actualChannel, self.subscribedChannels.firstObject);
        [self.tearDownExpectation fulfill];
        return; //return after tearDown
    }
    if (self.didReceiveStatusHandler) {
        self.didReceiveStatusHandler(client, status);
    }
    
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    if (self.didReceiveMessageHandler) {
        self.didReceiveMessageHandler(client, message);
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    if (self.didReceivePresenceEventHandler) {
        self.didReceivePresenceEventHandler(client, event);
    }
}

@end
