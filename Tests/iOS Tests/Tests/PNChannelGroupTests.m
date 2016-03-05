//
//  PNChannelGroupTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

static NSString * const kPNChannelGroupTestsName = @"PNChannelGroupTestsName";

@interface PNChannelGroupTests : PNBasicClientTestCase
@end

@implementation PNChannelGroupTests

- (BOOL)isRecording{
    return NO;
}

- (void)setUp {
    [super setUp];
    [self performVerifiedRemoveAllChannelsFromGroup:kPNChannelGroupTestsName withAssertions:nil];
}

- (void)tearDown {
    [self performVerifiedRemoveAllChannelsFromGroup:kPNChannelGroupTestsName withAssertions:nil];
    [super tearDown];
}

- (void)testChannelGroupAdd {
    PNWeakify(self);
    [self performVerifiedAddChannels:@[@"a", @"c"] toGroup:kPNChannelGroupTestsName withAssertions:^(PNAcknowledgmentStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
    }];
}

- (void)testChannelsForGroup {
    PNWeakify(self);
    NSArray *channelGroups = @[@"a", @"c"];
    [self performVerifiedAddChannels:channelGroups toGroup:kPNChannelGroupTestsName withAssertions:^(PNAcknowledgmentStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
    }];
    
    XCTestExpectation *channelsForGroup = [self expectationWithDescription:@"channelsForGroup"];
    [self.client channelsForGroup:kPNChannelGroupTestsName withCompletion:^(PNChannelGroupChannelsResult *result, PNErrorStatus *status) {
        PNStrongify(self);
        XCTAssertNil(status.errorData.information);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqual(result.operation, PNChannelsForGroupOperation);
        XCTAssertEqualObjects([NSSet setWithArray:result.data.channels],
                              [NSSet setWithArray:channelGroups]);
        [channelsForGroup fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)testChannelGroupRemoveAll {
    PNWeakify(self);
    [self performVerifiedAddChannels:@[@"a", @"c"] toGroup:kPNChannelGroupTestsName withAssertions:^(PNAcknowledgmentStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
    }];
    
    [self performVerifiedRemoveAllChannelsFromGroup:kPNChannelGroupTestsName withAssertions:^(PNAcknowledgmentStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNRemoveGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
        
    }];
    
}

- (void)testRemoveSpecificChannelsFromGroup {
    PNWeakify(self);
    [self performVerifiedAddChannels:@[@"a", @"c"] toGroup:kPNChannelGroupTestsName withAssertions:^(PNAcknowledgmentStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
    }];
    [self performVerifiedRemoveChannels:@[@"a"] fromGroup:kPNChannelGroupTestsName withAssertions:^(PNAcknowledgmentStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNRemoveChannelsFromGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
    }];
}

- (void)testGetAllChannelGroupsForClient {
    PNWeakify(self);
    XCTestExpectation *getAllChannelGroups = [self expectationWithDescription:@"getAllChannelGroups"];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated"
    [self.client channelGroupsWithCompletion:^(PNChannelGroupsResult *result, PNErrorStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(result);
        XCTAssertNil(status.errorData.information);
        XCTAssertEqual(result.operation, PNChannelGroupsOperation);
        XCTAssertEqual(result.statusCode, 200);
        // TODO: assert on actual groups, for now just do count
        XCTAssertEqual(result.data.groups.count, 64);
        [getAllChannelGroups fulfill];
    }];
    #pragma clang diagnostic pop
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
