#import <XCTest/XCTest.h>
#import <PubNub/PNSetMembershipsRequest.h>
#import <PubNub/PNRemoveMembershipsRequest.h>
#import <PubNub/PNFetchMembershipsRequest.h>
#import <PubNub/PNManageMembershipsRequest.h>
#import <PubNub/PNSetChannelMembersRequest.h>
#import <PubNub/PNRemoveChannelMembersRequest.h>
#import <PubNub/PNFetchChannelMembersRequest.h>
#import <PubNub/PNManageChannelMembersRequest.h>
#import <PubNub/PNStructures.h>
#import "PNBaseRequest+Private.h"


#pragma mark Interface declaration

@interface PNRelationsRequestTest : XCTestCase

@end


#pragma mark - Tests

@implementation PNRelationsRequestTest


#pragma mark - PNSetMembershipsRequest :: Construction

- (void)testItShouldCreateSetMembershipsRequestWhenUUIDAndChannelsProvided {
    NSArray *channels = @[@{ @"channel": @"ch1" }, @{ @"channel": @"ch2" }];
    PNSetMembershipsRequest *request = [PNSetMembershipsRequest requestWithUUID:@"uuid-123" channels:channels];

    XCTAssertNotNil(request);
}

- (void)testItShouldCreateSetMembershipsRequestWhenNilUUIDProvided {
    NSArray *channels = @[@{ @"channel": @"ch1" }];
    PNSetMembershipsRequest *request = [PNSetMembershipsRequest requestWithUUID:nil channels:channels];

    XCTAssertNotNil(request, @"Should create request with nil UUID (will use config UUID)");
}

- (void)testItShouldIncludeDefaultFieldsInSetMembershipsQuery {
    NSArray *channels = @[@{ @"channel": @"ch1" }];
    PNSetMembershipsRequest *request = [PNSetMembershipsRequest requestWithUUID:@"uuid" channels:channels];

    NSDictionary *query = request.query;

    XCTAssertEqualObjects(query[@"count"], @"1");
    XCTAssertTrue([query[@"include"] containsString:@"status"]);
    XCTAssertTrue([query[@"include"] containsString:@"type"]);
}

- (void)testItShouldIncludeFieldsInSetMembershipsQuery {
    NSArray *channels = @[@{ @"channel": @"ch1" }];
    PNSetMembershipsRequest *request = [PNSetMembershipsRequest requestWithUUID:@"uuid" channels:channels];
    request.includeFields = PNMembershipCustomField | PNMembershipChannelField;

    NSDictionary *query = request.query;

    XCTAssertTrue([query[@"include"] containsString:@"custom"]);
    XCTAssertTrue([query[@"include"] containsString:@"channel"]);
}

- (void)testItShouldAcceptChannelsWithCustomDataWhenSetMembershipsCreated {
    NSArray *channels = @[@{ @"channel": @"ch1", @"custom": @{ @"role": @"admin" } }];
    PNSetMembershipsRequest *request = [PNSetMembershipsRequest requestWithUUID:@"uuid" channels:channels];

    XCTAssertNotNil(request);
}


#pragma mark - PNRemoveMembershipsRequest :: Construction

- (void)testItShouldCreateRemoveMembershipsRequestWhenUUIDAndChannelsProvided {
    NSArray *channels = @[@"ch1", @"ch2"];
    PNRemoveMembershipsRequest *request = [PNRemoveMembershipsRequest requestWithUUID:@"uuid-123" channels:channels];

    XCTAssertNotNil(request);
}

- (void)testItShouldCreateRemoveMembershipsRequestWhenNilUUIDProvided {
    PNRemoveMembershipsRequest *request = [PNRemoveMembershipsRequest requestWithUUID:nil channels:@[@"ch1"]];

    XCTAssertNotNil(request, @"Should create request with nil UUID (will use config UUID)");
}

- (void)testItShouldIncludeDefaultFieldsInRemoveMembershipsQuery {
    PNRemoveMembershipsRequest *request = [PNRemoveMembershipsRequest requestWithUUID:@"uuid" channels:@[@"ch1"]];

    NSDictionary *query = request.query;

    XCTAssertEqualObjects(query[@"count"], @"1");
    XCTAssertTrue([query[@"include"] containsString:@"status"]);
    XCTAssertTrue([query[@"include"] containsString:@"type"]);
}

