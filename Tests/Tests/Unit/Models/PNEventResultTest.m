#import <XCTest/XCTest.h>
#import <PubNub/PNOperationResult.h>
#import <PubNub/PNMessageResult.h>
#import <PubNub/PNSignalResult.h>
#import <PubNub/PNPresenceEventResult.h>
#import <PubNub/PNFileEventResult.h>
#import <PubNub/PNObjectEventResult.h>
#import <PubNub/PNMessageActionResult.h>
#import <PubNub/PNSubscribeMessageEventData.h>
#import <PubNub/PNSubscribeSignalEventData.h>
#import <PubNub/PNSubscribePresenceEventData.h>
#import <PubNub/PNSubscribeFileEventData.h>
#import <PubNub/PNSubscribeObjectEventData.h>
#import <PubNub/PNSubscribeMessageActionEventData.h>
#import <PubNub/PNSubscribeEventData.h>
#import <PubNub/PNStructures.h>
#import "PNOperationResult+Private.h"
#import "PNSubscribeEventData+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Unit tests for subscribe event result model objects.
///
/// Tests covering construction and property access for PNMessageResult, PNSignalResult,
/// PNPresenceEventResult, PNFileEventResult, PNObjectEventResult, and PNMessageActionResult.
@interface PNEventResultTest : XCTestCase

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNEventResultTest


#pragma mark - Tests :: PNMessageResult

