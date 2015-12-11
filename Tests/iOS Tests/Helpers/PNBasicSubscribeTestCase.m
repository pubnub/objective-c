//
//  PNBasicSubscribeTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import "PNBasicSubscribeTestCase.h"

@implementation PNBasicSubscribeTestCase

- (void)setUp {
    [super setUp];
    [self.client addListener:self];
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
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
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

- (void)PNTest_unsubscribeFromChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence {
    self.unsubscribeExpectation = [self expectationWithDescription:@"unsubscribe"];
    [self.client unsubscribeFromChannels:channels withPresence:shouldObservePresence];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
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
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
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
