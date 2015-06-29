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

- (void)setUp {
    [super setUp];
    [self performVerifiedRemoveAllChannelsFromGroup:kPNChannelGroupTestsName withAssertions:nil];
    PNWeakify(self);
    [self performVerifiedAddChannels:@[@"a", @"b"] toGroup:kPNChannelGroupTestsName withAssertions:^(PNAcknowledgmentStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
    }];
    if (self.invocation.selector != @selector(testSetClientStateOnSubscribedChannelGroup)) {
        return;
    }
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
//        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
//        NSArray *expectedPresenceSubscriptions = @[@"a"];
//        XCTAssertEqualObjects([NSSet setWithArray:status.subscribedChannels], [NSSet setWithArray:expectedPresenceSubscriptions]);
        XCTAssertEqual(status.operation, PNSubscribeOperation);
        NSLog(@"timeToken: %@", status.currentTimetoken);
        if (self.invocation.selector == @selector(testSetClientStateOnSubscribedChannelGroup)) {
            XCTAssertEqualObjects(status.currentTimetoken, @14355768305464885);
        } else if (self.invocation.selector == @selector(testSetClientStateOnNotExistingChannelGroup)) {
            XCTAssertEqualObjects(status.currentTimetoken, @14355750743453296);
        }
        XCTAssertEqualObjects(status.currentTimetoken, status.data.timetoken);
        [self.channelGroupSubscribeExpectation fulfill];
        
    };
    [self PNTest_subscribeToChannelGroups:[self channelGroups] withPresence:YES];
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
        XCTAssertEqualObjects(status.data.state, state);
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
    [self.client setState:state forUUID:self.client.uuid onChannelGroup:@"42"
           withCompletion:^(PNClientStateUpdateStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertTrue(status.isError);
        XCTAssertEqual(status.operation, PNSetStateOperation);
        XCTAssertEqual(status.category, PNBadRequestCategory);
        XCTAssertEqual(status.statusCode, 400);
        XCTAssertNil(status.data.state);
        // TOOD: there should be a property for this?
//        XCTAssertEqualObjects(status.data, @"No valid channels specified");
        NSLog(@"Information %@", status.errorData.information);
        [stateExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
