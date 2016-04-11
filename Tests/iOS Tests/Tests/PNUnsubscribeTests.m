//
//  PNUnsubscribeTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import <PubNub/PubNub.h>

#import "PNBasicSubscribeTestCase.h"

@interface PNUnsubscribeTests : PNBasicSubscribeTestCase

/**
 @brief  Setup test environment for test which perform regular unsubscription test.
 */
- (void)setupForUnsubscriptionFromChannelsTest;

/**
 @brief  Setup test environment for test which perform unsubscription from all channels and groups.
 */
- (void)setupForUnsubscriptionFromAllTest;

/**
 @brief  Setup channel group for one of tests.
 */
- (void)setupChannelGroup;

@end


@implementation PNUnsubscribeTests

- (BOOL)isRecording{
    return NO;
}

- (void)setUp {
    [super setUp];
    
    if ([NSStringFromSelector(self.invocation.selector) isEqualToString:@"testUnsubscribeWithPresence"]) {
        
        [self setupForUnsubscriptionFromChannelsTest];
    }
    else { [self setupForUnsubscriptionFromAllTest]; }
}

- (void)setupForUnsubscriptionFromChannelsTest {
    
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
        XCTAssertEqualObjects(status.currentTimetoken, @14603978075142357);
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
        XCTAssertNil(message.data.actualChannel);
        XCTAssertEqualObjects(message.data.subscribedChannel, @"a");
        XCTAssertEqualObjects(message.data.message, @"***********.... 8968 - 2016-04-11 11:03:27");
        [self.subscribeExpectation fulfill];
    };
    [self PNTest_subscribeToChannels:@[@"a"] withPresence:YES];
}

- (void)setupForUnsubscriptionFromAllTest {
    
    [self setupChannelGroup];
    PNWeakify(self);
    self.subscribeExpectation = [self expectationWithDescription:@"subscribe"];
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSArray *expectedChannels = @[@"unsubscribe-channel-test", @"unsubscribe-channel-test-pnpres"];
        NSArray *expectedGroups = @[@"unsubscribe-group-test", @"unsubscribe-group-test-pnpres"];
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannels],
                              [NSSet setWithArray:expectedChannels]);
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannelGroups],
                              [NSSet setWithArray:expectedGroups]);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        XCTAssertEqualObjects(status.currentTimetoken, @14603978067682070);
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        [self.subscribeExpectation fulfill];
    };
    [self.client subscribeToChannels:@[@"unsubscribe-channel-test"] withPresence:YES];
    [self.client subscribeToChannelGroups:@[@"unsubscribe-group-test"] withPresence:YES];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)setupChannelGroup {
    
    PNWeakify(self);
    XCTestExpectation *channelGroupExpecation = [self expectationWithDescription:@"addChannelsToGroup"];
    [self.client addChannels:@[@"test-channel"] toGroup:@"unsubscribe-group-test"
              withCompletion:^(PNAcknowledgmentStatus *status) {
                  
                  PNStrongify(self);
                  XCTAssertNotNil(status);
                  XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                  XCTAssertFalse(status.isError);
                  XCTAssertEqual(status.statusCode, 200);
                  XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
                  [channelGroupExpecation fulfill];
              }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testUnsubscribeWithPresence {
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(client);
        XCTAssertNotNil(status);
        XCTAssertEqualObjects(self.client, client);
        if (
            !(
              (status.category == PNDisconnectedCategory) ||
              (status.category == PNCancelledCategory)
              )
            ) {
            return;
        }
        XCTAssertEqual(status.category, PNDisconnectedCategory);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        NSLog(@"category: %@", status.stringifiedCategory);
        NSLog(@"operation: %@", status.stringifiedOperation);
        [self.unsubscribeExpectation fulfill];
    };
    [self PNTest_unsubscribeFromChannels:@[@"a"] withPresence:YES];
}

- (void)testUnsubscribeFromAll {
    
    PNWeakify(self);
    self.unsubscribeExpectation = [self expectationWithDescription:@"unsubscribe"];
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        
        PNStrongify(self);
        XCTAssertNotNil(client);
        XCTAssertNotNil(status);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertEqual(status.category, PNDisconnectedCategory);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        XCTAssertEqual(status.subscribedChannels.count, 0,
                       @"There should be no channels after complete unsubscribe");
        XCTAssertEqual(status.subscribedChannelGroups.count, 0,
                       @"There should be no channel groups after complete unsubscribe");
        [self.unsubscribeExpectation fulfill];
    };
    [self.client unsubscribeFromAll];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end