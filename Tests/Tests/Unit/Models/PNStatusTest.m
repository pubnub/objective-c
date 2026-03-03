#import <XCTest/XCTest.h>
#import <PubNub/PNStatus.h>
#import <PubNub/PNErrorStatus.h>
#import <PubNub/PNAcknowledgmentStatus.h>
#import <PubNub/PNPublishStatus.h>
#import <PubNub/PNSignalStatus.h>
#import <PubNub/PNSubscribeStatus.h>
#import <PubNub/PNStructures.h>
#import "PNStatus+Private.h"
#import "PNErrorStatus+Private.h"
#import "PNOperationResult+Private.h"
#import "PNSubscribeStatus+Private.h"
#import "PNErrorData+Private.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Unit tests for PNStatus, PNErrorStatus, PNAcknowledgmentStatus, and related status model objects.
@interface PNStatusTest : XCTestCase

#pragma mark -

@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNStatusTest


#pragma mark - Tests :: PNOperationResult base

- (void)testItShouldCreateOperationResultWithOperationAndResponse {
    PNOperationResult *result = [PNOperationResult objectWithOperation:PNTimeOperation response:nil];

    XCTAssertEqual(result.operation, PNTimeOperation, @"Operation type should match the provided value.");
}

- (void)testItShouldReturnStringifiedOperationForKnownOperationType {
    PNOperationResult *result = [PNOperationResult objectWithOperation:PNPublishOperation response:nil];

    XCTAssertEqualObjects(result.stringifiedOperation, @"Publish",
                          @"Stringified operation should return 'Publish' for PNPublishOperation.");
}

- (void)testItShouldReturnStringifiedSubscribeOperation {
    PNOperationResult *result = [PNOperationResult objectWithOperation:PNSubscribeOperation response:nil];

    XCTAssertEqualObjects(result.stringifiedOperation, @"Subscribe",
                          @"Stringified operation should return 'Subscribe' for PNSubscribeOperation.");
}

- (void)testItShouldReturnStringifiedTimeOperation {
    PNOperationResult *result = [PNOperationResult objectWithOperation:PNTimeOperation response:nil];

    XCTAssertEqualObjects(result.stringifiedOperation, @"Time",
                          @"Stringified operation should return 'Time' for PNTimeOperation.");
}

- (void)testItShouldCopyOperationResult {
    NSString *responseData = @"test-response";
    PNOperationResult *result = [PNOperationResult objectWithOperation:PNHistoryOperation response:responseData];
    PNOperationResult *copy = [result copy];

    XCTAssertNotNil(copy, @"Copy should not be nil.");
    XCTAssertEqual(copy.operation, PNHistoryOperation, @"Copied object should preserve operation type.");
    XCTAssertEqualObjects(copy.responseData, responseData, @"Copied object should preserve response data.");
}

- (void)testItShouldStoreResponseData {
    NSDictionary *response = @{ @"key": @"value" };
    PNOperationResult *result = [PNOperationResult objectWithOperation:PNTimeOperation response:response];

    XCTAssertEqualObjects(result.responseData, response, @"Response data should match the provided response.");
}

- (void)testItShouldHandleNilResponse {
    PNOperationResult *result = [PNOperationResult objectWithOperation:PNTimeOperation response:nil];

    XCTAssertNil(result.responseData, @"Response data should be nil when nil is provided.");
}


#pragma mark - Tests :: PNStatus base

- (void)testItShouldCreateStatusWithOperationAndCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                            category:PNConnectedCategory
                                            response:nil];

    XCTAssertEqual(status.operation, PNSubscribeOperation, @"Operation type should match.");
    XCTAssertEqual(status.category, PNConnectedCategory, @"Category should match.");
}

- (void)testItShouldNotBeErrorForConnectedCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                            category:PNConnectedCategory
                                            response:nil];

    XCTAssertFalse(status.isError, @"Connected category should not be an error.");
}

- (void)testItShouldNotBeErrorForReconnectedCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                            category:PNReconnectedCategory
                                            response:nil];

    XCTAssertFalse(status.isError, @"Reconnected category should not be an error.");
}

- (void)testItShouldNotBeErrorForDisconnectedCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNUnsubscribeOperation
                                            category:PNDisconnectedCategory
                                            response:nil];

    XCTAssertFalse(status.isError, @"Disconnected category should not be an error.");
}

- (void)testItShouldNotBeErrorForUnexpectedDisconnectCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                            category:PNUnexpectedDisconnectCategory
                                            response:nil];

    XCTAssertFalse(status.isError, @"Unexpected disconnect category should not be an error.");
}

