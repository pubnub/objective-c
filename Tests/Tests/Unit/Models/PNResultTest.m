#import <XCTest/XCTest.h>
#import <PubNub/PNOperationResult.h>
#import <PubNub/PNTimeResult.h>
#import <PubNub/PNTimeData.h>
#import <PubNub/PNHistoryResult.h>
#import <PubNub/PNHistoryFetchData.h>
#import <PubNub/PNMessageCountResult.h>
#import <PubNub/PNHistoryMessageCountData.h>
#import <PubNub/PNPresenceHereNowResult.h>
#import <PubNub/PNPresenceHereNowFetchData.h>
#import <PubNub/PNPresenceWhereNowResult.h>
#import <PubNub/PNPresenceWhereNowFetchData.h>
#import <PubNub/PNChannelGroupChannelsResult.h>
#import <PubNub/PNChannelGroupFetchData.h>
#import <PubNub/PNStructures.h>
#import "PNOperationResult+Private.h"


#pragma mark - Private interface exposure

@interface PNTimeData (TestAccess)

- (instancetype)initWithTimetoken:(NSNumber *)timetoken;

@end


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Unit tests for PNOperationResult subclasses and their associated data objects.
///
/// Tests covering construction and property access for result model objects used by the SDK.
@interface PNResultTest : XCTestCase

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNResultTest


#pragma mark - Tests :: PNTimeResult

- (void)testItShouldCreateTimeResult {
    PNTimeResult *result = [PNTimeResult objectWithOperation:PNTimeOperation response:nil];

    XCTAssertEqual(result.operation, PNTimeOperation, @"Operation type should be PNTimeOperation.");
}

- (void)testItShouldReturnTimeResultDataWhenResponseIsSet {
    PNTimeData *timeData = [[PNTimeData alloc] initWithTimetoken:@(16000000000000000)];
    PNTimeResult *result = [PNTimeResult objectWithOperation:PNTimeOperation response:timeData];

    XCTAssertNotNil(result.data, @"Time result data should not be nil.");
    XCTAssertEqualObjects(result.data.timetoken, @(16000000000000000),
                          @"Timetoken should match the provided value.");
}

- (void)testItShouldReturnNilDataWhenTimeResponseIsNil {
    PNTimeResult *result = [PNTimeResult objectWithOperation:PNTimeOperation response:nil];

    XCTAssertNil(result.data, @"Time result data should be nil when no response is set.");
}

- (void)testItShouldReturnStringifiedTimeOperation {
    PNTimeResult *result = [PNTimeResult objectWithOperation:PNTimeOperation response:nil];

    XCTAssertEqualObjects(result.stringifiedOperation, @"Time",
                          @"Stringified operation should be 'Time'.");
}

- (void)testItShouldBeSubclassOfPNOperationResult {
    PNTimeResult *result = [PNTimeResult objectWithOperation:PNTimeOperation response:nil];

    XCTAssertTrue([result isKindOfClass:[PNOperationResult class]],
                  @"PNTimeResult should be a subclass of PNOperationResult.");
}


#pragma mark - Tests :: PNHistoryResult

- (void)testItShouldCreateHistoryResult {
    PNHistoryResult *result = [PNHistoryResult objectWithOperation:PNHistoryOperation response:nil];

    XCTAssertEqual(result.operation, PNHistoryOperation, @"Operation type should be PNHistoryOperation.");
}

- (void)testItShouldReturnNilDataWhenHistoryResponseIsNil {
    PNHistoryResult *result = [PNHistoryResult objectWithOperation:PNHistoryOperation response:nil];

    XCTAssertNil(result.data, @"History result data should be nil when no response is set.");
}

- (void)testItShouldSupportHistoryForChannelsOperation {
    PNHistoryResult *result = [PNHistoryResult objectWithOperation:PNHistoryForChannelsOperation response:nil];

    XCTAssertEqual(result.operation, PNHistoryForChannelsOperation,
                   @"Operation type should be PNHistoryForChannelsOperation.");
    XCTAssertEqualObjects(result.stringifiedOperation, @"History for Channels",
                          @"Stringified operation should match.");
}

- (void)testItShouldSupportHistoryWithActionsOperation {
    PNHistoryResult *result = [PNHistoryResult objectWithOperation:PNHistoryWithActionsOperation response:nil];

    XCTAssertEqualObjects(result.stringifiedOperation, @"History with Actions",
                          @"Stringified operation should match.");
}


#pragma mark - Tests :: PNMessageCountResult

- (void)testItShouldCreateMessageCountResult {
    PNMessageCountResult *result = [PNMessageCountResult objectWithOperation:PNMessageCountOperation response:nil];

    XCTAssertEqual(result.operation, PNMessageCountOperation,
                   @"Operation type should be PNMessageCountOperation.");
}

