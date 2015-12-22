//
//  PNClientConfigurationTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/29/15.
//
//

#import <PubNub/PubNub.h>

#import "PNBasicSubscribeTestCase.h"

@interface PNClientConfigurationTests : PNBasicSubscribeTestCase
@end

@implementation PNClientConfigurationTests

- (BOOL)isRecording{
    return NO;
}

- (NSArray *)subscriptionChannels {
    return @[
             @"a"
             ];
}

- (void)setUp {
    [super setUp];
    if (
        (self.invocation.selector != @selector(testCopyConfigurationWithSubscribedChannels)) &&
        (self.invocation.selector != @selector(testCopyConfigurationWithSubscribedChannelsAndCallbackQueue))
         ) {
        return;
    }
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
        if (self.invocation.selector == @selector(testCopyConfigurationWithSubscribedChannels)) {
            XCTAssertEqualObjects(status.currentTimetoken, @14508105355672413);
        } else if (self.invocation.selector == @selector(testCopyConfigurationWithSubscribedChannelsAndCallbackQueue)) {
            XCTAssertEqualObjects(status.currentTimetoken, @14508105367362132);
        }
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        [self.subscribeExpectation fulfill];
        
    };
    [self PNTest_subscribeToChannels:[self subscriptionChannels] withPresence:NO];
    self.didReceiveStatusAssertions = nil;
}

- (void)testCreateClientWithBasicConfiguration {
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
    XCTAssertNotNil(config);
    PubNub *simpleClient = [PubNub clientWithConfiguration:config];
    XCTAssertNotNil(simpleClient);
}

- (void)testCreateClientWithCallbackQueue {
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
    XCTAssertNotNil(config);
    dispatch_queue_t callbackQueue = dispatch_queue_create("com.testCreateClientWithCallbackQueue", DISPATCH_QUEUE_SERIAL);
    PubNub *simpleClient = [PubNub clientWithConfiguration:config callbackQueue:callbackQueue];
    XCTAssertNotNil(simpleClient);
}

// we should do something if we are trying to make a copy with no changes, instead of silently failing
- (void)testSimpleCopyConfigurationWithNoSubscriptions {
    XCTAssertNotNil(self.client);
    XCTAssertEqualObjects(self.client.uuid, @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C");
    PNWeakify(self);
    XCTestExpectation *copyExpectation = [self expectationWithDescription:@"copy"];
    NSString *changedUUID = @"changed";
    self.configuration.uuid = changedUUID;
    [self.client copyWithConfiguration:self.configuration completion:^(PubNub *client) {
        PNStrongify(self);
        XCTAssertNotEqualObjects(self.client, client.uuid);
        XCTAssertEqual(client.uuid, changedUUID);
        [copyExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testSimpleCopyConfigurationWithNoSubscriptionAndCallbackQueue {
    XCTAssertNotNil(self.client);
    XCTAssertEqualObjects(self.client.uuid, @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C");
    PNWeakify(self);
    XCTestExpectation *copyExpectation = [self expectationWithDescription:@"copy"];
    [self.client copyWithConfiguration:self.configuration completion:^(PubNub *client) {
        PNStrongify(self);
        XCTAssertNotEqualObjects(self.client, client.uuid);
        XCTAssertEqual(client.uuid, self.client.uuid);
        [copyExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testCopyConfigurationWithSubscribedChannels {
    self.didReceiveStatusAssertions = nil;
    XCTAssertNotNil(self.client);
    XCTAssertEqualObjects(self.client.uuid, @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C");
    PNWeakify(self);
    XCTestExpectation *copyExpectation = [self expectationWithDescription:@"copy"];
    NSString *changedUUID = @"changed";
    self.configuration.uuid = changedUUID;
    [self.client copyWithConfiguration:self.configuration completion:^(PubNub *client) {
        PNStrongify(self);
        XCTAssertNotEqualObjects(self.client, client.uuid);
        XCTAssertEqual(client.uuid, changedUUID);
        [copyExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testCopyConfigurationWithSubscribedChannelsAndCallbackQueue {
    self.didReceiveStatusAssertions = nil;
    XCTAssertNotNil(self.client);
    XCTAssertEqualObjects(self.client.uuid, @"322A70B3-F0EA-48CD-9BB0-D3F0F5DE996C");
    PNWeakify(self);
    XCTestExpectation *copyExpectation = [self expectationWithDescription:@"copy"];
    NSString *changedUUID = @"changed";
    self.configuration.uuid = changedUUID;
    [self.client copyWithConfiguration:self.configuration callbackQueue:dispatch_queue_create("com.testCopyCallbackQueue", DISPATCH_QUEUE_SERIAL) completion:^(PubNub *client) {
        PNStrongify(self);
        XCTAssertNotEqualObjects(self.client, client.uuid);
        XCTAssertEqual(client.uuid, changedUUID);
        [copyExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