- (void)testItShouldNotBeErrorForCancelledCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                            category:PNCancelledCategory
                                            response:nil];

    XCTAssertFalse(status.isError, @"Cancelled category should not be an error.");
}

- (void)testItShouldNotBeErrorForAcknowledgmentCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNPublishOperation
                                            category:PNAcknowledgmentCategory
                                            response:nil];

    XCTAssertFalse(status.isError, @"Acknowledgment category should not be an error.");
}

- (void)testItShouldNotBeErrorForUnknownCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNPublishOperation
                                            category:PNUnknownCategory
                                            response:nil];

    XCTAssertFalse(status.isError, @"Unknown category should not be an error by default.");
}

- (void)testItShouldBeErrorForAccessDeniedCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNPublishOperation
                                            category:PNAccessDeniedCategory
                                            response:nil];

    XCTAssertTrue(status.isError, @"Access denied category should be an error.");
}

- (void)testItShouldBeErrorForTimeoutCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNPublishOperation
                                            category:PNTimeoutCategory
                                            response:nil];

    XCTAssertTrue(status.isError, @"Timeout category should be an error.");
}

- (void)testItShouldBeErrorForNetworkIssuesCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNPublishOperation
                                            category:PNNetworkIssuesCategory
                                            response:nil];

    XCTAssertTrue(status.isError, @"Network issues category should be an error.");
}

- (void)testItShouldBeErrorForBadRequestCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNPublishOperation
                                            category:PNBadRequestCategory
                                            response:nil];

    XCTAssertTrue(status.isError, @"Bad request category should be an error.");
}

- (void)testItShouldBeErrorForDecryptionErrorCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                            category:PNDecryptionErrorCategory
                                            response:nil];

    XCTAssertTrue(status.isError, @"Decryption error category should be an error.");
}

- (void)testItShouldBeErrorForMalformedResponseCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNHistoryOperation
                                            category:PNMalformedResponseCategory
                                            response:nil];

    XCTAssertTrue(status.isError, @"Malformed response category should be an error.");
}

- (void)testItShouldBeErrorForRequestURITooLongCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                            category:PNRequestURITooLongCategory
                                            response:nil];

    XCTAssertTrue(status.isError, @"Request URI too long category should be an error.");
}

- (void)testItShouldBeErrorForTLSConnectionFailedCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                            category:PNTLSConnectionFailedCategory
                                            response:nil];

    XCTAssertTrue(status.isError, @"TLS connection failed category should be an error.");
}

- (void)testItShouldReturnStringifiedCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                            category:PNConnectedCategory
                                            response:nil];

    XCTAssertEqualObjects(status.stringifiedCategory, @"Connected",
                          @"Stringified category should return 'Connected' for PNConnectedCategory.");
}

- (void)testItShouldReturnStringifiedCategoryForAccessDenied {
    PNStatus *status = [PNStatus objectWithOperation:PNPublishOperation
                                            category:PNAccessDeniedCategory
                                            response:nil];

    XCTAssertEqualObjects(status.stringifiedCategory, @"Access Denied",
                          @"Stringified category should return 'Access Denied'.");
}

- (void)testItShouldReturnStringifiedCategoryForTimeout {
    PNStatus *status = [PNStatus objectWithOperation:PNPublishOperation
                                            category:PNTimeoutCategory
                                            response:nil];

    XCTAssertEqualObjects(status.stringifiedCategory, @"Timeout",
                          @"Stringified category should return 'Timeout'.");
}

- (void)testItShouldUpdateCategory {
    PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                            category:PNConnectedCategory
                                            response:nil];

    XCTAssertFalse(status.isError, @"Should not be error initially.");

    [status updateCategory:PNAccessDeniedCategory];

    XCTAssertEqual(status.category, PNAccessDeniedCategory, @"Category should be updated.");
}

- (void)testItShouldSetErrorToYesWhenCategoryUpdatedToDecryptionError {
    PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                            category:PNAcknowledgmentCategory
                                            response:nil];

    XCTAssertFalse(status.isError, @"Should not be error initially.");

    [status updateCategory:PNDecryptionErrorCategory];

    XCTAssertTrue(status.isError, @"Should be error after updating category to decryption error.");
}

- (void)testItShouldSetErrorToYesWhenCategoryUpdatedToBadRequest {
    PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                            category:PNAcknowledgmentCategory
                                            response:nil];

    [status updateCategory:PNBadRequestCategory];

    XCTAssertTrue(status.isError, @"Should be error after updating category to bad request.");
}