- (void)testItShouldIncludeFieldsInRemoveMembershipsQuery {
    PNRemoveMembershipsRequest *request = [PNRemoveMembershipsRequest requestWithUUID:@"uuid" channels:@[@"ch1"]];
    request.includeFields = PNMembershipCustomField;

    XCTAssertTrue([request.query[@"include"] containsString:@"custom"]);
}


#pragma mark - PNFetchMembershipsRequest :: Construction

- (void)testItShouldCreateFetchMembershipsRequestWhenUUIDProvided {
    PNFetchMembershipsRequest *request = [PNFetchMembershipsRequest requestWithUUID:@"uuid-123"];

    XCTAssertNotNil(request);
}

- (void)testItShouldCreateFetchMembershipsRequestWhenNilUUIDProvided {
    PNFetchMembershipsRequest *request = [PNFetchMembershipsRequest requestWithUUID:nil];

    XCTAssertNotNil(request, @"Should create request with nil UUID (will use config UUID)");
}

- (void)testItShouldIncludeDefaultFieldsInFetchMembershipsQuery {
    PNFetchMembershipsRequest *request = [PNFetchMembershipsRequest requestWithUUID:@"uuid"];

    NSDictionary *query = request.query;

    XCTAssertEqualObjects(query[@"count"], @"1");
    XCTAssertTrue([query[@"include"] containsString:@"status"]);
    XCTAssertTrue([query[@"include"] containsString:@"type"]);
}

- (void)testItShouldIncludePaginationParametersInFetchMembershipsQuery {
    PNFetchMembershipsRequest *request = [PNFetchMembershipsRequest requestWithUUID:@"uuid"];
    request.limit = 50;
    request.start = @"cursor-abc";
    request.end = @"cursor-xyz";
    request.filter = @"channel.name == 'General'";
    request.sort = @[@"channel.name:asc"];

    NSDictionary *query = request.query;

    XCTAssertEqualObjects(query[@"limit"], @(50).stringValue);
    XCTAssertEqualObjects(query[@"start"], @"cursor-abc");
    XCTAssertEqualObjects(query[@"end"], @"cursor-xyz");
    XCTAssertEqualObjects(query[@"filter"], @"channel.name == 'General'");
    XCTAssertTrue([query[@"sort"] containsString:@"channel.name:asc"]);
}

- (void)testItShouldIncludeFieldsInFetchMembershipsQuery {
    PNFetchMembershipsRequest *request = [PNFetchMembershipsRequest requestWithUUID:@"uuid"];
    request.includeFields = PNMembershipCustomField | PNMembershipChannelField | PNMembershipChannelCustomField;

    NSString *include = request.query[@"include"];

    XCTAssertTrue([include containsString:@"custom"]);
    XCTAssertTrue([include containsString:@"channel"]);
    XCTAssertTrue([include containsString:@"channel.custom"]);
}


#pragma mark - PNManageMembershipsRequest :: Construction

- (void)testItShouldCreateManageMembershipsRequestWhenUUIDProvided {
    PNManageMembershipsRequest *request = [PNManageMembershipsRequest requestWithUUID:@"uuid-123"];

    XCTAssertNotNil(request);
}

- (void)testItShouldCreateManageMembershipsRequestWhenNilUUIDProvided {
    PNManageMembershipsRequest *request = [PNManageMembershipsRequest requestWithUUID:nil];

    XCTAssertNotNil(request, @"Should create request with nil UUID (will use config UUID)");
}

- (void)testItShouldIncludeDefaultFieldsInManageMembershipsQuery {
    PNManageMembershipsRequest *request = [PNManageMembershipsRequest requestWithUUID:@"uuid"];

    NSDictionary *query = request.query;

    XCTAssertEqualObjects(query[@"count"], @"1");
    XCTAssertTrue([query[@"include"] containsString:@"status"]);
    XCTAssertTrue([query[@"include"] containsString:@"type"]);
}

- (void)testItShouldSetSetChannelsWhenManageMembershipsConfigured {
    PNManageMembershipsRequest *request = [PNManageMembershipsRequest requestWithUUID:@"uuid"];
    request.setChannels = @[@{ @"channel": @"ch1", @"custom": @{ @"role": @"member" } }];

    XCTAssertNotNil(request.setChannels);
    XCTAssertEqual(request.setChannels.count, 1);
}

- (void)testItShouldSetRemoveChannelsWhenManageMembershipsConfigured {
    PNManageMembershipsRequest *request = [PNManageMembershipsRequest requestWithUUID:@"uuid"];
    request.removeChannels = @[@"ch-old-1", @"ch-old-2"];

    XCTAssertNotNil(request.removeChannels);
    XCTAssertEqual(request.removeChannels.count, 2);
}

