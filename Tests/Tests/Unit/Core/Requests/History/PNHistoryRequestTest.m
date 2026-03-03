#import <XCTest/XCTest.h>
#import <PubNub/PNHistoryFetchRequest.h>
#import <PubNub/PNHistoryMessagesCountRequest.h>
#import <PubNub/PNHistoryMessagesDeleteRequest.h>
#import "PNBaseRequest+Private.h"


#pragma mark Interface declaration

@interface PNHistoryRequestTest : XCTestCase

@end


#pragma mark - Tests

@implementation PNHistoryRequestTest


#pragma mark - PNHistoryFetchRequest :: Construction (single channel)

- (void)testItShouldCreateFetchRequestWhenSingleChannelProvided {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannel:@"test-channel"];

    XCTAssertNotNil(request);
    XCTAssertEqual(request.channels.count, 1);
    XCTAssertEqualObjects(request.channels.firstObject, @"test-channel");
}

- (void)testItShouldHaveDefaultValuesWhenSingleChannelFetchRequestCreated {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannel:@"ch"];

    XCTAssertTrue(request.includeMessageType, @"includeMessageType should default to YES");
    XCTAssertTrue(request.includeUUID, @"includeUUID should default to YES");
    XCTAssertFalse(request.includeMessageActions, @"includeMessageActions should default to NO");
    XCTAssertFalse(request.includeCustomMessageType, @"includeCustomMessageType should default to NO");
    XCTAssertFalse(request.includeMetadata, @"includeMetadata should default to NO");
    XCTAssertFalse(request.includeTimeToken, @"includeTimeToken should default to NO");
    XCTAssertFalse(request.reverse, @"reverse should default to NO");
    XCTAssertEqual(request.limit, 0, @"limit should default to 0");
    XCTAssertNil(request.start, @"start should default to nil");
    XCTAssertNil(request.end, @"end should default to nil");
}


#pragma mark - PNHistoryFetchRequest :: Construction (multiple channels)

- (void)testItShouldCreateFetchRequestWhenMultipleChannelsProvided {
    NSArray *channels = @[@"ch1", @"ch2", @"ch3"];
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannels:channels];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channels, channels);
}


#pragma mark - PNHistoryFetchRequest :: Query parameters

- (void)testItShouldIncludeStartAndEndTimetokensInQuery {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannel:@"ch"];
    request.start = @(16000000000000000);
    request.end = @(16100000000000000);

    NSDictionary *query = request.query;

    XCTAssertNotNil(query[@"start"]);
    XCTAssertNotNil(query[@"end"]);
}

- (void)testItShouldIncludeLimitInSingleChannelQuery {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannel:@"ch"];
    request.limit = 50;

    XCTAssertEqualObjects(request.query[@"count"], @(50).stringValue);
}

- (void)testItShouldUseDifferentLimitKeyForMultiChannelQuery {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannels:@[@"ch1", @"ch2"]];
    request.limit = 10;

    XCTAssertNotNil(request.query[@"max"], @"Multi-channel should use 'max' limit key");
    XCTAssertNil(request.query[@"count"], @"Multi-channel should not use 'count' limit key");
}

- (void)testItShouldIncludeReverseInQuery {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannel:@"ch"];
    request.reverse = YES;

    XCTAssertEqualObjects(request.query[@"reverse"], @"true");
}

- (void)testItShouldIncludeMetadataFlagInQuery {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannel:@"ch"];
    request.includeMetadata = YES;

    XCTAssertEqualObjects(request.query[@"include_meta"], @"true");
}

- (void)testItShouldIncludeTimeTokenFlagInQuery {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannel:@"ch"];
    request.includeTimeToken = YES;

    XCTAssertEqualObjects(request.query[@"include_token"], @"true");
}

- (void)testItShouldUseLimitKeyMaxWhenMessageActionsEnabled {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannel:@"ch"];
    request.includeMessageActions = YES;

    XCTAssertEqualObjects(request.query[@"max"], @(25).stringValue, @"With-actions default limit should be 25");
    XCTAssertNil(request.query[@"count"], @"With-actions should not use 'count' limit key");
}


#pragma mark - PNHistoryFetchRequest :: Validation

- (void)testItShouldPassValidationWhenSingleChannelProvided {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannel:@"ch"];

    XCTAssertNil([request validate]);
}

