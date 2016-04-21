//
//  PNSubscribeTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/20/16.
//
//

#import "PNSubscribeTestCase.h"

@interface PNSubscribeTestCase ()

@property (nonatomic, strong) XCTestExpectation *setUpExpectation;
@property (nonatomic, strong) XCTestExpectation *tearDownExpectation;

@end

@implementation PNSubscribeTestCase

- (void)setUp {
    [super setUp];
    [self.client addListener:self];
    self.setUpExpectation = [self expectationWithDescription:@"setUp"];
    [self.client subscribeToChannels:self.subscribedChannels withPresence:self.shouldSubscribeWithPresence];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
}

- (void)tearDown {
    self.tearDownExpectation = [self expectationWithDescription:@"tearDown"];
    [self.client unsubscribeFromAll];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];
    [self.client removeListener:self];
    [super tearDown];
}

#pragma mark - Subscribed Channels

- (NSArray<NSString *> *)subscribedChannels {
    return @[@"a"];
}

- (BOOL)shouldSubscribeWithPresence {
    return NO;
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    NSLog(@"status: %@", status.debugDescription);
    if (status.operation == PNSubscribeOperation) {
        XCTAssertEqualObjects(self.client.channels, self.subscribedChannels);
        PNSubscribeStatus *subscribeStatus = (PNSubscribeStatus *)status;
        XCTAssertEqualObjects(subscribeStatus.subscribedChannels, self.subscribedChannels);
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
