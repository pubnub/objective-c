//
//  PNSubscribeToPresenceChannelsTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/30/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "PNBasicSubscribeTestCase.h"

@interface PNSubscribeToPresenceChannelsTests : PNBasicSubscribeTestCase

@end

@implementation PNSubscribeToPresenceChannelsTests

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

- (void)testSimpleSubscribeToPresenceChannels {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        NSArray *expectedPresenceSubscriptions = @[@"a-pnpres"];
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannels],
                              [NSSet setWithArray:expectedPresenceSubscriptions]);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        XCTAssertEqualObjects(status.currentTimetoken, @14356558880455349);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        [self.subscribeExpectation fulfill];
    };
    [self PNTest_subscribeToPresenceChannels:[self subscriptionChannels]];
}

@end
