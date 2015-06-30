//
//  PNClientStateChannelGroupTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/29/15.
//
//

#import <PubNub/PubNub.h>
#import "PNBasicSubscribeTestCase.h"

static NSString * const kPNChannelGroupTestsName = @"PNClientStateChannelGroupTests";

@interface PNClientStateChannelGroupTests : PNBasicSubscribeTestCase

@end

@implementation PNClientStateChannelGroupTests

- (BOOL)isRecording{
    return NO;
}

- (NSArray *)channelGroups {
    return @[
             kPNChannelGroupTestsName
             ];
}

- (NSString *)nonExistentChannelGroup {
    return @"42";
}

- (void)setUp {
    [super setUp];
    [self performVerifiedRemoveAllChannelsFromGroup:kPNChannelGroupTestsName withAssertions:nil];
    if (
        (self.invocation.selector != @selector(testSetClientStateOnSubscribedChannelGroup)) &&
        (self.invocation.selector != @selector(testStateForUUIDOnSubscribedChannelGroup))
        ) {
        return;
    }
    PNWeakify(self);
    [self performVerifiedAddChannels:@[@"a", @"b"] toGroup:kPNChannelGroupTestsName withAssertions:^(PNAcknowledgmentStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
    }];
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        NSArray *expectedChannelGroups = @[
                                           kPNChannelGroupTestsName,
                                           [kPNChannelGroupTestsName stringByAppendingString:@"-pnpres"]
                                           ];
        XCTAssertEqual(status.subscribedChannelGroups.count, expectedChannelGroups.count);
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannelGroups], [NSSet setWithArray:expectedChannelGroups]);
        
        NSArray *expectedPresenceSubscriptions = @[];
        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannels], [NSSet setWithArray:expectedPresenceSubscriptions]);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        if (self.invocation.selector == @selector(testSetClientStateOnSubscribedChannelGroup)) {
            XCTAssertEqualObjects(status.currentTimetoken, @14356954400894751);
        } else if (self.invocation.selector == @selector(testStateForUUIDOnSubscribedChannelGroup)) {
            XCTAssertEqualObjects(status.currentTimetoken, @14356954400894751);
        } else {
            XCTFail(@"not supposed to be handling this tests");
        }
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        [self.channelGroupSubscribeExpectation fulfill];
        
    };
    [self PNTest_subscribeToChannelGroups:[self channelGroups] withPresence:YES];
    self.didReceiveStatusAssertions = nil;
}

- (void)tearDown {
    [self performVerifiedRemoveAllChannelsFromGroup:kPNChannelGroupTestsName withAssertions:nil];
    [super tearDown];
}

- (void)testSetClientStateOnSubscribedChannelGroup {
    self.didReceiveStatusAssertions = nil;
    XCTestExpectation *stateExpectation = [self expectationWithDescription:@"clientState"];
    NSDictionary *state = @{
                            @"test" : @"test"
                            };
    PNWeakify(self);
    [self.client setState:state forUUID:self.client.uuid onChannelGroup:[self channelGroups].firstObject withCompletion:^(PNClientStateUpdateStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNSetStateOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
        NSDictionary *expectedState = @{
                                        @"test" : @"test"
                                        };
        XCTAssertEqualObjects(status.data.state, expectedState);
        [stateExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testSetClientStateOnNotExistingChannelGroup {
    self.didReceiveStatusAssertions = nil;
    XCTestExpectation *stateExpectation = [self expectationWithDescription:@"clientState"];
    NSDictionary *state = @{
                            @"test" : @"test"
                            };
    PNWeakify(self);
    [self.client setState:state forUUID:self.client.uuid onChannelGroup:[self nonExistentChannelGroup]
           withCompletion:^(PNClientStateUpdateStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertTrue(status.isError);
        XCTAssertEqual(status.operation, PNSetStateOperation);
        XCTAssertEqual(status.category, PNBadRequestCategory);
        XCTAssertEqual(status.statusCode, 400);
//        XCTAssertNil(status.data.state);
        // TOOD: there should be a property for this?
//        XCTAssertEqualObjects(status.data, @"No valid channels specified");
        NSLog(@"Information %@", status.errorData.information);
        [stateExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testStateForUUIDOnSubscribedChannelGroup {
    PNWeakify(self);
    XCTestExpectation *stateExpectation = [self expectationWithDescription:@"clientState"];
    NSDictionary *channels = @{
                            @"a" : @{
                                    @"test" : @"test"
                                    },
                            @"b" : @{
                                    @"test" : @"test"
                                    }
                            };
    [self.client stateForUUID:self.client.uuid onChannelGroup:[self channelGroups].firstObject withCompletion:^(PNChannelGroupClientStateResult *result, PNErrorStatus *status) {
        PNStrongify(self);
        XCTAssertNil(status);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.operation, PNStateForChannelGroupOperation);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqualObjects(result.data.channels, channels, @"result.data.channels: %@", result.data.channels);
        [stateExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testStateForUUIDOnNonExistentChannelGroup {
    PNWeakify(self);
    XCTestExpectation *stateExpectation = [self expectationWithDescription:@"clientState"];
    [self.client stateForUUID:self.client.uuid onChannelGroup:[self nonExistentChannelGroup] withCompletion:^(PNChannelGroupClientStateResult *result, PNErrorStatus *status) {
        PNStrongify(self);
        XCTAssertNil(result);
        XCTAssertNotNil(status);
        XCTAssertTrue(status.isError);
        XCTAssertEqual(status.category, PNBadRequestCategory);
        XCTAssertEqual(status.operation, PNStateForChannelGroupOperation);
        XCTAssertEqual(status.statusCode, 400);
        XCTAssertEqualObjects(status.errorData.information, @"No valid channels specified");
        [stateExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
