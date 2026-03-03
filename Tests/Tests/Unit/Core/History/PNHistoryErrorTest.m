/**
 * @brief Error / negative path tests for History, Message Count, and Delete Messages operations.
 *
 * @author PubNub Tests
 * @copyright (c) 2010-2026 PubNub, Inc.
 */
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNHistoryMessagesCountRequest.h>
#import <PubNub/PNHistoryMessagesDeleteRequest.h>
#import <PubNub/PNHistoryFetchRequest.h>
#import "PNRecordableTestCase.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNHistoryErrorTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNHistoryErrorTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: History :: Missing channel (single channel request)

- (void)testItShouldReturnValidationErrorWhenHistoryFetchChannelIsEmpty {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannel:@""];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channel"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenHistoryFetchChannelIsNil {
    NSString *channel = nil;
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannel:channel];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channel"].location, NSNotFound);
}


#pragma mark - Tests :: History :: Missing channels (multi-channel request)

- (void)testItShouldReturnValidationErrorWhenHistoryFetchChannelsIsEmpty {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannels:@[]];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channels"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenHistoryFetchChannelsIsNil {
    NSArray *channels = nil;
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannels:channels];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channels"].location, NSNotFound);
}


#pragma mark - Tests :: History :: Message actions with multiple channels

- (void)testItShouldReturnValidationErrorWhenMessageActionsUsedWithMultipleChannels {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannels:@[@"ch-a", @"ch-b"]];
    request.includeMessageActions = YES;

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"includeMessageActions"].location, NSNotFound);
}


#pragma mark - Tests :: History :: Valid single channel request

- (void)testItShouldNotReturnValidationErrorWhenHistoryFetchChannelIsValid {
    PNHistoryFetchRequest *request = [PNHistoryFetchRequest requestWithChannel:@"test-channel"];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: Messages Count :: Missing channels

- (void)testItShouldReturnValidationErrorWhenMessageCountChannelsIsEmpty {
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:@[]
                                                                                    timetokens:@[@(123456)]];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channels"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenMessageCountChannelsIsNil {
    NSArray *channels = nil;
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:channels
                                                                                    timetokens:@[@(123456)]];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channels"].location, NSNotFound);
}


#pragma mark - Tests :: Messages Count :: Missing timetokens

- (void)testItShouldReturnValidationErrorWhenMessageCountTimetokensIsEmpty {
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:@[@"ch-a"]
                                                                                    timetokens:@[]];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"timetokens"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenMessageCountTimetokensIsNil {
    NSArray *timetokens = nil;
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:@[@"ch-a"]
                                                                                    timetokens:timetokens];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"timetokens"].location, NSNotFound);
}


#pragma mark - Tests :: Messages Count :: Mismatched channels and timetokens count

- (void)testItShouldReturnValidationErrorWhenChannelCountDoesNotMatchTimetokenCount {
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:@[@"ch-a", @"ch-b"]
                                                                                    timetokens:@[@(1), @(2), @(3)]];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"doesn't match"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenOneChannelHasMultipleTimetokens {
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:@[@"ch-a"]
                                                                                    timetokens:@[@(1), @(2)]];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
}


#pragma mark - Tests :: Messages Count :: Valid request

- (void)testItShouldNotReturnValidationErrorWhenMessageCountParamsAreValid {
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:@[@"ch-a"]
                                                                                    timetokens:@[@(123456)]];

    PNError *error = [request validate];

    XCTAssertNil(error);
}

- (void)testItShouldNotReturnValidationErrorWhenMultipleChannelsMatchTimetokens {
    PNHistoryMessagesCountRequest *request = [PNHistoryMessagesCountRequest requestWithChannels:@[@"ch-a", @"ch-b"]
                                                                                    timetokens:@[@(1), @(2)]];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark - Tests :: Delete Messages :: Missing channel

- (void)testItShouldReturnValidationErrorWhenDeleteMessagesChannelIsEmpty {
    PNHistoryMessagesDeleteRequest *request = [PNHistoryMessagesDeleteRequest requestWithChannel:@""];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channel"].location, NSNotFound);
}

- (void)testItShouldReturnValidationErrorWhenDeleteMessagesChannelIsNil {
    NSString *channel = nil;
    PNHistoryMessagesDeleteRequest *request = [PNHistoryMessagesDeleteRequest requestWithChannel:channel];

    PNError *error = [request validate];

    XCTAssertNotNil(error);
    XCTAssertNotEqual([error.localizedFailureReason rangeOfString:@"channel"].location, NSNotFound);
}


#pragma mark - Tests :: Delete Messages :: Valid request

- (void)testItShouldNotReturnValidationErrorWhenDeleteMessagesChannelIsValid {
    PNHistoryMessagesDeleteRequest *request = [PNHistoryMessagesDeleteRequest requestWithChannel:@"test-channel"];

    PNError *error = [request validate];

    XCTAssertNil(error);
}


#pragma mark -

#pragma clang diagnostic pop

@end