- (void)testItShouldReturnNilDataWhenMessageCountResponseIsNil {
    PNMessageCountResult *result = [PNMessageCountResult objectWithOperation:PNMessageCountOperation response:nil];

    XCTAssertNil(result.data, @"Message count result data should be nil when no response is set.");
}

- (void)testItShouldReturnStringifiedMessageCountOperation {
    PNMessageCountResult *result = [PNMessageCountResult objectWithOperation:PNMessageCountOperation response:nil];

    XCTAssertEqualObjects(result.stringifiedOperation, @"Message count for Channels",
                          @"Stringified operation should match.");
}


#pragma mark - Tests :: PNPresenceHereNowResult

- (void)testItShouldCreateHereNowResult {
    PNPresenceHereNowResult *result = [PNPresenceHereNowResult objectWithOperation:PNHereNowForChannelOperation
                                                                          response:nil];

    XCTAssertEqual(result.operation, PNHereNowForChannelOperation,
                   @"Operation type should be PNHereNowForChannelOperation.");
}

- (void)testItShouldReturnNilDataWhenHereNowResponseIsNil {
    PNPresenceHereNowResult *result = [PNPresenceHereNowResult objectWithOperation:PNHereNowForChannelOperation
                                                                          response:nil];

    XCTAssertNil(result.data, @"Here now result data should be nil when no response is set.");
}

- (void)testItShouldSupportGlobalHereNowOperation {
    PNPresenceHereNowResult *result = [PNPresenceHereNowResult objectWithOperation:PNHereNowGlobalOperation
                                                                          response:nil];

    XCTAssertEqualObjects(result.stringifiedOperation, @"Global Here Now",
                          @"Stringified operation should match.");
}


#pragma mark - Tests :: PNPresenceWhereNowResult

- (void)testItShouldCreateWhereNowResult {
    PNPresenceWhereNowResult *result = [PNPresenceWhereNowResult objectWithOperation:PNWhereNowOperation
                                                                            response:nil];

    XCTAssertEqual(result.operation, PNWhereNowOperation,
                   @"Operation type should be PNWhereNowOperation.");
}

- (void)testItShouldReturnNilDataWhenWhereNowResponseIsNil {
    PNPresenceWhereNowResult *result = [PNPresenceWhereNowResult objectWithOperation:PNWhereNowOperation
                                                                            response:nil];

    XCTAssertNil(result.data, @"Where now result data should be nil when no response is set.");
}

- (void)testItShouldReturnStringifiedWhereNowOperation {
    PNPresenceWhereNowResult *result = [PNPresenceWhereNowResult objectWithOperation:PNWhereNowOperation
                                                                            response:nil];

    XCTAssertEqualObjects(result.stringifiedOperation, @"Where Now",
                          @"Stringified operation should be 'Where Now'.");
}


#pragma mark - Tests :: PNChannelGroupChannelsResult

- (void)testItShouldCreateChannelGroupChannelsResult {
    PNChannelGroupChannelsResult *result = [PNChannelGroupChannelsResult objectWithOperation:PNChannelsForGroupOperation
                                                                                   response:nil];

    XCTAssertEqual(result.operation, PNChannelsForGroupOperation,
                   @"Operation type should be PNChannelsForGroupOperation.");
}

- (void)testItShouldReturnNilDataWhenChannelGroupResponseIsNil {
    PNChannelGroupChannelsResult *result = [PNChannelGroupChannelsResult objectWithOperation:PNChannelsForGroupOperation
                                                                                   response:nil];

    XCTAssertNil(result.data, @"Channel group result data should be nil when no response is set.");
}

- (void)testItShouldReturnStringifiedChannelsForGroupOperation {
    PNChannelGroupChannelsResult *result = [PNChannelGroupChannelsResult objectWithOperation:PNChannelsForGroupOperation
                                                                                   response:nil];

    XCTAssertEqualObjects(result.stringifiedOperation, @"Get Channels For Group",
                          @"Stringified operation should match.");
}


#pragma mark - Tests :: Result with mock response data

- (void)testItShouldReturnTimeDataWhenSetDirectly {
    PNTimeData *timeData = [[PNTimeData alloc] initWithTimetoken:@(16123456789012345)];
    PNTimeResult *result = [PNTimeResult objectWithOperation:PNTimeOperation response:timeData];

    XCTAssertNotNil(result.data, @"Data should not be nil when response is set.");
    XCTAssertTrue([result.data isKindOfClass:[PNTimeData class]], @"Data should be PNTimeData instance.");
    XCTAssertEqualObjects(result.data.timetoken, @(16123456789012345),
                          @"Timetoken should be preserved correctly.");
}

