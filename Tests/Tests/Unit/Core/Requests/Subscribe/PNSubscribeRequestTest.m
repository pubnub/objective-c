#import <XCTest/XCTest.h>
#import <PubNub/PNSubscribeRequest.h>
#import <PubNub/PNPresenceLeaveRequest.h>
#import "PNBaseRequest+Private.h"


#pragma mark Interface declaration

@interface PNSubscribeRequestTest : XCTestCase

@end


#pragma mark - Tests

@implementation PNSubscribeRequestTest


#pragma mark - PNSubscribeRequest :: Construction with channels

- (void)testItShouldCreateSubscribeRequestWhenChannelsProvided {
    NSArray *channels = @[@"channel1", @"channel2"];
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:channels channelGroups:nil];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects([NSSet setWithArray:request.channels], [NSSet setWithArray:channels]);
    XCTAssertNil(request.channelGroups);
}

- (void)testItShouldCreateSubscribeRequestWhenChannelGroupsProvided {
    NSArray *groups = @[@"group1", @"group2"];
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:nil channelGroups:groups];

    XCTAssertNotNil(request);
    XCTAssertNil(request.channels);
    XCTAssertEqualObjects([NSSet setWithArray:request.channelGroups], [NSSet setWithArray:groups]);
}

- (void)testItShouldCreateSubscribeRequestWhenBothChannelsAndGroupsProvided {
    NSArray *channels = @[@"ch1"];
    NSArray *groups = @[@"grp1"];
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:channels channelGroups:groups];

    XCTAssertEqualObjects(request.channels, channels);
    XCTAssertEqualObjects(request.channelGroups, groups);
}


#pragma mark - PNSubscribeRequest :: Default values

- (void)testItShouldHaveDefaultValuesWhenSubscribeRequestCreated {
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[@"ch"] channelGroups:nil];

    XCTAssertFalse(request.shouldObservePresence, @"observePresence should default to NO for regular subscribe");
    XCTAssertNil(request.state);
    XCTAssertNil(request.timetoken);
    XCTAssertNil(request.region);
}


#pragma mark - PNSubscribeRequest :: Query parameters

- (void)testItShouldIncludeTimetokenInQuery {
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[@"ch"] channelGroups:nil];
    request.timetoken = @(16000000000000000);

    XCTAssertEqualObjects(request.query[@"tt"], @(16000000000000000).stringValue);
}

- (void)testItShouldIncludeRegionInQuery {
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[@"ch"] channelGroups:nil];
    request.region = @42;

    XCTAssertEqualObjects(request.query[@"tr"], @(42).stringValue);
}

- (void)testItShouldIncludeStateInQuery {
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[@"ch"] channelGroups:nil];
    request.state = @{ @"ch": @{ @"mood": @"happy" } };

    NSString *stateJSON = request.query[@"state"];

    XCTAssertNotNil(stateJSON);
    NSData *stateData = [stateJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *state = [NSJSONSerialization JSONObjectWithData:stateData options:0 error:nil];
    XCTAssertEqualObjects(state[@"ch"][@"mood"], @"happy");
}

- (void)testItShouldIncludeChannelGroupsInQuery {
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[@"ch"] channelGroups:@[@"grp1", @"grp2"]];

    NSString *channelGroups = request.query[@"channel-group"];

    XCTAssertNotNil(channelGroups);
    XCTAssertTrue([channelGroups containsString:@"grp1"]);
    XCTAssertTrue([channelGroups containsString:@"grp2"]);
}


#pragma mark - PNSubscribeRequest :: Presence channels

- (void)testItShouldCreatePresenceSubscribeRequestWhenPresenceChannelsProvided {
    NSArray *channels = @[@"ch1", @"ch2"];
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithPresenceChannels:channels channelGroups:nil];

    XCTAssertNotNil(request);
    XCTAssertTrue(request.shouldObservePresence, @"observePresence should be YES for presence subscribe");
}

- (void)testItShouldAppendPresenceSuffixWhenPresenceChannelsCreated {
    NSArray *channels = @[@"ch1"];
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithPresenceChannels:channels channelGroups:nil];

    XCTAssertTrue([request.channels.firstObject hasSuffix:@"-pnpres"],
                  @"Channels should have -pnpres suffix");
}

- (void)testItShouldNotDuplicatePresenceSuffixWhenAlreadyPresent {
    NSArray *channels = @[@"ch1-pnpres"];
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithPresenceChannels:channels channelGroups:nil];

    XCTAssertEqualObjects(request.channels.firstObject, @"ch1-pnpres",
                          @"Should not double the -pnpres suffix");
}

- (void)testItShouldAppendPresenceSuffixToChannelGroupsWhenPresenceRequest {
    NSArray *groups = @[@"group1"];
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithPresenceChannels:nil channelGroups:groups];

    XCTAssertTrue([request.channelGroups.firstObject hasSuffix:@"-pnpres"],
                  @"Channel groups should have -pnpres suffix");
}


#pragma mark - PNSubscribeRequest :: Validation

- (void)testItShouldFailValidationWhenNoChannelsOrGroupsProvided {
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[] channelGroups:@[]];

    XCTAssertNotNil([request validate], @"Validation should fail with no channels or groups");
}

- (void)testItShouldPassValidationWhenChannelsProvided {
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:@[@"ch1"] channelGroups:nil];

    XCTAssertNil([request validate], @"Validation should pass with channels");
}

- (void)testItShouldPassValidationWhenChannelGroupsProvided {
    PNSubscribeRequest *request = [PNSubscribeRequest requestWithChannels:nil channelGroups:@[@"grp1"]];

    XCTAssertNil([request validate], @"Validation should pass with channel groups");
}


#pragma mark - PNPresenceLeaveRequest :: Construction

- (void)testItShouldCreateLeaveRequestWhenChannelsProvided {
    NSArray *channels = @[@"ch1", @"ch2"];
    PNPresenceLeaveRequest *request = [PNPresenceLeaveRequest requestWithChannels:channels channelGroups:nil];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects([NSSet setWithArray:request.channels], [NSSet setWithArray:channels]);
    XCTAssertNil(request.channelGroups);
}

- (void)testItShouldCreateLeaveRequestWhenChannelGroupsProvided {
    NSArray *groups = @[@"grp1"];
    PNPresenceLeaveRequest *request = [PNPresenceLeaveRequest requestWithChannels:nil channelGroups:groups];

    XCTAssertNotNil(request);
    XCTAssertNil(request.channels);
    XCTAssertEqualObjects(request.channelGroups, groups);
}

- (void)testItShouldCreatePresenceLeaveRequestWhenPresenceChannelsProvided {
    PNPresenceLeaveRequest *request = [PNPresenceLeaveRequest requestWithPresenceChannels:@[@"ch1"]
                                                                            channelGroups:nil];

    XCTAssertNotNil(request);
    XCTAssertTrue([request.channels.firstObject hasSuffix:@"-pnpres"]);
}


#pragma mark -

@end
