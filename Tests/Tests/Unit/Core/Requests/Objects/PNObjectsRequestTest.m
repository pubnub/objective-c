#import <XCTest/XCTest.h>
#import <PubNub/PNSetUUIDMetadataRequest.h>
#import <PubNub/PNFetchUUIDMetadataRequest.h>
#import <PubNub/PNRemoveUUIDMetadataRequest.h>
#import <PubNub/PNFetchAllUUIDMetadataRequest.h>
#import <PubNub/PNSetChannelMetadataRequest.h>
#import <PubNub/PNFetchChannelMetadataRequest.h>
#import <PubNub/PNRemoveChannelMetadataRequest.h>
#import <PubNub/PNFetchAllChannelsMetadataRequest.h>
#import <PubNub/PNStructures.h>
#import "PNBaseRequest+Private.h"


#pragma mark Interface declaration

@interface PNObjectsRequestTest : XCTestCase

@end


#pragma mark - Tests

@implementation PNObjectsRequestTest


#pragma mark - PNSetUUIDMetadataRequest :: Construction

- (void)testItShouldCreateSetUUIDMetadataRequestWhenUUIDProvided {
    PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:@"uuid-123"];

    XCTAssertNotNil(request);
}

- (void)testItShouldCreateSetUUIDMetadataRequestWhenNilUUIDProvided {
    PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:nil];

    XCTAssertNotNil(request, @"Should create request with nil UUID (will use config UUID)");
}

- (void)testItShouldIncludeDefaultFieldsInSetUUIDQuery {
    PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:@"uuid"];

    NSString *include = request.query[@"include"];

    XCTAssertTrue([include containsString:@"custom"]);
    XCTAssertTrue([include containsString:@"status"]);
    XCTAssertTrue([include containsString:@"type"]);
}


#pragma mark - PNSetUUIDMetadataRequest :: Body

- (void)testItShouldIncludeAllPropertiesInBodyWhenValidated {
    PNSetUUIDMetadataRequest *request = [PNSetUUIDMetadataRequest requestWithUUID:@"uuid-123"];
    request.name = @"John Doe";
    request.email = @"john@example.com";
    request.externalId = @"ext-456";
    request.profileUrl = @"https://example.com/profile";
    request.custom = @{ @"key": @"value" };
    request.status = @"active";
    request.type = @"admin";

    PNError *error = [request validate];

    XCTAssertNil(error);
    XCTAssertNotNil(request.body);

    NSDictionary *body = [NSJSONSerialization JSONObjectWithData:request.body options:0 error:nil];
    XCTAssertEqualObjects(body[@"name"], @"John Doe");
    XCTAssertEqualObjects(body[@"email"], @"john@example.com");
    XCTAssertEqualObjects(body[@"externalId"], @"ext-456");
    XCTAssertEqualObjects(body[@"profileUrl"], @"https://example.com/profile");
    XCTAssertEqualObjects(body[@"custom"][@"key"], @"value");
    XCTAssertEqualObjects(body[@"status"], @"active");
    XCTAssertEqualObjects(body[@"type"], @"admin");
}


#pragma mark - PNFetchUUIDMetadataRequest :: Construction

- (void)testItShouldCreateFetchUUIDMetadataRequestWhenUUIDProvided {
    PNFetchUUIDMetadataRequest *request = [PNFetchUUIDMetadataRequest requestWithUUID:@"uuid-123"];

    XCTAssertNotNil(request);
}

- (void)testItShouldCreateFetchUUIDMetadataRequestWhenNilUUID {
    PNFetchUUIDMetadataRequest *request = [PNFetchUUIDMetadataRequest requestWithUUID:nil];

    XCTAssertNotNil(request, @"Should create request with nil UUID (will use config UUID)");
}

- (void)testItShouldIncludeFieldsInFetchUUIDQuery {
    PNFetchUUIDMetadataRequest *request = [PNFetchUUIDMetadataRequest requestWithUUID:@"uuid"];
    request.includeFields = PNUUIDCustomField;

    NSString *include = request.query[@"include"];

    XCTAssertTrue([include containsString:@"custom"]);
}


#pragma mark - PNRemoveUUIDMetadataRequest :: Construction

- (void)testItShouldCreateRemoveUUIDMetadataRequestWhenUUIDProvided {
    PNRemoveUUIDMetadataRequest *request = [PNRemoveUUIDMetadataRequest requestWithUUID:@"uuid-123"];

    XCTAssertNotNil(request);
}

- (void)testItShouldCreateRemoveUUIDMetadataRequestWhenNilUUID {
    PNRemoveUUIDMetadataRequest *request = [PNRemoveUUIDMetadataRequest requestWithUUID:nil];

    XCTAssertNotNil(request, @"Should create request with nil UUID (will use config UUID)");
}


#pragma mark - PNFetchAllUUIDMetadataRequest :: Construction

- (void)testItShouldCreateFetchAllUUIDMetadataRequest {
    PNFetchAllUUIDMetadataRequest *request = [PNFetchAllUUIDMetadataRequest new];

    XCTAssertNotNil(request);
}


#pragma mark - PNFetchAllUUIDMetadataRequest :: Query parameters

