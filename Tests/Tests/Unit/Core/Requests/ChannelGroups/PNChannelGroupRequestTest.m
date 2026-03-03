#import <XCTest/XCTest.h>
#import <PubNub/PNChannelGroupFetchRequest.h>
#import <PubNub/PNChannelGroupManageRequest.h>
#import "PNBaseRequest+Private.h"


#pragma mark Interface declaration

@interface PNChannelGroupRequestTest : XCTestCase

@end


#pragma mark - Tests

@implementation PNChannelGroupRequestTest


#pragma mark - PNChannelGroupFetchRequest :: List all channel groups

- (void)testItShouldCreateListAllChannelGroupsRequest {
    PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestChannelGroups];

    XCTAssertNotNil(request);
}

- (void)testItShouldHaveNilChannelGroupWhenListingAllGroups {
    PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestChannelGroups];

    XCTAssertNil(request.channelGroup, @"channelGroup should be nil for list all groups request");
}

- (void)testItShouldPassValidationWhenListingAllGroups {
    PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestChannelGroups];

    XCTAssertNil([request validate], @"List all groups should pass validation without channelGroup");
}


#pragma mark - PNChannelGroupFetchRequest :: List channel group channels

- (void)testItShouldCreateFetchRequestWhenChannelGroupProvided {
    PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestWithChannelGroup:@"my-group"];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channelGroup, @"my-group");
}

- (void)testItShouldHaveNilQueryWhenFetchRequestCreated {
    PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestWithChannelGroup:@"grp"];

    XCTAssertNil(request.query);
}

- (void)testItShouldIncludeArbitraryParametersInFetchQuery {
    PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestWithChannelGroup:@"grp"];
    request.arbitraryQueryParameters = @{ @"key": @"value" };

    XCTAssertEqualObjects(request.query[@"key"], @"value");
}

- (void)testItShouldRetainChannelGroupNameWhenCreated {
    PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestWithChannelGroup:@"my-special-group"];

    XCTAssertEqualObjects(request.channelGroup, @"my-special-group");
}

- (void)testItShouldHandleSpecialCharactersInChannelGroupNameWhenCreated {
    PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestWithChannelGroup:@"group_with-special.chars"];

    XCTAssertEqualObjects(request.channelGroup, @"group_with-special.chars");
}


#pragma mark - PNChannelGroupFetchRequest :: Validation

- (void)testItShouldPassValidationWhenChannelGroupProvided {
    PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestWithChannelGroup:@"grp"];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenChannelGroupIsEmpty {
    PNChannelGroupFetchRequest *request = [PNChannelGroupFetchRequest requestWithChannelGroup:@""];

    XCTAssertNotNil([request validate], @"Validation should fail with empty channel group");
}


#pragma mark - PNChannelGroupManageRequest :: Add channels

- (void)testItShouldCreateAddChannelsRequestWhenChannelsAndGroupProvided {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToAddChannels:@[@"ch1", @"ch2"]
                                                                             toChannelGroup:@"my-group"];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channelGroup, @"my-group");
}

- (void)testItShouldIncludeChannelsInAddQuery {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToAddChannels:@[@"ch1", @"ch2"]
                                                                             toChannelGroup:@"grp"];

    NSDictionary *query = request.query;

    XCTAssertNotNil(query[@"add"]);
    XCTAssertTrue([query[@"add"] containsString:@"ch1"]);
    XCTAssertTrue([query[@"add"] containsString:@"ch2"]);
}

- (void)testItShouldIncludeArbitraryParametersInAddChannelsQuery {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToAddChannels:@[@"ch"]
                                                                             toChannelGroup:@"grp"];
    request.arbitraryQueryParameters = @{ @"custom": @"param" };

    XCTAssertEqualObjects(request.query[@"custom"], @"param");
}


#pragma mark - PNChannelGroupManageRequest :: Remove channels

- (void)testItShouldCreateRemoveChannelsRequestWhenChannelsAndGroupProvided {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToRemoveChannels:@[@"ch1"]
                                                                              fromChannelGroup:@"my-group"];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channelGroup, @"my-group");
}

- (void)testItShouldIncludeChannelsInRemoveQuery {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToRemoveChannels:@[@"ch1"]
                                                                              fromChannelGroup:@"my-group"];

    XCTAssertEqualObjects(request.query[@"remove"], @"ch1");
}


#pragma mark - PNChannelGroupManageRequest :: Remove channel group

- (void)testItShouldCreateRemoveChannelGroupRequestWhenGroupProvided {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToRemoveChannelGroup:@"my-group"];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channelGroup, @"my-group");
    XCTAssertNil(request.channels, @"channels should be nil for remove group request");
}


#pragma mark - PNChannelGroupManageRequest :: Validation

- (void)testItShouldPassValidationWhenAddChannelsToGroupProvided {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToAddChannels:@[@"ch"]
                                                                             toChannelGroup:@"grp"];

    XCTAssertNil([request validate]);
}

- (void)testItShouldPassValidationWhenRemoveChannelsFromGroupProvided {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToRemoveChannels:@[@"ch"]
                                                                              fromChannelGroup:@"grp"];

    XCTAssertNil([request validate]);
}

- (void)testItShouldPassValidationWhenRemoveGroupProvided {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToRemoveChannelGroup:@"grp"];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenAddChannelsGroupNameIsEmpty {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToAddChannels:@[@"ch"]
                                                                             toChannelGroup:@""];

    XCTAssertNotNil([request validate], @"Validation should fail with empty channel group name");
}

- (void)testItShouldFailValidationWhenRemoveChannelsGroupNameIsEmpty {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToRemoveChannels:@[@"ch"]
                                                                              fromChannelGroup:@""];

    XCTAssertNotNil([request validate], @"Validation should fail with empty channel group name");
}

- (void)testItShouldFailValidationWhenRemoveGroupNameIsEmpty {
    PNChannelGroupManageRequest *request = [PNChannelGroupManageRequest requestToRemoveChannelGroup:@""];

    XCTAssertNotNil([request validate], @"Validation should fail with empty channel group name");
}


#pragma mark -

@end