- (void)testItShouldPreserveLargeTimetoken {
    PNTimeData *timeData = [[PNTimeData alloc] initWithTimetoken:@(17094336000000000)];
    PNTimeResult *result = [PNTimeResult objectWithOperation:PNTimeOperation response:timeData];

    XCTAssertEqualObjects(result.data.timetoken, @(17094336000000000),
                          @"Large timetoken should be preserved without precision loss.");
}


#pragma mark - Tests :: Result copy

- (void)testItShouldCopyTimeResult {
    PNTimeData *timeData = [[PNTimeData alloc] initWithTimetoken:@(16000000000000000)];
    PNTimeResult *result = [PNTimeResult objectWithOperation:PNTimeOperation response:timeData];
    PNTimeResult *copy = [result copy];

    XCTAssertNotNil(copy, @"Copied result should not be nil.");
    XCTAssertEqual(copy.operation, PNTimeOperation, @"Copied result should preserve operation.");
    XCTAssertEqualObjects(copy.data.timetoken, @(16000000000000000),
                          @"Copied result should preserve data.");
}

- (void)testItShouldCopyHistoryResult {
    PNHistoryResult *result = [PNHistoryResult objectWithOperation:PNHistoryOperation response:nil];
    PNHistoryResult *copy = [result copy];

    XCTAssertNotNil(copy, @"Copied history result should not be nil.");
    XCTAssertEqual(copy.operation, PNHistoryOperation, @"Copied result should preserve operation.");
}


#pragma mark - Tests :: Multiple result types independence

- (void)testMultipleResultTypesShouldBeIndependent {
    PNTimeData *timeData = [[PNTimeData alloc] initWithTimetoken:@(16000000000000000)];
    PNTimeResult *timeResult = [PNTimeResult objectWithOperation:PNTimeOperation response:timeData];
    PNHistoryResult *historyResult = [PNHistoryResult objectWithOperation:PNHistoryOperation response:nil];
    PNMessageCountResult *countResult = [PNMessageCountResult objectWithOperation:PNMessageCountOperation response:nil];

    XCTAssertEqual(timeResult.operation, PNTimeOperation, @"Time result operation should be independent.");
    XCTAssertEqual(historyResult.operation, PNHistoryOperation, @"History result operation should be independent.");
    XCTAssertEqual(countResult.operation, PNMessageCountOperation, @"Count result operation should be independent.");
    XCTAssertNotNil(timeResult.data, @"Time result should have data.");
    XCTAssertNil(historyResult.data, @"History result should have nil data.");
    XCTAssertNil(countResult.data, @"Count result should have nil data.");
}


#pragma mark - Tests :: All operation types have string representation

- (void)testAllMainOperationTypesShouldHaveStringRepresentation {
    NSArray<NSNumber *> *operations = @[
        @(PNSubscribeOperation),
        @(PNUnsubscribeOperation),
        @(PNPublishOperation),
        @(PNSignalOperation),
        @(PNHistoryOperation),
        @(PNHistoryForChannelsOperation),
        @(PNHistoryWithActionsOperation),
        @(PNDeleteMessageOperation),
        @(PNMessageCountOperation),
        @(PNWhereNowOperation),
        @(PNHereNowGlobalOperation),
        @(PNHereNowForChannelOperation),
        @(PNHereNowForChannelGroupOperation),
        @(PNTimeOperation),
        @(PNChannelsForGroupOperation),
        @(PNChannelGroupsOperation),
        @(PNSetStateOperation),
        @(PNGetStateOperation),
        @(PNFetchUUIDMetadataOperation),
        @(PNFetchAllUUIDMetadataOperation),
        @(PNFetchChannelMetadataOperation),
        @(PNFetchAllChannelsMetadataOperation),
        @(PNFetchMembershipsOperation),
        @(PNFetchChannelMembersOperation),
        @(PNFetchMessagesActionsOperation),
        @(PNListFilesOperation),
        @(PNDownloadFileOperation),
    ];

    for (NSNumber *opNumber in operations) {
        PNOperationType op = (PNOperationType)opNumber.integerValue;
        PNOperationResult *result = [PNOperationResult objectWithOperation:op response:nil];

        XCTAssertNotNil(result.stringifiedOperation,
                        @"Operation %ld should have a string representation.", (long)op);
        XCTAssertFalse([result.stringifiedOperation isEqualToString:@"Unknown"],
                       @"Operation %ld should not return 'Unknown' as string representation.", (long)op);
    }
}

#pragma mark -


@end
