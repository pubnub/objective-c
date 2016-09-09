//
//  PNBasicSubscribeTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import "PNBasicSubscribeTestCase.h"

@implementation PNSubscribeTestData

- (instancetype)init {
    self = [super init];
    if (self) {
        _shouldReceiveMessage = YES;
    }
    return self;
}

@end

@implementation PNBasicSubscribeTestCase

- (void)setUp {
    [super setUp];
    [self.client addListener:self];
    self.subscribeExpectation = nil;
    self.unsubscribeExpectation = nil;
}

- (void)tearDown {
    self.subscribeExpectation = nil;
    self.unsubscribeExpectation = nil;
    [self.client removeListener:self];
    [super tearDown];
}

#pragma mark - Helpers

- (void)PNTest_subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence {
    
    [self PNTest_subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:nil];
}

- (void)PNTest_subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
                    usingTimeToken:(NSNumber *)timeToken {
    
    self.subscribeExpectation = [self expectationWithDescription:@"subscribe"];
    [self.client subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:timeToken];
    [self waitForExpectationsWithTimeout:25 handler:^(NSError *error) {
        if (error) {
            XCTAssertNotNil(error);
        }
    }];
}

- (void)PNTest_subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence withClientState:(NSDictionary *)clientState {
    self.subscribeExpectation = [self expectationWithDescription:@"subscribe"];
    [self.client subscribeToChannels:channels withPresence:shouldObservePresence clientState:clientState];
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)PNTest_subscribeToPresenceChannels:(NSArray *)channels {
    self.subscribeExpectation = [self expectationWithDescription:@"subscribe"];
    [self.client subscribeToPresenceChannels:channels];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)PNTest_unsubscribeFromAll {
    
    self.unsubscribeExpectation = [self expectationWithDescription:@"unsubscribe"];
    [self.client unsubscribeFromAll];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)PNTest_unsubscribeFromChannels:(NSArray *)channels {
    
    [self PNTest_unsubscribeFromChannels:channels withPresence:NO];
}

- (void)PNTest_unsubscribeFromChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence {
    self.unsubscribeExpectation = [self expectationWithDescription:@"unsubscribe"];
    [self.client unsubscribeFromChannels:channels withPresence:shouldObservePresence];
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)PNTest_unsubscribeFromPresenceChannels:(NSArray *)channels {
    self.subscribeExpectation = [self expectationWithDescription:@"subscribe"];
    [self.client unsubscribeFromPresenceChannels:channels];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)PNTest_subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence {
    self.channelGroupSubscribeExpectation = [self expectationWithDescription:@"channelGroupSubscribe"];
    [self.client subscribeToChannelGroups:groups withPresence:shouldObservePresence];
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)PNTest_subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence usingTimeToken:(NSNumber *)timeToken {
    self.channelGroupSubscribeExpectation = [self expectationWithDescription:@"channelGroupSubscribe"];
    [self.client subscribeToChannelGroups:groups withPresence:shouldObservePresence usingTimeToken:timeToken];
    [self waitForExpectationsWithTimeout:15 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)PNTest_unsubscribeFromChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence {
    self.channelGroupUnsubscribeExpectation = [self expectationWithDescription:@"channelGroupUnsubscribe"];
    [self.client unsubscribeFromChannelGroups:groups withPresence:shouldObservePresence];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)PNTest_sendAndReceiveMessageWithTestData:(PNSubscribeTestData *)testData {
    PNWeakify(self);
    __block BOOL hasPublishedMessage = NO;
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
//        XCTAssertEqualObjects(status.subscribedChannels, @[kPNChannelTestName]);
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannels], [NSSet setWithArray:testData.subscribedChannels]);
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannelGroups], [NSSet setWithArray:testData.subscribedChannelGroups]);
        
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
//        XCTAssertEqualObjects(status.currentTimetoken, @14490969656951470);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        if (hasPublishedMessage) {
            return;
        }
        hasPublishedMessage = YES;
        [self.client publish:testData.publishMessage toChannel:testData.publishChannel
                withMetadata:testData.publishMetadata completion:^(PNPublishStatus *status) {
                    
            NSLog(@"status: %@", status.debugDescription);
            XCTAssertNotNil(status);
            XCTAssertFalse(status.isError);
            XCTAssertEqualObjects(status.data.timetoken, testData.expectedPublishTimetoken);
            XCTAssertEqualObjects(status.data.information, testData.expectedPublishInformation);
            [self fulfillSubscribeExpectationAfterDelay:10];
            [self.publishExpectation fulfill];
        }];
        
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        if (testData.shouldReceiveMessage) {
            XCTAssertEqualObjects(self.client, client);
            XCTAssertEqualObjects(client.uuid, message.uuid);
            XCTAssertNotNil(message.uuid);
            XCTAssertNil(message.authKey);
            XCTAssertEqual(message.statusCode, 200);
            XCTAssertTrue(message.TLSEnabled);
            XCTAssertEqual(message.operation, PNSubscribeOperation);
            NSLog(@"message:");
            NSLog(@"%@", message.data.message);
            XCTAssertNotNil(message.data);
            XCTAssertEqualObjects(message.data.message, testData.publishMessage);
            XCTAssertEqualObjects(message.data.channel, testData.expectedMessageSubscribedChannel);
            XCTAssertEqualObjects(message.data.timetoken, testData.expectedMessageTimetoken);
        } else {
            XCTFail(@"Should not receive a message, received: %@", message.debugDescription);
        }
        [self.subscribeExpectation fulfill];
    };
    self.publishExpectation = [self expectationWithDescription:@"publish"];
    if (testData.subscribedChannels.count) {
        self.subscribeExpectation = [self expectationWithDescription:@"subscribe"];
        [self.client subscribeToChannels:testData.subscribedChannels withPresence:NO];
    }
    if (testData.subscribedChannelGroups.count) {
        self.channelGroupSubscribeExpectation = [self expectationWithDescription:@"channelGroupSubscribe"];
        [self.client subscribeToChannelGroups:testData.subscribedChannelGroups withPresence:NO];
    }
    [self waitForExpectationsWithTimeout:15 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error, @"error is %@", error.localizedDescription);
    }];
}

#pragma mark - Helpers

- (void)fulfillSubscribeExpectationAfterDelay:(NSTimeInterval)delay {
    PNWeakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        PNStrongify(self);
        [self.channelGroupSubscribeExpectation fulfill];
        [self.subscribeExpectation fulfill];
    });
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    if (self.didReceiveMessageAssertions) {
        self.didReceiveMessageAssertions(client, message);
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    if (self.didReceivePresenceEventAssertions) {
        self.didReceivePresenceEventAssertions(client, event);
    }
}

- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status {
    if (self.didReceiveStatusAssertions) {
        self.didReceiveStatusAssertions(client, status);
    }
}


@end