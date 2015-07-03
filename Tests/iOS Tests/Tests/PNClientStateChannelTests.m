//
//  PNClientStateChannelTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/29/15.
//
//

#import <PubNub/PubNub.h>

#import "PNBasicSubscribeTestCase.h"

@interface PNClientStateChannelTests : PNBasicSubscribeTestCase

@end

@implementation PNClientStateChannelTests

- (BOOL)isRecording{
    return NO;
}

- (NSArray *)subscriptionChannels {
    return @[
             @"a"
             ];
}

- (NSString *)unsubscribedChannel {
    return @"21";
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
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        NSArray *expectedPresenceSubscriptions = @[@"a"];
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannels],
                              [NSSet setWithArray:expectedPresenceSubscriptions]);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        
        if (self.invocation.selector == @selector(testSetClientStateOnNotSubscribedChannel)) {
            XCTAssertEqualObjects(status.currentTimetoken, @14356938649889605);
        } else if (self.invocation.selector == @selector(testSetClientStateOnSubscribedChannel)) {
            XCTAssertEqualObjects(status.currentTimetoken, @14356938670305577);
        } else if (self.invocation.selector == @selector(testStateForUUIDOnSubscribedChannel)) {
            XCTAssertEqualObjects(status.currentTimetoken, @14356938670305577);
        } else if (self.invocation.selector == @selector(testStateForUUIDOnUnsubscribedChannel)) {
            XCTAssertEqualObjects(status.currentTimetoken, @14356938670305577);
        } else {
            XCTFail(@"we haven't done anything to prepare for %@", NSStringFromSelector(self.invocation.selector));
        }
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        [self.subscribeExpectation fulfill];
        
    };
    [self PNTest_subscribeToChannels:[self subscriptionChannels] withPresence:NO];
    self.didReceiveStatusAssertions = nil;
}

- (void)tearDown {
    PNWeakify(self);
    // TODO: assertions during teardown
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        //        XCTAssertEqual(status.operation, PNUnsubscribeOperation);
        //        XCTAssertEqual(status.category, PNDisconnectedCategory);
        //        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        //        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        //        XCTAssertEqualObjects(status.currentTimetoken, @14355626738514132);
        //        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        [self.unsubscribeExpectation fulfill];
        
    };
    NSArray *channelsToRemove = [[self subscriptionChannels] arrayByAddingObjectsFromArray:@[[self unsubscribedChannel]]];
    [self PNTest_unsubscribeFromChannels:channelsToRemove withPresence:YES];
    [super tearDown];
}

- (void)testSetClientStateOnSubscribedChannel {
    PNWeakify(self);
    XCTestExpectation *stateExpectation = [self expectationWithDescription:@"clientState"];
    NSDictionary *state = @{
                            @"test" : @"test"
                            };
    [self.client setState:state forUUID:self.client.uuid onChannel:[self subscriptionChannels].firstObject withCompletion:^(PNClientStateUpdateStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNSetStateOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertEqualObjects(status.data.state, state);
        [stateExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testSetClientStateOnNotSubscribedChannel {
    PNWeakify(self);
    XCTestExpectation *stateExpectation = [self expectationWithDescription:@"clientState"];
    NSDictionary *state = @{
                            @"test" : @"test"
                            };
    [self.client setState:state forUUID:self.client.uuid onChannel:[self unsubscribedChannel] withCompletion:^(PNClientStateUpdateStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNSetStateOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertEqualObjects(status.data.state, state);
        [stateExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testStateForUUIDOnSubscribedChannel {
    PNWeakify(self);
    XCTestExpectation *stateExpectation = [self expectationWithDescription:@"clientState"];
    NSDictionary *state = @{
                            @"test" : @"test"
                            };
    [self.client stateForUUID:self.client.uuid onChannel:[self subscriptionChannels].firstObject withCompletion:^(PNChannelClientStateResult *result, PNErrorStatus *status) {
        PNStrongify(self);
        XCTAssertNil(status);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.operation, PNStateForChannelOperation);
        XCTAssertEqualObjects(result.data.state, state);
        XCTAssertEqual(result.statusCode, 200);
        [stateExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testStateForUUIDOnUnsubscribedChannel {
    PNWeakify(self);
    XCTestExpectation *stateExpectation = [self expectationWithDescription:@"clientState"];
    NSDictionary *state = @{
                            @"test" : @"test"
                            };
    [self.client stateForUUID:self.client.uuid onChannel:[self unsubscribedChannel] withCompletion:^(PNChannelClientStateResult *result, PNErrorStatus *status) {
        PNStrongify(self);
        XCTAssertNil(status);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.operation, PNStateForChannelOperation);
        XCTAssertEqualObjects(result.data.state, state);
        XCTAssertEqual(result.statusCode, 200);
        [stateExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