- (void)testItShouldIncludePaginationParametersInFetchAllUUIDQuery {
    PNFetchAllUUIDMetadataRequest *request = [PNFetchAllUUIDMetadataRequest new];
    request.limit = 50;
    request.start = @"cursor-abc";
    request.end = @"cursor-xyz";
    request.filter = @"name == 'John'";
    request.sort = @[@"name:asc", @"updated:desc"];

    NSDictionary *query = request.query;

    XCTAssertEqualObjects(query[@"limit"], @(50).stringValue);
    XCTAssertEqualObjects(query[@"start"], @"cursor-abc");
    XCTAssertEqualObjects(query[@"end"], @"cursor-xyz");
    XCTAssertEqualObjects(query[@"filter"], @"name == 'John'");
    XCTAssertNotNil(query[@"sort"]);
    XCTAssertTrue([query[@"sort"] containsString:@"name:asc"]);
}

- (void)testItShouldIncludeFieldsAndCountInFetchAllUUIDQuery {
    PNFetchAllUUIDMetadataRequest *request = [PNFetchAllUUIDMetadataRequest new];
    request.includeFields = PNUUIDCustomField | PNUUIDTotalCountField;

    NSDictionary *query = request.query;

    XCTAssertTrue([query[@"include"] containsString:@"custom"]);
    XCTAssertEqualObjects(query[@"count"], @"1");
}


#pragma mark - PNSetChannelMetadataRequest :: Construction

- (void)testItShouldCreateSetChannelMetadataRequestWhenChannelProvided {
    PNSetChannelMetadataRequest *request = [PNSetChannelMetadataRequest requestWithChannel:@"my-channel"];

    XCTAssertNotNil(request);
}

- (void)testItShouldIncludeDefaultFieldsInSetChannelQuery {
    PNSetChannelMetadataRequest *request = [PNSetChannelMetadataRequest requestWithChannel:@"ch"];

    NSString *include = request.query[@"include"];

    XCTAssertTrue([include containsString:@"custom"]);
    XCTAssertTrue([include containsString:@"status"]);
    XCTAssertTrue([include containsString:@"type"]);
}


#pragma mark - PNSetChannelMetadataRequest :: Body

- (void)testItShouldIncludeAllChannelMetadataPropertiesInBodyWhenValidated {
    PNSetChannelMetadataRequest *request = [PNSetChannelMetadataRequest requestWithChannel:@"ch"];
    request.name = @"General Chat";
    request.information = @"A channel for general discussion";
    request.custom = @{ @"theme": @"dark" };
    request.status = @"active";
    request.type = @"group";

    PNError *error = [request validate];

    XCTAssertNil(error);
    XCTAssertNotNil(request.body);

    NSDictionary *body = [NSJSONSerialization JSONObjectWithData:request.body options:0 error:nil];
    XCTAssertEqualObjects(body[@"name"], @"General Chat");
    XCTAssertEqualObjects(body[@"description"], @"A channel for general discussion");
    XCTAssertEqualObjects(body[@"custom"][@"theme"], @"dark");
    XCTAssertEqualObjects(body[@"status"], @"active");
    XCTAssertEqualObjects(body[@"type"], @"group");
}


#pragma mark - PNFetchChannelMetadataRequest :: Construction

- (void)testItShouldCreateFetchChannelMetadataRequestWhenChannelProvided {
    PNFetchChannelMetadataRequest *request = [PNFetchChannelMetadataRequest requestWithChannel:@"ch"];

    XCTAssertNotNil(request);
}

- (void)testItShouldIncludeFieldsInFetchChannelQuery {
    PNFetchChannelMetadataRequest *request = [PNFetchChannelMetadataRequest requestWithChannel:@"ch"];
    request.includeFields = PNChannelCustomField;

    XCTAssertTrue([request.query[@"include"] containsString:@"custom"]);
}


#pragma mark - PNRemoveChannelMetadataRequest :: Construction

- (void)testItShouldCreateRemoveChannelMetadataRequestWhenChannelProvided {
    PNRemoveChannelMetadataRequest *request = [PNRemoveChannelMetadataRequest requestWithChannel:@"ch"];

    XCTAssertNotNil(request);
}


#pragma mark - PNFetchAllChannelsMetadataRequest :: Construction

- (void)testItShouldCreateFetchAllChannelsMetadataRequest {
    PNFetchAllChannelsMetadataRequest *request = [PNFetchAllChannelsMetadataRequest new];

    XCTAssertNotNil(request);
}


#pragma mark - PNFetchAllChannelsMetadataRequest :: Query parameters

- (void)testItShouldIncludePaginationParametersInFetchAllChannelsQuery {
    PNFetchAllChannelsMetadataRequest *request = [PNFetchAllChannelsMetadataRequest new];
    request.limit = 25;
    request.start = @"cursor-start";
    request.filter = @"name LIKE 'gen*'";
    request.sort = @[@"name:desc"];

    NSDictionary *query = request.query;

    XCTAssertEqualObjects(query[@"limit"], @(25).stringValue);
    XCTAssertEqualObjects(query[@"start"], @"cursor-start");
    XCTAssertEqualObjects(query[@"filter"], @"name LIKE 'gen*'");
    XCTAssertTrue([query[@"sort"] containsString:@"name:desc"]);
}

- (void)testItShouldIncludeFieldsAndCountInFetchAllChannelsQuery {
    PNFetchAllChannelsMetadataRequest *request = [PNFetchAllChannelsMetadataRequest new];
    request.includeFields = PNChannelCustomField | PNChannelTotalCountField;

    NSDictionary *query = request.query;

    XCTAssertTrue([query[@"include"] containsString:@"custom"]);
    XCTAssertEqualObjects(query[@"count"], @"1");
}


#pragma mark -

@end
