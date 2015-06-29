//
//  PNChannelGroupTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"
typedef void (^PNChannelGroupAssertions)(PNAcknowledgmentStatus *status);

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
        XCTAssertNil(status);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqual(result.operation, PNChannelsForGroupOperation);
        XCTAssertEqualObjects(result.data.channels, channelGroups);
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
    [self.client channelGroupsWithCompletion:^(PNChannelGroupsResult *result, PNErrorStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(result);
        XCTAssertNil(status);
        XCTAssertEqual(result.operation, PNChannelGroupsOperation);
        XCTAssertEqual(result.statusCode, 200);
        // TODO: assert on actual groups, for now just do count
        XCTAssertEqual(result.data.groups.count, 64);
        [getAllChannelGroups fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

#pragma mark - Helpers

- (void)performVerifiedAddChannels:(NSArray *)channels toGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions {
    XCTestExpectation *addChannelsToGroupExpectation = [self expectationWithDescription:@"addChannels"];
    [self.client addChannels:channels toGroup:channelGroup
              withCompletion:^(PNAcknowledgmentStatus *status) {
                  if (assertions) {
                      assertions(status);
                  }
                  [addChannelsToGroupExpectation fulfill];
              }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)performVerifiedRemoveAllChannelsFromGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions {
    XCTestExpectation *removeChannels = [self expectationWithDescription:@"removeChannels"];
    [self.client removeChannelsFromGroup:channelGroup withCompletion:^(PNAcknowledgmentStatus *status) {
        if (assertions) {
            assertions(status);
        }
        [removeChannels fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)performVerifiedRemoveChannels:(NSArray *)channels fromGroup:(NSString *)channelGroup withAssertions:(PNChannelGroupAssertions)assertions {
    XCTestExpectation *removeSpecificChannels = [self expectationWithDescription:@"removeSpecificChannels"];
    [self.client removeChannels:channels fromGroup:channelGroup withCompletion:^(PNAcknowledgmentStatus *status) {
        if (assertions) {
            assertions(status);
        }
        [removeSpecificChannels fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
