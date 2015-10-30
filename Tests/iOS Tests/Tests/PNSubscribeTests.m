//
//  PNSubscribeTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import <PubNub/PubNub.h>

#import "PNBasicSubscribeTestCase.h"

@interface PNSubscribeTests : PNBasicSubscribeTestCase
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

- (void)tearDown {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
//        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
//        XCTAssertEqual(status.category, PNDisconnectedCategory);
//        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
//        XCTAssertEqualObjects(status.currentTimetoken, @14355626738514132);
//        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        [self.unsubscribeExpectation fulfill];
        
    };
    [self PNTest_unsubscribeFromChannels:[self subscriptionChannels] withPresence:YES];
    [super tearDown];
}

- (void)testSimpleSubscribeWithPresence {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        NSArray *expectedPresenceSubscriptions = @[@"a", @"a-pnpres"];
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannels],
                              [NSSet setWithArray:expectedPresenceSubscriptions]);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        XCTAssertEqualObjects(status.currentTimetoken, @14356472220766752);
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
        XCTAssertEqualObjects(message.data.message, @"***********.... 6988 - 2015-06-29 23:53:42");
        [self.subscribeExpectation fulfill];
    };
    [self PNTest_subscribeToChannels:[self subscriptionChannels] withPresence:YES];
}

- (void)testSimpleSubscribeWithNoPresence {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        NSArray *expectedPresenceSubscriptions = @[@"a"];
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannels],
                              [NSSet setWithArray:expectedPresenceSubscriptions]);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        XCTAssertEqualObjects(status.currentTimetoken, @14356472196232226);
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
        XCTAssertEqualObjects(message.data.message, @"**********..... 6987 - 2015-06-29 23:53:40");
        [self.subscribeExpectation fulfill];
    };
    [self PNTest_subscribeToChannels:[self subscriptionChannels] withPresence:NO];
}

@end