- (void)testItShouldSetBothSetAndRemoveChannelsWhenManageMembershipsConfigured {
    PNManageMembershipsRequest *request = [PNManageMembershipsRequest requestWithUUID:@"uuid"];
    request.setChannels = @[@{ @"channel": @"ch-new" }];
    request.removeChannels = @[@"ch-old"];

    XCTAssertNotNil(request.setChannels);
    XCTAssertNotNil(request.removeChannels);
}


#pragma mark - PNSetChannelMembersRequest :: Construction

- (void)testItShouldCreateSetChannelMembersRequestWhenChannelAndUUIDsProvided {
    NSArray *uuids = @[@{ @"uuid": @"uuid-1" }, @{ @"uuid": @"uuid-2" }];
    PNSetChannelMembersRequest *request = [PNSetChannelMembersRequest requestWithChannel:@"my-channel" uuids:uuids];

    XCTAssertNotNil(request);
}

- (void)testItShouldIncludeDefaultFieldsInSetChannelMembersQuery {
    NSArray *uuids = @[@{ @"uuid": @"uuid-1" }];
    PNSetChannelMembersRequest *request = [PNSetChannelMembersRequest requestWithChannel:@"ch" uuids:uuids];

    NSDictionary *query = request.query;

    XCTAssertEqualObjects(query[@"count"], @"1");
    XCTAssertTrue([query[@"include"] containsString:@"status"]);
    XCTAssertTrue([query[@"include"] containsString:@"type"]);
}

- (void)testItShouldIncludeFieldsInSetChannelMembersQuery {
    NSArray *uuids = @[@{ @"uuid": @"uuid-1" }];
    PNSetChannelMembersRequest *request = [PNSetChannelMembersRequest requestWithChannel:@"ch" uuids:uuids];
    request.includeFields = PNChannelMemberCustomField | PNChannelMemberUUIDField;

    NSString *include = request.query[@"include"];

    XCTAssertTrue([include containsString:@"custom"]);
    XCTAssertTrue([include containsString:@"uuid"]);
}

- (void)testItShouldAcceptUUIDsWithCustomDataWhenSetChannelMembersCreated {
    NSArray *uuids = @[@{ @"uuid": @"uuid-1", @"custom": @{ @"role": @"moderator" } }];
    PNSetChannelMembersRequest *request = [PNSetChannelMembersRequest requestWithChannel:@"ch" uuids:uuids];

    XCTAssertNotNil(request);
}


#pragma mark - PNRemoveChannelMembersRequest :: Construction

- (void)testItShouldCreateRemoveChannelMembersRequestWhenChannelAndUUIDsProvided {
    NSArray *uuids = @[@"uuid-1", @"uuid-2"];
    PNRemoveChannelMembersRequest *request = [PNRemoveChannelMembersRequest requestWithChannel:@"my-channel"
                                                                                         uuids:uuids];

    XCTAssertNotNil(request);
}

- (void)testItShouldIncludeDefaultFieldsInRemoveChannelMembersQuery {
    PNRemoveChannelMembersRequest *request = [PNRemoveChannelMembersRequest requestWithChannel:@"ch"
                                                                                         uuids:@[@"uuid-1"]];

    NSDictionary *query = request.query;

    XCTAssertEqualObjects(query[@"count"], @"1");
    XCTAssertTrue([query[@"include"] containsString:@"status"]);
    XCTAssertTrue([query[@"include"] containsString:@"type"]);
}

- (void)testItShouldIncludeFieldsInRemoveChannelMembersQuery {
    PNRemoveChannelMembersRequest *request = [PNRemoveChannelMembersRequest requestWithChannel:@"ch"
                                                                                         uuids:@[@"uuid-1"]];
    request.includeFields = PNChannelMemberCustomField;

    XCTAssertTrue([request.query[@"include"] containsString:@"custom"]);
}


#pragma mark - PNFetchChannelMembersRequest :: Construction

- (void)testItShouldCreateFetchChannelMembersRequestWhenChannelProvided {
    PNFetchChannelMembersRequest *request = [PNFetchChannelMembersRequest requestWithChannel:@"my-channel"];

    XCTAssertNotNil(request);
}

- (void)testItShouldIncludeDefaultFieldsInFetchChannelMembersQuery {
    PNFetchChannelMembersRequest *request = [PNFetchChannelMembersRequest requestWithChannel:@"ch"];

    NSDictionary *query = request.query;

    XCTAssertEqualObjects(query[@"count"], @"1");
    XCTAssertTrue([query[@"include"] containsString:@"status"]);
    XCTAssertTrue([query[@"include"] containsString:@"type"]);
}