- (void)testItShouldSetErrorToNoWhenCategoryUpdatedToConnected {
    PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                            category:PNAccessDeniedCategory
                                            response:nil];

    XCTAssertTrue(status.isError, @"Should be error initially.");

    [status updateCategory:PNConnectedCategory];

    XCTAssertFalse(status.isError, @"Should not be error after updating category to connected.");
}

- (void)testItShouldCopyStatusWithAllProperties {
    PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                            category:PNConnectedCategory
                                            response:nil];
    status.subscribedChannels = @[@"channel1", @"channel2"];
    status.subscribedChannelGroups = @[@"group1"];
    status.currentTimetoken = @(16000000000000000);
    status.lastTimeToken = @(15000000000000000);
    status.currentTimeTokenRegion = @(1);
    status.lastTimeTokenRegion = @(2);

    PNStatus *copy = [status copy];

    XCTAssertEqual(copy.operation, PNSubscribeOperation, @"Copied status should preserve operation.");
    XCTAssertEqual(copy.category, PNConnectedCategory, @"Copied status should preserve category.");
    XCTAssertFalse(copy.isError, @"Copied status should preserve error flag.");
    XCTAssertEqualObjects(copy.subscribedChannels, (@[@"channel1", @"channel2"]),
                          @"Copied status should preserve subscribed channels.");
    XCTAssertEqualObjects(copy.subscribedChannelGroups, @[@"group1"],
                          @"Copied status should preserve subscribed channel groups.");
    XCTAssertEqualObjects(copy.currentTimetoken, @(16000000000000000),
                          @"Copied status should preserve current timetoken.");
    XCTAssertEqualObjects(copy.lastTimeToken, @(15000000000000000),
                          @"Copied status should preserve last time token.");
    XCTAssertEqualObjects(copy.currentTimeTokenRegion, @(1),
                          @"Copied status should preserve current time token region.");
    XCTAssertEqualObjects(copy.lastTimeTokenRegion, @(2),
                          @"Copied status should preserve last time token region.");
}


#pragma mark - Tests :: PNErrorStatus

- (void)testItShouldCreateErrorStatusObject {
    PNErrorStatus *errorStatus = [PNErrorStatus objectWithOperation:PNPublishOperation
                                                           category:PNAccessDeniedCategory
                                                           response:nil];

    XCTAssertTrue(errorStatus.isError, @"Error status should indicate error.");
    XCTAssertEqual(errorStatus.category, PNAccessDeniedCategory, @"Category should match.");
}

- (void)testItShouldCreateErrorStatusFromErrorObject {
    NSError *error = [NSError errorWithDomain:@"PNTransportErrorDomain"
                                         code:3001  // PNTransportErrorRequestTimeout
                                     userInfo:@{NSLocalizedFailureReasonErrorKey: @"Request timed out"}];
    PNErrorData *errorData = [PNErrorData dataWithError:error];

    PNErrorStatus *errorStatus = [PNErrorStatus objectWithOperation:PNPublishOperation
                                                           category:PNUnknownCategory
                                                           response:errorData];

    XCTAssertNotNil(errorStatus.errorData, @"Error data should be set.");
}

- (void)testItShouldSetAssociatedObjectOnErrorStatus {
    PNErrorStatus *errorStatus = [PNErrorStatus objectWithOperation:PNSubscribeOperation
                                                           category:PNDecryptionErrorCategory
                                                           response:nil];
    NSDictionary *associatedObject = @{ @"original": @"message" };
    errorStatus.associatedObject = associatedObject;

    XCTAssertEqualObjects(errorStatus.associatedObject, associatedObject,
                          @"Associated object should match the assigned value.");
}

- (void)testItShouldCopyErrorStatusWithAssociatedObject {
    PNErrorStatus *errorStatus = [PNErrorStatus objectWithOperation:PNSubscribeOperation
                                                           category:PNDecryptionErrorCategory
                                                           response:nil];
    errorStatus.associatedObject = @{ @"original": @"message" };

    PNErrorStatus *copy = [errorStatus copy];

    XCTAssertEqualObjects(copy.associatedObject, errorStatus.associatedObject,
                          @"Copied error status should preserve associated object.");
}

- (void)testItShouldFallbackToAcknowledgmentCategoryWhenNotErrorAndUnknown {
    PNErrorStatus *errorStatus = [PNErrorStatus objectWithOperation:PNPublishOperation
                                                           category:PNAcknowledgmentCategory
                                                           response:nil];

    XCTAssertEqual(errorStatus.category, PNAcknowledgmentCategory,
                   @"Non-error status with acknowledgment category should stay acknowledgment.");
    XCTAssertFalse(errorStatus.isError, @"Acknowledgment status should not be error.");
}