- (void)testItShouldCreateMessageResult {
    PNMessageResult *result = [PNMessageResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertEqual(result.operation, PNSubscribeOperation,
                   @"Operation type should be PNSubscribeOperation.");
}

- (void)testItShouldReturnNilDataWhenMessageResponseIsNil {
    PNMessageResult *result = [PNMessageResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertNil(result.data, @"Message result data should be nil when no response is set.");
}

- (void)testItShouldBeSubclassOfPNOperationResult {
    PNMessageResult *result = [PNMessageResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertTrue([result isKindOfClass:[PNOperationResult class]],
                  @"PNMessageResult should be a subclass of PNOperationResult.");
}

- (void)testItShouldReturnMessageEventDataWhenResponseSet {
    PNSubscribeMessageEventData *eventData = [[PNSubscribeMessageEventData alloc] init];
    PNMessageResult *result = [PNMessageResult objectWithOperation:PNSubscribeOperation response:eventData];

    XCTAssertNotNil(result.data, @"Data should not be nil when response is set.");
    XCTAssertTrue([result.data isKindOfClass:[PNSubscribeMessageEventData class]],
                  @"Data should be PNSubscribeMessageEventData instance.");
}

- (void)testItShouldCopyMessageResult {
    PNSubscribeMessageEventData *eventData = [[PNSubscribeMessageEventData alloc] init];
    PNMessageResult *result = [PNMessageResult objectWithOperation:PNSubscribeOperation response:eventData];
    PNMessageResult *copy = [result copy];

    XCTAssertNotNil(copy, @"Copied message result should not be nil.");
    XCTAssertEqual(copy.operation, PNSubscribeOperation,
                   @"Copied result should preserve operation type.");
}


#pragma mark - Tests :: PNSignalResult

- (void)testItShouldCreateSignalResult {
    PNSignalResult *result = [PNSignalResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertEqual(result.operation, PNSubscribeOperation,
                   @"Operation type should be PNSubscribeOperation.");
}

- (void)testItShouldReturnNilDataWhenSignalResponseIsNil {
    PNSignalResult *result = [PNSignalResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertNil(result.data, @"Signal result data should be nil when no response is set.");
}

- (void)testItShouldReturnSignalEventDataWhenResponseSet {
    PNSubscribeSignalEventData *eventData = [[PNSubscribeSignalEventData alloc] init];
    PNSignalResult *result = [PNSignalResult objectWithOperation:PNSubscribeOperation response:eventData];

    XCTAssertNotNil(result.data, @"Data should not be nil when response is set.");
    XCTAssertTrue([result.data isKindOfClass:[PNSubscribeSignalEventData class]],
                  @"Data should be PNSubscribeSignalEventData instance.");
}

- (void)testItShouldBeSignalEventDataSubclassOfMessageEventData {
    PNSubscribeSignalEventData *signalData = [[PNSubscribeSignalEventData alloc] init];

    XCTAssertTrue([signalData isKindOfClass:[PNSubscribeMessageEventData class]],
                  @"PNSubscribeSignalEventData should be a subclass of PNSubscribeMessageEventData.");
}


#pragma mark - Tests :: PNPresenceEventResult

- (void)testItShouldCreatePresenceEventResult {
    PNPresenceEventResult *result = [PNPresenceEventResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertEqual(result.operation, PNSubscribeOperation,
                   @"Operation type should be PNSubscribeOperation.");
}

- (void)testItShouldReturnNilDataWhenPresenceResponseIsNil {
    PNPresenceEventResult *result = [PNPresenceEventResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertNil(result.data, @"Presence event result data should be nil when no response is set.");
}

- (void)testItShouldReturnPresenceEventDataWhenResponseSet {
    PNSubscribePresenceEventData *eventData = [[PNSubscribePresenceEventData alloc] init];
    PNPresenceEventResult *result = [PNPresenceEventResult objectWithOperation:PNSubscribeOperation
                                                                      response:eventData];

    XCTAssertNotNil(result.data, @"Data should not be nil when response is set.");
    XCTAssertTrue([result.data isKindOfClass:[PNSubscribePresenceEventData class]],
                  @"Data should be PNSubscribePresenceEventData instance.");
}

- (void)testPresenceEventDataShouldBeSubclassOfSubscribeEventData {
    PNSubscribePresenceEventData *presenceData = [[PNSubscribePresenceEventData alloc] init];

    XCTAssertTrue([presenceData isKindOfClass:[PNSubscribeEventData class]],
                  @"PNSubscribePresenceEventData should be a subclass of PNSubscribeEventData.");
}


#pragma mark - Tests :: PNFileEventResult

- (void)testItShouldCreateFileEventResult {
    PNFileEventResult *result = [PNFileEventResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertEqual(result.operation, PNSubscribeOperation,
                   @"Operation type should be PNSubscribeOperation.");
}

- (void)testItShouldReturnNilDataWhenFileResponseIsNil {
    PNFileEventResult *result = [PNFileEventResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertNil(result.data, @"File event result data should be nil when no response is set.");
}

- (void)testItShouldReturnFileEventDataWhenResponseSet {
    PNSubscribeFileEventData *eventData = [[PNSubscribeFileEventData alloc] init];
    PNFileEventResult *result = [PNFileEventResult objectWithOperation:PNSubscribeOperation response:eventData];

    XCTAssertNotNil(result.data, @"Data should not be nil when response is set.");
    XCTAssertTrue([result.data isKindOfClass:[PNSubscribeFileEventData class]],
                  @"Data should be PNSubscribeFileEventData instance.");
}

- (void)testFileEventDataShouldBeSubclassOfSubscribeEventData {
    PNSubscribeFileEventData *fileData = [[PNSubscribeFileEventData alloc] init];

    XCTAssertTrue([fileData isKindOfClass:[PNSubscribeEventData class]],
                  @"PNSubscribeFileEventData should be a subclass of PNSubscribeEventData.");
}


#pragma mark - Tests :: PNObjectEventResult

- (void)testItShouldCreateObjectEventResult {
    PNObjectEventResult *result = [PNObjectEventResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertEqual(result.operation, PNSubscribeOperation,
                   @"Operation type should be PNSubscribeOperation.");
}

- (void)testItShouldReturnNilDataWhenObjectResponseIsNil {
    PNObjectEventResult *result = [PNObjectEventResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertNil(result.data, @"Object event result data should be nil when no response is set.");
}

- (void)testItShouldReturnObjectEventDataWhenResponseSet {
    PNSubscribeObjectEventData *eventData = [[PNSubscribeObjectEventData alloc] init];
    PNObjectEventResult *result = [PNObjectEventResult objectWithOperation:PNSubscribeOperation response:eventData];

    XCTAssertNotNil(result.data, @"Data should not be nil when response is set.");
    XCTAssertTrue([result.data isKindOfClass:[PNSubscribeObjectEventData class]],
                  @"Data should be PNSubscribeObjectEventData instance.");
}

- (void)testObjectEventDataShouldBeSubclassOfSubscribeEventData {
    PNSubscribeObjectEventData *objectData = [[PNSubscribeObjectEventData alloc] init];

    XCTAssertTrue([objectData isKindOfClass:[PNSubscribeEventData class]],
                  @"PNSubscribeObjectEventData should be a subclass of PNSubscribeEventData.");
}


#pragma mark - Tests :: PNMessageActionResult

- (void)testItShouldCreateMessageActionResult {
    PNMessageActionResult *result = [PNMessageActionResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertEqual(result.operation, PNSubscribeOperation,
                   @"Operation type should be PNSubscribeOperation.");
}

- (void)testItShouldReturnNilDataWhenMessageActionResponseIsNil {
    PNMessageActionResult *result = [PNMessageActionResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertNil(result.data, @"Message action result data should be nil when no response is set.");
}

- (void)testItShouldReturnMessageActionEventDataWhenResponseSet {
    PNSubscribeMessageActionEventData *eventData = [[PNSubscribeMessageActionEventData alloc] init];
    PNMessageActionResult *result = [PNMessageActionResult objectWithOperation:PNSubscribeOperation response:eventData];

    XCTAssertNotNil(result.data, @"Data should not be nil when response is set.");
    XCTAssertTrue([result.data isKindOfClass:[PNSubscribeMessageActionEventData class]],
                  @"Data should be PNSubscribeMessageActionEventData instance.");
}

- (void)testMessageActionEventDataShouldBeSubclassOfSubscribeEventData {
    PNSubscribeMessageActionEventData *actionData = [[PNSubscribeMessageActionEventData alloc] init];

    XCTAssertTrue([actionData isKindOfClass:[PNSubscribeEventData class]],
                  @"PNSubscribeMessageActionEventData should be a subclass of PNSubscribeEventData.");
}


#pragma mark - Tests :: PNSubscribeEventData base properties

- (void)testSubscribeEventDataShouldBeSubclassOfPNBaseOperationData {
    PNSubscribeEventData *eventData = [[PNSubscribeEventData alloc] init];

    XCTAssertTrue([eventData isKindOfClass:[PNBaseOperationData class]],
                  @"PNSubscribeEventData should be a subclass of PNBaseOperationData.");
}


#pragma mark - Tests :: Event result types independence

- (void)testDifferentEventResultTypesShouldBeIndependent {
    PNSubscribeMessageEventData *messageData = [[PNSubscribeMessageEventData alloc] init];
    PNSubscribePresenceEventData *presenceData = [[PNSubscribePresenceEventData alloc] init];

    PNMessageResult *messageResult = [PNMessageResult objectWithOperation:PNSubscribeOperation
                                                                 response:messageData];
    PNPresenceEventResult *presenceResult = [PNPresenceEventResult objectWithOperation:PNSubscribeOperation
                                                                              response:presenceData];

    XCTAssertTrue([messageResult.data isKindOfClass:[PNSubscribeMessageEventData class]],
                  @"Message result data should be message event data.");
    XCTAssertTrue([presenceResult.data isKindOfClass:[PNSubscribePresenceEventData class]],
                  @"Presence result data should be presence event data.");
    XCTAssertFalse([messageResult.data isKindOfClass:[PNSubscribePresenceEventData class]],
                   @"Message result data should not be presence event data.");
}


#pragma mark - Tests :: All event result types subclass PNOperationResult

- (void)testAllEventResultTypesShouldSubclassPNOperationResult {
    PNMessageResult *messageResult = [PNMessageResult objectWithOperation:PNSubscribeOperation response:nil];
    PNSignalResult *signalResult = [PNSignalResult objectWithOperation:PNSubscribeOperation response:nil];
    PNPresenceEventResult *presenceResult = [PNPresenceEventResult objectWithOperation:PNSubscribeOperation response:nil];
    PNFileEventResult *fileResult = [PNFileEventResult objectWithOperation:PNSubscribeOperation response:nil];
    PNObjectEventResult *objectResult = [PNObjectEventResult objectWithOperation:PNSubscribeOperation response:nil];
    PNMessageActionResult *actionResult = [PNMessageActionResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertTrue([messageResult isKindOfClass:[PNOperationResult class]],
                  @"PNMessageResult should be PNOperationResult subclass.");
    XCTAssertTrue([signalResult isKindOfClass:[PNOperationResult class]],
                  @"PNSignalResult should be PNOperationResult subclass.");
    XCTAssertTrue([presenceResult isKindOfClass:[PNOperationResult class]],
                  @"PNPresenceEventResult should be PNOperationResult subclass.");
    XCTAssertTrue([fileResult isKindOfClass:[PNOperationResult class]],
                  @"PNFileEventResult should be PNOperationResult subclass.");
    XCTAssertTrue([objectResult isKindOfClass:[PNOperationResult class]],
                  @"PNObjectEventResult should be PNOperationResult subclass.");
    XCTAssertTrue([actionResult isKindOfClass:[PNOperationResult class]],
                  @"PNMessageActionResult should be PNOperationResult subclass.");
}


#pragma mark - Tests :: Event data class inheritance

- (void)testMessageEventDataShouldInheritFromSubscribeEventData {
    XCTAssertTrue([PNSubscribeMessageEventData isSubclassOfClass:[PNSubscribeEventData class]],
                  @"PNSubscribeMessageEventData should be a subclass of PNSubscribeEventData.");
}

- (void)testSignalEventDataShouldInheritFromMessageEventData {
    XCTAssertTrue([PNSubscribeSignalEventData isSubclassOfClass:[PNSubscribeMessageEventData class]],
                  @"PNSubscribeSignalEventData should be a subclass of PNSubscribeMessageEventData.");
}

- (void)testPresenceEventDataShouldInheritFromSubscribeEventData {
    XCTAssertTrue([PNSubscribePresenceEventData isSubclassOfClass:[PNSubscribeEventData class]],
                  @"PNSubscribePresenceEventData should be a subclass of PNSubscribeEventData.");
}

- (void)testFileEventDataShouldInheritFromSubscribeEventData {
    XCTAssertTrue([PNSubscribeFileEventData isSubclassOfClass:[PNSubscribeEventData class]],
                  @"PNSubscribeFileEventData should be a subclass of PNSubscribeEventData.");
}

- (void)testObjectEventDataShouldInheritFromSubscribeEventData {
    XCTAssertTrue([PNSubscribeObjectEventData isSubclassOfClass:[PNSubscribeEventData class]],
                  @"PNSubscribeObjectEventData should be a subclass of PNSubscribeEventData.");
}

- (void)testMessageActionEventDataShouldInheritFromSubscribeEventData {
    XCTAssertTrue([PNSubscribeMessageActionEventData isSubclassOfClass:[PNSubscribeEventData class]],
                  @"PNSubscribeMessageActionEventData should be a subclass of PNSubscribeEventData.");
}


#pragma mark - Tests :: Copy event results

- (void)testItShouldCopyMessageEventResult {
    PNSubscribeMessageEventData *eventData = [[PNSubscribeMessageEventData alloc] init];
    PNMessageResult *result = [PNMessageResult objectWithOperation:PNSubscribeOperation response:eventData];
    PNMessageResult *copy = [result copy];

    XCTAssertNotNil(copy, @"Copied message result should not be nil.");
    XCTAssertEqual(copy.operation, PNSubscribeOperation,
                   @"Copied result should preserve operation.");
    XCTAssertNotNil(copy.data, @"Copied result should preserve data.");
}

- (void)testItShouldCopyPresenceEventResult {
    PNSubscribePresenceEventData *eventData = [[PNSubscribePresenceEventData alloc] init];
    PNPresenceEventResult *result = [PNPresenceEventResult objectWithOperation:PNSubscribeOperation
                                                                      response:eventData];
    PNPresenceEventResult *copy = [result copy];

    XCTAssertNotNil(copy, @"Copied presence result should not be nil.");
    XCTAssertEqual(copy.operation, PNSubscribeOperation,
                   @"Copied result should preserve operation.");
}

- (void)testItShouldCopyFileEventResult {
    PNSubscribeFileEventData *eventData = [[PNSubscribeFileEventData alloc] init];
    PNFileEventResult *result = [PNFileEventResult objectWithOperation:PNSubscribeOperation response:eventData];
    PNFileEventResult *copy = [result copy];

    XCTAssertNotNil(copy, @"Copied file event result should not be nil.");
    XCTAssertEqual(copy.operation, PNSubscribeOperation,
                   @"Copied result should preserve operation.");
}

#pragma mark -


@end
