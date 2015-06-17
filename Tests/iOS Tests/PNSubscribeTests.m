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

- (BOOL)recording {
    return NO;
}

- (void)testSimpleSubscribe {
    self.subscribeExpectation = [self expectationWithDescription:@"network"];
    [self.client subscribeToChannels:@[@"a"] withPresence:NO];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveMessage:(PNResult<PNMessageResult> *)message withStatus:(PNStatus<PNStatus> *)status {
    XCTAssertNil(status);
    XCTAssertEqualObjects(self.client, client);
    XCTAssertEqualObjects(client.uuid, message.uuid);
    XCTAssertNotNil(message.uuid);
    XCTAssertNil(message.authKey);
    XCTAssertEqual(message.statusCode, 200);
    XCTAssertTrue(message.TLSEnabled);
    XCTAssertEqual(message.operation, PNSubscribeOperation);
    NSLog(@"message:");
    NSLog(@"%@", message.data.message);
    XCTAssertEqualObjects(message.data.message, @"************... 281 - 2015-06-17 12:13:32");
    [self.subscribeExpectation fulfill];
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNResult<PNPresenceEventResult> *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus<PNSubscriberStatus> *)status {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
