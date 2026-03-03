#import <XCTest/XCTest.h>
#import <PubNub/PNHereNowRequest.h>
#import <PubNub/PNWhereNowRequest.h>
#import <PubNub/PNPresenceHeartbeatRequest.h>
#import <PubNub/PNPresenceStateSetRequest.h>
#import <PubNub/PNPresenceStateFetchRequest.h>
#import <PubNub/PNStructures.h>
#import "PNBaseRequest+Private.h"


#pragma mark Interface declaration

@interface PNPresenceRequestTest : XCTestCase

@end


#pragma mark - Tests

@implementation PNPresenceRequestTest


#pragma mark - PNHereNowRequest :: Construction (channels)

- (void)testItShouldCreateHereNowRequestWhenChannelsProvided {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[@"ch1", @"ch2"]];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channels, (@[@"ch1", @"ch2"]));
}

- (void)testItShouldHaveDefaultVerbosityInQueryWhenChannelHereNowCreated {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[@"ch1"]];

    NSDictionary *query = request.query;

    // Default PNHereNowState: UUIDs enabled, state enabled.
    XCTAssertEqualObjects(query[@"disable_uuids"], @"0");
    XCTAssertEqualObjects(query[@"state"], @"1");
}

- (void)testItShouldHaveDefaultLimitInQueryWhenChannelHereNowCreated {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[@"ch1"]];

    XCTAssertEqualObjects(request.query[@"limit"], @(1000).stringValue, @"Default limit should be 1000");
}


#pragma mark - PNHereNowRequest :: Construction (channel groups)

- (void)testItShouldCreateHereNowRequestWhenChannelGroupsProvided {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannelGroups:@[@"grp1"]];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.query[@"channel-group"], @"grp1");
}


#pragma mark - PNHereNowRequest :: Construction (global)

- (void)testItShouldCreateGlobalHereNowRequestWhenRequested {
    PNHereNowRequest *request = [PNHereNowRequest requestGlobal];

    XCTAssertNotNil(request);
}

- (void)testItShouldPassValidationWhenGlobalRequest {
    PNHereNowRequest *request = [PNHereNowRequest requestGlobal];

    XCTAssertNil([request validate], @"Global here now request should pass validation");
}


#pragma mark - PNHereNowRequest :: Query parameters

- (void)testItShouldSetOccupancyOnlyInQueryWhenVerbosityConfigured {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[@"ch"]];
    request.verbosityLevel = PNHereNowOccupancy;

    NSDictionary *query = request.query;

    // Occupancy: no UUIDs, no state.
    XCTAssertEqualObjects(query[@"disable_uuids"], @"1");
    XCTAssertEqualObjects(query[@"state"], @"0");
}

- (void)testItShouldCapLimitInQueryWhenExceedingMaximum {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[@"ch"]];
    request.limit = 5000;

    XCTAssertEqualObjects(request.query[@"limit"], @(1000).stringValue, @"Limit should be capped at 1000");
}

- (void)testItShouldIncludeLimitInQueryWhenBelowMaximum {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[@"ch"]];
    request.limit = 500;

    XCTAssertEqualObjects(request.query[@"limit"], @(500).stringValue);
}

- (void)testItShouldIncludeArbitraryParametersInHereNowQuery {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[@"ch"]];
    request.arbitraryQueryParameters = @{ @"key": @"value" };

    XCTAssertEqualObjects(request.query[@"key"], @"value");
}


#pragma mark - PNHereNowRequest :: Validation

- (void)testItShouldPassValidationWhenChannelsProvided {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[@"ch1"]];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenEmptyChannelsArrayProvided {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannels:@[]];

    XCTAssertNotNil([request validate], @"Validation should fail with empty channels");
}

- (void)testItShouldPassValidationWhenChannelGroupsProvided {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannelGroups:@[@"grp1"]];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenEmptyChannelGroupsProvided {
    PNHereNowRequest *request = [PNHereNowRequest requestForChannelGroups:@[]];

    XCTAssertNotNil([request validate], @"Validation should fail with empty channel groups");
}


#pragma mark - PNWhereNowRequest :: Construction

- (void)testItShouldCreateWhereNowRequestWhenUserIdProvided {
    PNWhereNowRequest *request = [PNWhereNowRequest requestForUserId:@"user-123"];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.userId, @"user-123");
}


#pragma mark - PNWhereNowRequest :: Validation