#pragma mark - Tests :: PNAcknowledgmentStatus

- (void)testItShouldCreateAcknowledgmentStatus {
    PNAcknowledgmentStatus *ackStatus = [PNAcknowledgmentStatus objectWithOperation:PNDeleteMessageOperation
                                                                           category:PNAcknowledgmentCategory
                                                                           response:nil];

    XCTAssertFalse(ackStatus.isError, @"Acknowledgment status should not be error.");
    XCTAssertEqual(ackStatus.category, PNAcknowledgmentCategory,
                   @"Category should be acknowledgment.");
}

- (void)testItShouldBeSubclassOfPNErrorStatus {
    PNAcknowledgmentStatus *ackStatus = [PNAcknowledgmentStatus objectWithOperation:PNDeleteMessageOperation
                                                                           category:PNAcknowledgmentCategory
                                                                           response:nil];

    XCTAssertTrue([ackStatus isKindOfClass:[PNErrorStatus class]],
                  @"PNAcknowledgmentStatus should be a subclass of PNErrorStatus.");
    XCTAssertTrue([ackStatus isKindOfClass:[PNStatus class]],
                  @"PNAcknowledgmentStatus should be a subclass of PNStatus.");
}


#pragma mark - Tests :: PNPublishStatus

- (void)testItShouldCreatePublishStatus {
    PNPublishStatus *publishStatus = [PNPublishStatus objectWithOperation:PNPublishOperation
                                                                category:PNAcknowledgmentCategory
                                                                response:nil];

    XCTAssertEqual(publishStatus.operation, PNPublishOperation, @"Operation should be publish.");
    XCTAssertFalse(publishStatus.isError, @"Successful publish should not be error.");
}

- (void)testItShouldReturnNilDataWhenPublishStatusIsError {
    PNPublishStatus *publishStatus = [PNPublishStatus objectWithOperation:PNPublishOperation
                                                                category:PNAccessDeniedCategory
                                                                response:nil];

    XCTAssertTrue(publishStatus.isError, @"Publish status with access denied should be error.");
    XCTAssertNil(publishStatus.data, @"Data should be nil when status is error.");
}

- (void)testItShouldBeSubclassOfPNAcknowledgmentStatus {
    PNPublishStatus *publishStatus = [PNPublishStatus objectWithOperation:PNPublishOperation
                                                                category:PNAcknowledgmentCategory
                                                                response:nil];

    XCTAssertTrue([publishStatus isKindOfClass:[PNAcknowledgmentStatus class]],
                  @"PNPublishStatus should be a subclass of PNAcknowledgmentStatus.");
}


#pragma mark - Tests :: PNSignalStatus

- (void)testItShouldCreateSignalStatus {
    PNSignalStatus *signalStatus = [PNSignalStatus objectWithOperation:PNSignalOperation
                                                              category:PNAcknowledgmentCategory
                                                              response:nil];

    XCTAssertEqual(signalStatus.operation, PNSignalOperation, @"Operation should be signal.");
    XCTAssertFalse(signalStatus.isError, @"Successful signal should not be error.");
}

- (void)testItShouldReturnNilDataWhenSignalStatusIsError {
    PNSignalStatus *signalStatus = [PNSignalStatus objectWithOperation:PNSignalOperation
                                                              category:PNBadRequestCategory
                                                              response:nil];

    XCTAssertTrue(signalStatus.isError, @"Signal status with bad request should be error.");
    XCTAssertNil(signalStatus.data, @"Data should be nil when status is error.");
}


#pragma mark - Tests :: PNSubscribeStatus

- (void)testItShouldCreateSubscribeStatus {
    PNSubscribeStatus *subStatus = [PNSubscribeStatus objectWithOperation:PNSubscribeOperation
                                                                category:PNConnectedCategory
                                                                response:nil];

    XCTAssertEqual(subStatus.operation, PNSubscribeOperation, @"Operation should be subscribe.");
    XCTAssertFalse(subStatus.isError, @"Connected subscribe status should not be error.");
}

