//
//  PNSubscribeTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "PNBasicSubscribeTestCase.h"

@interface PNSubscribeTests : PNBasicSubscribeTestCase <PNObjectEventListener>
@end

@implementation PNSubscribeTests

- (BOOL)isRecording{
    return NO;
}

- (NSArray *)subscriptionChannels {
    return @[
             @"a"
             ];
}

- (void)testSimpleSubscribeWithPresence {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        NSArray *expectedPresenceSubscriptions = @[@"a", @"a-pnpres"];
        XCTAssertEqualObjects(status.subscribedChannels, expectedPresenceSubscriptions);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        XCTAssertEqual(status.currentTimetoken, @14355377127740789);
        XCTAssertEqual(status.currentTimetoken, status.data.timetoken);
        
    };
    self.didReceiveMessageAssertions = ^void (PubNub *client, PNMessageResult *message) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertEqualObjects(client.uuid, message.uuid);
        XCTAssertNotNil(message.uuid);
        XCTAssertNil(message.authKey);
        XCTAssertEqual(message.statusCode, 200);
        XCTAssertTrue(message.TLSEnabled);
        XCTAssertEqual(message.operation, PNSubscribeOperation);
        NSLog(@"message:");
        NSLog(@"%@", message.data.message);
        XCTAssertEqualObjects(message.data.message, @"*.............. 2703 - 2015-06-28 17:28:33");
        [self.subscribeExpectation fulfill];
    };
    [self PNTest_subscribeToChannels:[self subscriptionChannels] withPresence:YES];
}

#pragma mark - Helpers

- (void)PNTest_subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence {
    self.subscribeExpectation = [self expectationWithDescription:@"network"];
    [self.client subscribeToChannels:[self subscriptionChannels] withPresence:YES];
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