- (void)testItShouldPassValidationWhenUserIdProvided {
    PNWhereNowRequest *request = [PNWhereNowRequest requestForUserId:@"user-123"];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenUserIdIsEmpty {
    PNWhereNowRequest *request = [PNWhereNowRequest requestForUserId:@""];

    XCTAssertNotNil([request validate], @"Validation should fail with empty userId");
}


#pragma mark - PNPresenceHeartbeatRequest :: Construction

- (void)testItShouldCreateHeartbeatRequestWhenChannelsProvided {
    PNPresenceHeartbeatRequest *request = [PNPresenceHeartbeatRequest requestWithHeartbeat:300
                                                                                 channels:@[@"ch1"]
                                                                            channelGroups:nil];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channels, @[@"ch1"]);
    XCTAssertEqual(request.presenceHeartbeatValue, 300);
}

- (void)testItShouldIncludeHeartbeatValueInQuery {
    PNPresenceHeartbeatRequest *request = [PNPresenceHeartbeatRequest requestWithHeartbeat:300
                                                                                 channels:@[@"ch"]
                                                                            channelGroups:nil];

    XCTAssertEqualObjects(request.query[@"heartbeat"], @(300).stringValue);
}

- (void)testItShouldCreateHeartbeatRequestWhenChannelGroupsProvided {
    PNPresenceHeartbeatRequest *request = [PNPresenceHeartbeatRequest requestWithHeartbeat:120
                                                                                 channels:nil
                                                                            channelGroups:@[@"grp1"]];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.query[@"channel-group"], @"grp1");
}

- (void)testItShouldIncludeStateInHeartbeatQuery {
    PNPresenceHeartbeatRequest *request = [PNPresenceHeartbeatRequest requestWithHeartbeat:300
                                                                                 channels:@[@"ch"]
                                                                            channelGroups:nil];
    request.state = @{ @"ch": @{ @"key": @"value" } };

    XCTAssertNotNil(request.query[@"state"]);
}


#pragma mark - PNPresenceStateSetRequest :: Construction

- (void)testItShouldCreateStateSetRequestWhenUserIdProvided {
    PNPresenceStateSetRequest *request = [PNPresenceStateSetRequest requestWithUserId:@"user-123"];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.userId, @"user-123");
}

- (void)testItShouldHaveDefaultValuesWhenStateSetCreated {
    PNPresenceStateSetRequest *request = [PNPresenceStateSetRequest requestWithUserId:@"user-123"];

    XCTAssertNil(request.channels);
    XCTAssertNil(request.channelGroups);
    XCTAssertNil(request.state);
}


#pragma mark - PNPresenceStateSetRequest :: Query parameters

- (void)testItShouldIncludeStateInSetStateQuery {
    PNPresenceStateSetRequest *request = [PNPresenceStateSetRequest requestWithUserId:@"user-123"];
    request.channels = @[@"ch1", @"ch2"];
    request.state = @{ @"mood": @"happy" };

    NSString *stateJSON = request.query[@"state"];

    XCTAssertNotNil(stateJSON);
    NSData *stateData = [stateJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *state = [NSJSONSerialization JSONObjectWithData:stateData options:0 error:nil];
    XCTAssertEqualObjects(state[@"mood"], @"happy");
}

- (void)testItShouldIncludeChannelGroupsInSetStateQuery {
    PNPresenceStateSetRequest *request = [PNPresenceStateSetRequest requestWithUserId:@"user-123"];
    request.channelGroups = @[@"grp1"];

    XCTAssertEqualObjects(request.query[@"channel-group"], @"grp1");
}


#pragma mark - PNPresenceStateFetchRequest :: Construction

- (void)testItShouldCreateStateFetchRequestWhenUserIdProvided {
    PNPresenceStateFetchRequest *request = [PNPresenceStateFetchRequest requestWithUserId:@"user-123"];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.userId, @"user-123");
}

- (void)testItShouldHaveDefaultValuesWhenStateFetchCreated {
    PNPresenceStateFetchRequest *request = [PNPresenceStateFetchRequest requestWithUserId:@"user-123"];

    XCTAssertNil(request.channels);
    XCTAssertNil(request.channelGroups);
}


#pragma mark - PNPresenceStateFetchRequest :: Query parameters

- (void)testItShouldIncludeChannelGroupsInStateFetchQuery {
    PNPresenceStateFetchRequest *request = [PNPresenceStateFetchRequest requestWithUserId:@"user-123"];
    request.channelGroups = @[@"grp1"];

    XCTAssertEqualObjects(request.query[@"channel-group"], @"grp1");
}


#pragma mark -

@end