- (void)testItShouldExposeSubscriptionProperties {
    PNSubscribeStatus *subStatus = [PNSubscribeStatus objectWithOperation:PNSubscribeOperation
                                                                category:PNConnectedCategory
                                                                response:nil];
    subStatus.subscribedChannels = @[@"ch1", @"ch2"];
    subStatus.subscribedChannelGroups = @[@"cg1"];
    subStatus.currentTimetoken = @(16500000000000000);
    subStatus.lastTimeToken = @(16400000000000000);

    XCTAssertEqualObjects(subStatus.subscribedChannels, (@[@"ch1", @"ch2"]),
                          @"Subscribed channels should be accessible.");
    XCTAssertEqualObjects(subStatus.subscribedChannelGroups, @[@"cg1"],
                          @"Subscribed channel groups should be accessible.");
    XCTAssertEqualObjects(subStatus.currentTimetoken, @(16500000000000000),
                          @"Current timetoken should be accessible.");
    XCTAssertEqualObjects(subStatus.lastTimeToken, @(16400000000000000),
                          @"Last time token should be accessible.");
}

- (void)testSubscribeStatusShouldBeSubclassOfPNErrorStatus {
    PNSubscribeStatus *subStatus = [PNSubscribeStatus objectWithOperation:PNSubscribeOperation
                                                                category:PNConnectedCategory
                                                                response:nil];

    XCTAssertTrue([subStatus isKindOfClass:[PNErrorStatus class]],
                  @"PNSubscribeStatus should be a subclass of PNErrorStatus.");
}

- (void)testItShouldBeErrorForSubscribeWithAccessDenied {
    PNSubscribeStatus *subStatus = [PNSubscribeStatus objectWithOperation:PNSubscribeOperation
                                                                category:PNAccessDeniedCategory
                                                                response:nil];

    XCTAssertTrue(subStatus.isError, @"Subscribe status with access denied should be error.");
}


#pragma mark - Tests :: Category error flag mapping comprehensive

- (void)testAllNonErrorCategoriesShouldNotSetErrorFlag {
    NSArray<NSNumber *> *nonErrorCategories = @[
        @(PNConnectedCategory),
        @(PNReconnectedCategory),
        @(PNDisconnectedCategory),
        @(PNUnexpectedDisconnectCategory),
        @(PNCancelledCategory),
        @(PNAcknowledgmentCategory),
    ];

    for (NSNumber *categoryNumber in nonErrorCategories) {
        PNStatusCategory category = (PNStatusCategory)categoryNumber.integerValue;
        PNStatus *status = [PNStatus objectWithOperation:PNSubscribeOperation
                                                category:category
                                                response:nil];

        XCTAssertFalse(status.isError, @"Category %@ should not be an error.",
                       status.stringifiedCategory);
    }
}

- (void)testAllErrorCategoriesShouldSetErrorFlag {
    NSArray<NSNumber *> *errorCategories = @[
        @(PNAccessDeniedCategory),
        @(PNTimeoutCategory),
        @(PNNetworkIssuesCategory),
        @(PNRequestMessageCountExceededCategory),
        @(PNBadRequestCategory),
        @(PNRequestURITooLongCategory),
        @(PNMalformedFilterExpressionCategory),
        @(PNMalformedResponseCategory),
        @(PNDecryptionErrorCategory),
        @(PNTLSConnectionFailedCategory),
        @(PNTLSUntrustedCertificateCategory),
        @(PNSendFileErrorCategory),
        @(PNPublishFileMessageErrorCategory),
        @(PNDownloadErrorCategory),
        @(PNResourceNotFoundCategory),
    ];

    for (NSNumber *categoryNumber in errorCategories) {
        PNStatusCategory category = (PNStatusCategory)categoryNumber.integerValue;
        PNStatus *status = [PNStatus objectWithOperation:PNPublishOperation
                                                category:category
                                                response:nil];

        XCTAssertTrue(status.isError, @"Category %@ should be an error.",
                      status.stringifiedCategory);
    }
}


#pragma mark - Tests :: PNStatus inheritance chain

- (void)testStatusShouldBeSubclassOfOperationResult {
    PNStatus *status = [PNStatus objectWithOperation:PNPublishOperation
                                            category:PNAcknowledgmentCategory
                                            response:nil];

    XCTAssertTrue([status isKindOfClass:[PNOperationResult class]],
                  @"PNStatus should be a subclass of PNOperationResult.");
}

- (void)testErrorStatusShouldBeSubclassOfStatus {
    PNErrorStatus *errorStatus = [PNErrorStatus objectWithOperation:PNPublishOperation
                                                           category:PNAccessDeniedCategory
                                                           response:nil];

    XCTAssertTrue([errorStatus isKindOfClass:[PNStatus class]],
                  @"PNErrorStatus should be a subclass of PNStatus.");
}

#pragma mark -


@end
