//
//  PNUnsubscribeTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "PNBasicSubscribeTestCase.h"

@interface PNUnsubscribeTests : PNBasicSubscribeTestCase
@end

@implementation PNUnsubscribeTests

- (BOOL)isRecording{
    return NO;
}

- (void)setUp {
    [super setUp];
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        NSArray *expectedPresenceSubscriptions = @[@"a", @"a-pnpres"];
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannels],
                              [NSSet setWithArray:expectedPresenceSubscriptions]);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        XCTAssertEqualObjects(status.currentTimetoken, @14356475647691168);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        
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
        XCTAssertEqualObjects(message.data.message, @"****........... 7161 - 2015-06-29 23:59:25");
        [self.subscribeExpectation fulfill];
    };
    [self PNTest_subscribeToChannels:@[@"a"] withPresence:YES];
    
}

- (void)testUnsubscribeWithPresence {
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
    [self PNTest_unsubscribeFromChannels:@[@"a"] withPresence:YES];
}

@end
