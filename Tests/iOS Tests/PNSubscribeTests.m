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

- (void)testSimpleSubscribe {
    self.subscribeExpectation = [self expectationWithDescription:@"network"];
    [self.client subscribeToChannels:[self subscriptionChannels] withPresence:NO];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    XCTAssertEqualObjects(self.client, client);
    XCTAssertEqualObjects(client.uuid, message.uuid);
    XCTAssertNotNil(message.uuid);
    XCTAssertNil(message.authKey);
    XCTAssertEqual(message.statusCode, 200);
    XCTAssertTrue(message.TLSEnabled);
    XCTAssertEqual(message.operation, PNSubscribeOperation);
    NSLog(@"message:");
    NSLog(@"%@", message.data.message);
    XCTAssertEqualObjects(message.data.message, @"*******........ 9888 - 2015-06-28 15:54:23");
    [self.subscribeExpectation fulfill];
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