- (void)testItShouldPassValidationWhenMultipleChannelsProvided {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannels:@[@"ch1", @"ch2"]];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenEmptyChannelsArrayProvided {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannels:@[]];

    XCTAssertNotNil([request validate], @"Validation should fail with empty channels array");
}

- (void)testItShouldFailValidationWhenMultiChannelRequestHasMessageActionsEnabled {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannels:@[@"ch1", @"ch2"]];
    request.includeMessageActions = YES;

    XCTAssertNotNil([request validate],
                    @"Validation should fail with messageActions on multi-channel request");
}

- (void)testItShouldPassValidationWhenSingleChannelHasMessageActionsEnabled {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannel:@"ch"];
    request.includeMessageActions = YES;

    XCTAssertNil([request validate],
                 @"Validation should pass with messageActions on single channel request");
}


#pragma mark - PNHistoryMessagesCountRequest :: Construction

- (void)testItShouldCreateMessagesCountRequestWhenChannelsAndTimetokensProvided {
    NSArray *channels = @[@"ch1", @"ch2"];
    NSArray *timetokens = @[@(1550140202)];
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:channels
                                                                                    timetokens:timetokens];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channels, channels);
    XCTAssertEqualObjects(request.timetokens, timetokens);
}

- (void)testItShouldRetainMultipleTimetokensWhenProvided {
    NSArray *channels = @[@"ch1", @"ch2"];
    NSArray *timetokens = @[@(1550140202), @(1550140204)];
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:channels
                                                                                    timetokens:timetokens];

    XCTAssertEqual(request.timetokens.count, 2);
}


#pragma mark - PNHistoryMessagesCountRequest :: Validation

- (void)testItShouldPassValidationWhenChannelsAndSingleTimetokenProvided {
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:@[@"ch1", @"ch2"]
                                                                                    timetokens:@[@(1550140202)]];

    XCTAssertNil([request validate]);
}

- (void)testItShouldPassValidationWhenChannelsMatchTimetokensCount {
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:@[@"ch1", @"ch2"]
                                                                                    timetokens:@[@(100), @(200)]];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenNoChannelsProvided {
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:@[]
                                                                                    timetokens:@[@(100)]];

    XCTAssertNotNil([request validate], @"Validation should fail without channels");
}

- (void)testItShouldFailValidationWhenNoTimetokensProvided {
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:@[@"ch1"]
                                                                                    timetokens:@[]];

    XCTAssertNotNil([request validate], @"Validation should fail without timetokens");
}

- (void)testItShouldFailValidationWhenTimetokensCountMismatchesChannels {
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:@[@"ch1", @"ch2"]
                                                                                    timetokens:@[@(100), @(200), @(300)]];

    XCTAssertNotNil([request validate],
                    @"Validation should fail when timetoken count doesn't match channel count");
}


#pragma mark - PNHistoryMessagesDeleteRequest :: Construction

- (void)testItShouldCreateDeleteRequestWhenChannelProvided {
    PNHistoryMessagesDeleteRequest *request = [PNHistoryMessagesDeleteRequest requestWithChannel:@"test-channel"];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channel, @"test-channel");
}

- (void)testItShouldHaveDefaultValuesWhenDeleteRequestCreated {
    PNHistoryMessagesDeleteRequest *request = [PNHistoryMessagesDeleteRequest requestWithChannel:@"ch"];

    XCTAssertNil(request.start, @"start should default to nil");
    XCTAssertNil(request.end, @"end should default to nil");
}


#pragma mark - PNHistoryMessagesDeleteRequest :: Query parameters

- (void)testItShouldIncludeStartAndEndInDeleteQuery {
    PNHistoryMessagesDeleteRequest *request = [PNHistoryMessagesDeleteRequest requestWithChannel:@"ch"];
    request.start = @(16000000000000000);
    request.end = @(16100000000000000);

    NSDictionary *query = request.query;

    XCTAssertNotNil(query[@"start"]);
    XCTAssertNotNil(query[@"end"]);
}


#pragma mark - PNHistoryMessagesDeleteRequest :: Validation

- (void)testItShouldPassValidationWhenDeleteChannelProvided {
    PNHistoryMessagesDeleteRequest *request = [PNHistoryMessagesDeleteRequest requestWithChannel:@"ch"];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenDeleteChannelIsEmpty {
    PNHistoryMessagesDeleteRequest *request = [PNHistoryMessagesDeleteRequest requestWithChannel:@""];

    XCTAssertNotNil([request validate], @"Validation should fail with empty channel");
}


#pragma mark -

@end