- (void)testItShouldIncludePaginationParametersInFetchChannelMembersQuery {
    PNFetchChannelMembersRequest *request = [PNFetchChannelMembersRequest requestWithChannel:@"ch"];
    request.limit = 25;
    request.start = @"cursor-start";
    request.end = @"cursor-end";
    request.filter = @"uuid.name LIKE 'John*'";
    request.sort = @[@"uuid.name:asc", @"updated:desc"];

    NSDictionary *query = request.query;

    XCTAssertEqualObjects(query[@"limit"], @(25).stringValue);
    XCTAssertEqualObjects(query[@"start"], @"cursor-start");
    XCTAssertEqualObjects(query[@"end"], @"cursor-end");
    XCTAssertEqualObjects(query[@"filter"], @"uuid.name LIKE 'John*'");
    XCTAssertTrue([query[@"sort"] containsString:@"uuid.name:asc"]);
}

- (void)testItShouldIncludeFieldsInFetchChannelMembersQuery {
    PNFetchChannelMembersRequest *request = [PNFetchChannelMembersRequest requestWithChannel:@"ch"];
    request.includeFields = PNChannelMemberCustomField | PNChannelMemberUUIDField | PNChannelMemberUUIDCustomField;

    NSString *include = request.query[@"include"];

    XCTAssertTrue([include containsString:@"custom"]);
    XCTAssertTrue([include containsString:@"uuid"]);
    XCTAssertTrue([include containsString:@"uuid.custom"]);
}


#pragma mark - PNManageChannelMembersRequest :: Construction

- (void)testItShouldCreateManageChannelMembersRequestWhenChannelProvided {
    PNManageChannelMembersRequest *request = [PNManageChannelMembersRequest requestWithChannel:@"my-channel"];

    XCTAssertNotNil(request);
}

- (void)testItShouldIncludeDefaultFieldsInManageChannelMembersQuery {
    PNManageChannelMembersRequest *request = [PNManageChannelMembersRequest requestWithChannel:@"ch"];

    NSDictionary *query = request.query;

    XCTAssertEqualObjects(query[@"count"], @"1");
    XCTAssertTrue([query[@"include"] containsString:@"status"]);
    XCTAssertTrue([query[@"include"] containsString:@"type"]);
}

- (void)testItShouldSetSetMembersWhenManageChannelMembersConfigured {
    PNManageChannelMembersRequest *request = [PNManageChannelMembersRequest requestWithChannel:@"ch"];
    request.setMembers = @[@{ @"uuid": @"uuid-1", @"custom": @{ @"role": @"admin" } }];

    XCTAssertNotNil(request.setMembers);
    XCTAssertEqual(request.setMembers.count, 1);
}

- (void)testItShouldSetRemoveMembersWhenManageChannelMembersConfigured {
    PNManageChannelMembersRequest *request = [PNManageChannelMembersRequest requestWithChannel:@"ch"];
    request.removeMembers = @[@"uuid-old-1", @"uuid-old-2"];

    XCTAssertNotNil(request.removeMembers);
    XCTAssertEqual(request.removeMembers.count, 2);
}

- (void)testItShouldSetBothSetAndRemoveMembersWhenManageChannelMembersConfigured {
    PNManageChannelMembersRequest *request = [PNManageChannelMembersRequest requestWithChannel:@"ch"];
    request.setMembers = @[@{ @"uuid": @"uuid-new" }];
    request.removeMembers = @[@"uuid-old"];

    XCTAssertNotNil(request.setMembers);
    XCTAssertNotNil(request.removeMembers);
}

- (void)testItShouldIncludePaginationParametersInManageChannelMembersQuery {
    PNManageChannelMembersRequest *request = [PNManageChannelMembersRequest requestWithChannel:@"ch"];
    request.limit = 10;
    request.start = @"page-start";
    request.filter = @"uuid.name == 'test'";
    request.sort = @[@"updated:desc"];

    NSDictionary *query = request.query;

    XCTAssertEqualObjects(query[@"limit"], @(10).stringValue);
    XCTAssertEqualObjects(query[@"start"], @"page-start");
    XCTAssertEqualObjects(query[@"filter"], @"uuid.name == 'test'");
    XCTAssertTrue([query[@"sort"] containsString:@"updated:desc"]);
}


#pragma mark -

@end
