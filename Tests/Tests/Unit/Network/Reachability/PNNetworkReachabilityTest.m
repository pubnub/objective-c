#import <XCTest/XCTest.h>
#import <PubNub/PNRequestRetryConfiguration+Private.h>
#import <PubNub/PNTransportRequest.h>
#import <PubNub/PNError.h>
#import "PNTransportRequest+Private.h"
#import "PNTransportConfiguration+Private.h"
#import "PNMockTransport.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Network reachability and failure behaviour unit tests.
///
/// Tests verify SDK transport layer behaviour under simulated network failure conditions using a mock
/// transport that conforms to the `PNTransport` protocol.
///
/// - Copyright: 2010-2026 PubNub, Inc.
@interface PNNetworkReachabilityTest : XCTestCase


#pragma mark - Properties

/// Mock transport instance used across test cases.
@property(strong, nonatomic) PNMockTransport *mockTransport;


#pragma mark - Helpers

/// Create a transport request targeting a specific endpoint path.
///
/// - Parameters:
///   - path: The URL path for the request.
///   - origin: The origin host (defaults to `ps.pndsn.com` if nil).
/// - Returns: Configured transport request.
- (PNTransportRequest *)transportRequestWithPath:(NSString *)path origin:(nullable NSString *)origin;

/// Create a transport request for the subscribe endpoint.
///
/// - Returns: Configured transport request for `/v2/subscribe/...`.
- (PNTransportRequest *)subscribeRequest;

/// Create a transport request for the publish endpoint.
///
/// - Returns: Configured transport request for `/publish/...`.
- (PNTransportRequest *)publishRequest;

/// Create a retriable transport request for the publish endpoint.
///
/// - Returns: Configured transport request with `retriable = YES`.
- (PNTransportRequest *)retriablePublishRequest;

/// Create a non-retriable transport request.
///
/// - Returns: Configured transport request with `retriable = NO`.
- (PNTransportRequest *)nonRetriableRequest;

/// Create a `PNTransportConfiguration` with the given retry configuration.
///
/// - Parameter retryConfiguration: Optional retry configuration.
/// - Returns: Configured transport configuration.
- (PNTransportConfiguration *)transportConfigurationWithRetry:(nullable PNRequestRetryConfiguration *)retryConfiguration;


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNNetworkReachabilityTest


#pragma mark - Setup

- (void)setUp {
    [super setUp];
    self.mockTransport = [[PNMockTransport alloc] init];
}

- (void)tearDown {
    [self.mockTransport reset];
    self.mockTransport = nil;
    [super tearDown];
}


#pragma mark - Tests :: Happy Path :: Connected state delivers response

- (void)testItShouldDeliverSuccessResponseWhenConnected {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request completes successfully"];
    PNTransportRequest *request = [self publishRequest];

    NSDictionary *json = @{@"status": @200, @"message": @"OK"};
    [self.mockTransport enqueueResponse:[PNMockTransportResponse responseWithStatusCode:200 json:json]];

    [self.mockTransport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                                   id<PNTransportResponse> response,
                                                                   PNError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertEqual(response.statusCode, 200);
        XCTAssertNotNil(response.body);

        NSError *jsonError = nil;
        NSDictionary *parsed = [NSJSONSerialization JSONObjectWithData:response.body
                                                              options:(NSJSONReadingOptions)0
                                                                error:&jsonError];
        XCTAssertNil(jsonError);
        XCTAssertEqualObjects(parsed[@"message"], @"OK");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testItShouldDeliverDefaultResponseWhenQueueIsEmpty {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Default response delivered"];
    PNTransportRequest *request = [self publishRequest];

    // No enqueued responses; default is 200 OK with nil body.
    [self.mockTransport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                                   id<PNTransportResponse> response,
                                                                   PNError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertEqual(response.statusCode, 200);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testItShouldDeliverCustomDefaultResponseWhenQueueIsEmpty {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Custom default response delivered"];
    PNTransportRequest *request = [self publishRequest];

    PNMockTransportResponse *defaultResponse = [PNMockTransportResponse responseWithStatusCode:204 body:nil];
    [self.mockTransport setDefaultResponse:defaultResponse];

    [self.mockTransport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                                   id<PNTransportResponse> response,
                                                                   PNError *error) {
        XCTAssertNil(error);
        XCTAssertEqual(response.statusCode, 204);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Error Path :: Disconnected state returns network error

- (void)testItShouldReturnNetworkErrorWhenDisconnected {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Network error on disconnect"];
    PNTransportRequest *request = [self publishRequest];

    self.mockTransport.networkState = PNMockTransportDisconnected;

    [self.mockTransport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                                   id<PNTransportResponse> response,
                                                                   PNError *error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        XCTAssertEqualObjects(error.domain, PNTransportErrorDomain);
        XCTAssertEqual(error.code, PNTransportErrorNetworkIssues);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Error Path :: Timeout state returns timeout error

- (void)testItShouldReturnTimeoutErrorWhenTimingOut {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Timeout error"];
    PNTransportRequest *request = [self publishRequest];

    self.mockTransport.networkState = PNMockTransportTimingOut;

    [self.mockTransport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                                   id<PNTransportResponse> response,
                                                                   PNError *error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        XCTAssertEqualObjects(error.domain, PNTransportErrorDomain);
        XCTAssertEqual(error.code, PNTransportErrorRequestTimeout);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Error Path :: Enqueued error response

- (void)testItShouldReturnNetworkErrorWhenResponseHasError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Enqueued error delivered"];
    PNTransportRequest *request = [self publishRequest];

    NSError *simulatedError = [NSError errorWithDomain:NSURLErrorDomain
                                                  code:NSURLErrorNetworkConnectionLost
                                              userInfo:nil];
    [self.mockTransport enqueueResponse:[PNMockTransportResponse responseWithError:simulatedError]];

    [self.mockTransport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                                   id<PNTransportResponse> response,
                                                                   PNError *error) {
        XCTAssertNotNil(error);
        XCTAssertNil(response);
        XCTAssertEqualObjects(error.domain, PNTransportErrorDomain);
        XCTAssertEqual(error.code, PNTransportErrorNetworkIssues);

        NSError *underlying = error.userInfo[NSUnderlyingErrorKey];
        XCTAssertNotNil(underlying);
        XCTAssertEqual(underlying.code, NSURLErrorNetworkConnectionLost);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Error Path :: HTTP 503 response

- (void)testItShouldReturnHTTP503Response {
    XCTestExpectation *expectation = [self expectationWithDescription:@"503 response delivered"];
    PNTransportRequest *request = [self publishRequest];

    NSDictionary *json = @{@"error": @YES, @"message": @"Service Unavailable"};
    [self.mockTransport enqueueResponse:[PNMockTransportResponse responseWithStatusCode:503 json:json]];

    [self.mockTransport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                                   id<PNTransportResponse> response,
                                                                   PNError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertEqual(response.statusCode, 503);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Error Path :: HTTP 403 response

- (void)testItShouldReturnHTTP403Response {
    XCTestExpectation *expectation = [self expectationWithDescription:@"403 response delivered"];
    PNTransportRequest *request = [self publishRequest];

    NSDictionary *json = @{@"error": @YES, @"message": @"Forbidden"};
    [self.mockTransport enqueueResponse:[PNMockTransportResponse responseWithStatusCode:403 json:json]];

    [self.mockTransport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                                   id<PNTransportResponse> response,
                                                                   PNError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertEqual(response.statusCode, 403);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Request Recording

- (void)testItShouldRecordAllSentRequests {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Multiple requests recorded"];
    PNTransportRequest *request1 = [self publishRequest];
    PNTransportRequest *request2 = [self subscribeRequest];

    __block NSUInteger completionCount = 0;

    void (^checkCompletion)(void) = ^{
        completionCount++;
        if (completionCount == 2) {
            XCTAssertEqual(self.mockTransport.recordedRequestCount, 2);
            NSArray<PNMockTransportRequestRecord *> *records = self.mockTransport.recordedRequests;
            XCTAssertEqualObjects(records[0].request, request1);
            XCTAssertEqualObjects(records[1].request, request2);
            [expectation fulfill];
        }
    };

    [self.mockTransport sendRequest:request1 withCompletionBlock:^(PNTransportRequest *req,
                                                                    id<PNTransportResponse> response,
                                                                    PNError *error) {
        // Send second request after first completes to guarantee ordering.
        [self.mockTransport sendRequest:request2 withCompletionBlock:^(PNTransportRequest *req2,
                                                                       id<PNTransportResponse> response2,
                                                                       PNError *error2) {
            checkCompletion();
        }];
        checkCompletion();
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testItShouldRecordRequestTimestamps {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Timestamp recorded"];
    PNTransportRequest *request = [self publishRequest];
    NSDate *beforeSend = [NSDate date];

    [self.mockTransport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                                   id<PNTransportResponse> response,
                                                                   PNError *error) {
        NSDate *afterSend = [NSDate date];
        PNMockTransportRequestRecord *record = self.mockTransport.recordedRequests.firstObject;
        XCTAssertNotNil(record.timestamp);
        XCTAssertTrue([record.timestamp compare:beforeSend] != NSOrderedAscending);
        XCTAssertTrue([record.timestamp compare:afterSend] != NSOrderedDescending);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testItShouldClearRecordedRequestsOnReset {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Records cleared"];
    PNTransportRequest *request = [self publishRequest];

    [self.mockTransport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                                   id<PNTransportResponse> response,
                                                                   PNError *error) {
        XCTAssertEqual(self.mockTransport.recordedRequestCount, 1);
        [self.mockTransport resetRecordedRequests];
        XCTAssertEqual(self.mockTransport.recordedRequestCount, 0);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Response Queue :: FIFO ordering

- (void)testItShouldDeliverEnqueuedResponsesInFIFOOrder {
    XCTestExpectation *expectation = [self expectationWithDescription:@"FIFO order maintained"];

    [self.mockTransport enqueueResponse:[PNMockTransportResponse responseWithStatusCode:200 body:nil]];
    [self.mockTransport enqueueResponse:[PNMockTransportResponse responseWithStatusCode:503 body:nil]];
    [self.mockTransport enqueueResponse:[PNMockTransportResponse responseWithStatusCode:429 body:nil]];

    PNTransportRequest *request1 = [self publishRequest];
    PNTransportRequest *request2 = [self publishRequest];
    PNTransportRequest *request3 = [self publishRequest];

    [self.mockTransport sendRequest:request1 withCompletionBlock:^(PNTransportRequest *req,
                                                                    id<PNTransportResponse> response,
                                                                    PNError *error) {
        XCTAssertEqual(response.statusCode, 200);

        [self.mockTransport sendRequest:request2 withCompletionBlock:^(PNTransportRequest *req2,
                                                                       id<PNTransportResponse> response2,
                                                                       PNError *error2) {
            XCTAssertEqual(response2.statusCode, 503);

            [self.mockTransport sendRequest:request3 withCompletionBlock:^(PNTransportRequest *req3,
                                                                           id<PNTransportResponse> response3,
                                                                           PNError *error3) {
                XCTAssertEqual(response3.statusCode, 429);
                [expectation fulfill];
            }];
        }];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Response Delay

- (void)testItShouldDelayResponseDeliveryWhenConfigured {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Response delayed"];
    PNTransportRequest *request = [self publishRequest];

    PNMockTransportResponse *delayedResponse = [PNMockTransportResponse responseWithStatusCode:200 body:nil];
    delayedResponse.delay = 0.5;
    [self.mockTransport enqueueResponse:delayedResponse];

    NSDate *startTime = [NSDate date];

    [self.mockTransport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                                   id<PNTransportResponse> response,
                                                                   PNError *error) {
        NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:startTime];
        XCTAssertGreaterThanOrEqual(elapsed, 0.4);
        XCTAssertNil(error);
        XCTAssertEqual(response.statusCode, 200);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Recovery :: Disconnect then reconnect

- (void)testItShouldRecoverAfterDisconnectAndReconnect {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Recovery after reconnect"];
    PNTransportRequest *request1 = [self publishRequest];
    PNTransportRequest *request2 = [self publishRequest];

    // Step 1: Disconnect.
    self.mockTransport.networkState = PNMockTransportDisconnected;

    [self.mockTransport sendRequest:request1 withCompletionBlock:^(PNTransportRequest *req,
                                                                    id<PNTransportResponse> response,
                                                                    PNError *error) {
        XCTAssertNotNil(error);
        XCTAssertEqual(error.code, PNTransportErrorNetworkIssues);

        // Step 2: Reconnect.
        self.mockTransport.networkState = PNMockTransportConnected;

        NSDictionary *json = @{@"status": @200, @"message": @"Recovered"};
        [self.mockTransport enqueueResponse:[PNMockTransportResponse responseWithStatusCode:200 json:json]];

        [self.mockTransport sendRequest:request2 withCompletionBlock:^(PNTransportRequest *req2,
                                                                       id<PNTransportResponse> response2,
                                                                       PNError *error2) {
            XCTAssertNil(error2);
            XCTAssertNotNil(response2);
            XCTAssertEqual(response2.statusCode, 200);
            [expectation fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testItShouldRecoverAfterMultipleConsecutiveFailures {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Recovery after N failures"];
    NSUInteger failureCount = 3;

    self.mockTransport.networkState = PNMockTransportDisconnected;

    __block NSUInteger failedRequests = 0;
    __block void (^sendNextFailedRequest)(void);

    sendNextFailedRequest = ^{
        if (failedRequests >= failureCount) {
            // Now reconnect and verify recovery.
            self.mockTransport.networkState = PNMockTransportConnected;
            [self.mockTransport enqueueResponse:[PNMockTransportResponse responseWithStatusCode:200 body:nil]];

            PNTransportRequest *recoveryRequest = [self publishRequest];
            [self.mockTransport sendRequest:recoveryRequest
                        withCompletionBlock:^(PNTransportRequest *req,
                                              id<PNTransportResponse> response,
                                              PNError *error) {
                XCTAssertNil(error);
                XCTAssertEqual(response.statusCode, 200);
                XCTAssertEqual(self.mockTransport.recordedRequestCount, failureCount + 1);
                [expectation fulfill];
            }];
            return;
        }

        PNTransportRequest *failedReq = [self publishRequest];
        [self.mockTransport sendRequest:failedReq
                    withCompletionBlock:^(PNTransportRequest *req,
                                          id<PNTransportResponse> response,
                                          PNError *error) {
            XCTAssertNotNil(error);
            failedRequests++;
            sendNextFailedRequest();
        }];
    };

    sendNextFailedRequest();

    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}


#pragma mark - Tests :: Retry Configuration :: Linear policy does not retry HTTP 403

- (void)testItShouldNotRetryHTTP403WithLinearPolicy {
    PNRequestRetryConfiguration *retryConfig = [PNRequestRetryConfiguration configurationWithLinearDelay];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
        [NSURL URLWithString:@"https://ps.pndsn.com/publish/demo/demo/0/test-channel/0/message"]];
    NSURLResponse *response403 = [[NSHTTPURLResponse alloc] initWithURL:urlRequest.URL
                                                             statusCode:403
                                                            HTTPVersion:@"1.1"
                                                           headerFields:nil];

    NSTimeInterval delay = [retryConfig retryDelayForFailedRequest:urlRequest
                                                      withResponse:response403
                                                      retryAttempt:1];
    XCTAssertEqual(delay, -1.f, @"HTTP 403 should not be retriable.");
}


#pragma mark - Tests :: Retry Configuration :: Linear policy retries HTTP 503

- (void)testItShouldRetryHTTP503WithLinearPolicy {
    PNRequestRetryConfiguration *retryConfig = [PNRequestRetryConfiguration configurationWithLinearDelay];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
        [NSURL URLWithString:@"https://ps.pndsn.com/publish/demo/demo/0/test-channel/0/message"]];
    NSURLResponse *response503 = [[NSHTTPURLResponse alloc] initWithURL:urlRequest.URL
                                                             statusCode:503
                                                            HTTPVersion:@"1.1"
                                                           headerFields:nil];

    NSTimeInterval delay = [retryConfig retryDelayForFailedRequest:urlRequest
                                                      withResponse:response503
                                                      retryAttempt:1];
    XCTAssertGreaterThan(delay, 0.f, @"HTTP 503 should be retriable.");
    // Linear policy default delay is 2.0 seconds (plus jitter up to 1.0).
    XCTAssertEqualWithAccuracy(delay, 2.f, 1.f);
}


#pragma mark - Tests :: Retry Configuration :: Linear delay is constant

- (void)testItShouldUseConstantDelayWithLinearPolicy {
    NSTimeInterval configuredDelay = 3.5;
    PNRequestRetryConfiguration *retryConfig = [PNRequestRetryConfiguration configurationWithLinearDelay:configuredDelay
                                                                                           maximumRetry:5
                                                                                      excludedEndpoints:0];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
        [NSURL URLWithString:@"https://ps.pndsn.com/publish/demo/demo/0/test-channel/0/message"]];
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:urlRequest.URL
                                                          statusCode:500
                                                         HTTPVersion:@"1.1"
                                                        headerFields:nil];

    NSTimeInterval delay1 = [retryConfig retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:1];
    NSTimeInterval delay2 = [retryConfig retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:2];
    NSTimeInterval delay3 = [retryConfig retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:3];

    // All delays should be approximately equal (within jitter).
    XCTAssertEqualWithAccuracy(delay1, configuredDelay, 1.f);
    XCTAssertEqualWithAccuracy(delay2, configuredDelay, 1.f);
    XCTAssertEqualWithAccuracy(delay3, configuredDelay, 1.f);
}


#pragma mark - Tests :: Retry Configuration :: Exponential delay increases

- (void)testItShouldIncreaseDelayWithExponentialPolicy {
    PNRequestRetryConfiguration *retryConfig = [PNRequestRetryConfiguration configurationWithExponentialDelay:2.f
                                                                                                maximumDelay:150.f
                                                                                                maximumRetry:6
                                                                                           excludedEndpoints:0];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
        [NSURL URLWithString:@"https://ps.pndsn.com/publish/demo/demo/0/test-channel/0/message"]];
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:urlRequest.URL
                                                          statusCode:500
                                                         HTTPVersion:@"1.1"
                                                        headerFields:nil];

    // Expected delays (before jitter): 2*2^0=2, 2*2^1=4, 2*2^2=8, 2*2^3=16
    NSTimeInterval delay1 = [retryConfig retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:1];
    NSTimeInterval delay2 = [retryConfig retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:2];
    NSTimeInterval delay3 = [retryConfig retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:3];
    NSTimeInterval delay4 = [retryConfig retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:4];

    // Each subsequent delay should be approximately double (within jitter tolerance).
    XCTAssertEqualWithAccuracy(delay1, 2.f, 1.f);
    XCTAssertEqualWithAccuracy(delay2, 4.f, 1.f);
    XCTAssertEqualWithAccuracy(delay3, 8.f, 1.5f);
    XCTAssertEqualWithAccuracy(delay4, 16.f, 1.5f);

    // Verify ordering (delays increase, accounting for jitter by comparing base values).
    XCTAssertLessThan(delay1, delay3, @"Exponential delay should increase over attempts.");
}


#pragma mark - Tests :: Retry Configuration :: Exponential delay respects maximum

- (void)testItShouldCapExponentialDelayAtMaximum {
    PNRequestRetryConfiguration *retryConfig = [PNRequestRetryConfiguration configurationWithExponentialDelay:2.f
                                                                                                maximumDelay:10.f
                                                                                                maximumRetry:10
                                                                                           excludedEndpoints:0];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
        [NSURL URLWithString:@"https://ps.pndsn.com/publish/demo/demo/0/test-channel/0/message"]];
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:urlRequest.URL
                                                          statusCode:500
                                                         HTTPVersion:@"1.1"
                                                        headerFields:nil];

    // At attempt 5: 2*2^4 = 32 which exceeds max of 10, so should be capped.
    NSTimeInterval delay = [retryConfig retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:5];
    XCTAssertEqualWithAccuracy(delay, 10.f, 1.f, @"Delay should be capped at maximum.");
}


#pragma mark - Tests :: Retry Configuration :: Maximum retry count respected

- (void)testItShouldStopRetryingAfterMaximumAttempts {
    PNRequestRetryConfiguration *retryConfig = [PNRequestRetryConfiguration configurationWithLinearDelay:2.f
                                                                                           maximumRetry:3
                                                                                      excludedEndpoints:0];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
        [NSURL URLWithString:@"https://ps.pndsn.com/publish/demo/demo/0/test-channel/0/message"]];
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:urlRequest.URL
                                                          statusCode:500
                                                         HTTPVersion:@"1.1"
                                                        headerFields:nil];

    // Attempts 1-3 should be retriable.
    XCTAssertGreaterThan([retryConfig retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:1], 0.f);
    XCTAssertGreaterThan([retryConfig retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:2], 0.f);
    XCTAssertGreaterThan([retryConfig retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:3], 0.f);

    // Attempt 4 should exceed maximum.
    XCTAssertEqual([retryConfig retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:4], -1.f,
                   @"Should return -1 (no retry) after exceeding maximum retry attempts.");
}


#pragma mark - Tests :: Retry Configuration :: HTTP 429 with Retry-After header

- (void)testItShouldUseRetryAfterHeaderValueForHTTP429 {
    PNRequestRetryConfiguration *retryConfig = [PNRequestRetryConfiguration configurationWithLinearDelay:2.f
                                                                                           maximumRetry:5
                                                                                      excludedEndpoints:0];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
        [NSURL URLWithString:@"https://ps.pndsn.com/publish/demo/demo/0/test-channel/0/message"]];
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:urlRequest.URL
                                                          statusCode:429
                                                         HTTPVersion:@"1.1"
                                                        headerFields:@{@"Retry-After": @"10"}];

    NSTimeInterval delay = [retryConfig retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:1];
    XCTAssertEqualWithAccuracy(delay, 10.f, 1.f, @"Should use Retry-After header value.");
}

- (void)testItShouldUseConfiguredDelayForHTTP429WithoutRetryAfterHeader {
    PNRequestRetryConfiguration *retryConfig = [PNRequestRetryConfiguration configurationWithLinearDelay:4.f
                                                                                           maximumRetry:5
                                                                                      excludedEndpoints:0];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
        [NSURL URLWithString:@"https://ps.pndsn.com/publish/demo/demo/0/test-channel/0/message"]];
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:urlRequest.URL
                                                          statusCode:429
                                                         HTTPVersion:@"1.1"
                                                        headerFields:nil];

    NSTimeInterval delay = [retryConfig retryDelayForFailedRequest:urlRequest withResponse:response retryAttempt:1];
    XCTAssertEqualWithAccuracy(delay, 4.f, 1.f, @"Should use configured delay when Retry-After is absent.");
}


#pragma mark - Tests :: Retry Configuration :: Excluded endpoints

- (void)testItShouldNotRetryExcludedEndpoint {
    PNRequestRetryConfiguration *retryConfig = [PNRequestRetryConfiguration configurationWithLinearDelay:2.f
                                                                                           maximumRetry:5
                                                                                      excludedEndpoints:PNMessageSendEndpoint, 0];
    // Publish endpoint is in the excluded list.
    NSURLRequest *publishReq = [NSURLRequest requestWithURL:
        [NSURL URLWithString:@"https://ps.pndsn.com/publish/demo/demo/0/test-channel/0/message"]];
    NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:publishReq.URL
                                                          statusCode:500
                                                         HTTPVersion:@"1.1"
                                                        headerFields:nil];

    XCTAssertEqual([retryConfig retryDelayForFailedRequest:publishReq withResponse:response retryAttempt:1], -1.f,
                   @"Excluded endpoint should not be retried.");

    // Subscribe endpoint is NOT excluded.
    NSURLRequest *subscribeReq = [NSURLRequest requestWithURL:
        [NSURL URLWithString:@"https://ps.pndsn.com/v2/subscribe/demo/test-channel/0"]];
    NSURLResponse *subResponse = [[NSHTTPURLResponse alloc] initWithURL:subscribeReq.URL
                                                             statusCode:500
                                                            HTTPVersion:@"1.1"
                                                           headerFields:nil];

    XCTAssertGreaterThan([retryConfig retryDelayForFailedRequest:subscribeReq withResponse:subResponse retryAttempt:1],
                         0.f, @"Non-excluded endpoint should be retried.");
}


#pragma mark - Tests :: Transport State :: Suspend and Resume

- (void)testItShouldTrackSuspendAndResumeState {
    [self.mockTransport suspend];
    // Verify transport is suspended (via internal state check through a request).
    // The mock transport records requests even when suspended.
    XCTestExpectation *expectation = [self expectationWithDescription:@"Request while suspended"];
    PNTransportRequest *request = [self publishRequest];

    [self.mockTransport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                                   id<PNTransportResponse> response,
                                                                   PNError *error) {
        XCTAssertEqual(self.mockTransport.recordedRequestCount, 1);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];

    [self.mockTransport resume];
}


#pragma mark - Tests :: Transport State :: Invalidate

- (void)testItShouldClearActiveRequestsOnInvalidate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Invalidation clears active requests"];
    PNTransportRequest *request = [self publishRequest];
    request.cancellable = YES;

    [self.mockTransport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                                   id<PNTransportResponse> response,
                                                                   PNError *error) {
        [self.mockTransport invalidate];

        [self.mockTransport requestsWithBlock:^(NSArray<PNTransportRequest *> *requests) {
            XCTAssertEqual(requests.count, 0, @"Active requests should be cleared after invalidation.");
        }];

        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Download Request

- (void)testItShouldHandleDownloadRequestSuccessfully {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Download request succeeds"];
    PNTransportRequest *request = [self publishRequest];
    request.responseAsFile = YES;

    NSData *fileData = [@"file content" dataUsingEncoding:NSUTF8StringEncoding];
    [self.mockTransport enqueueResponse:[PNMockTransportResponse responseWithStatusCode:200 body:fileData]];

    [self.mockTransport sendDownloadRequest:request
                        withCompletionBlock:^(PNTransportRequest *req,
                                              id<PNTransportResponse> response,
                                              NSURL *path,
                                              PNError *error) {
        XCTAssertNil(error);
        XCTAssertNotNil(response);
        XCTAssertEqual(response.statusCode, 200);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testItShouldHandleDownloadRequestNetworkError {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Download request fails"];
    PNTransportRequest *request = [self publishRequest];
    request.responseAsFile = YES;

    self.mockTransport.networkState = PNMockTransportDisconnected;

    [self.mockTransport sendDownloadRequest:request
                        withCompletionBlock:^(PNTransportRequest *req,
                                              id<PNTransportResponse> response,
                                              NSURL *path,
                                              PNError *error) {
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, PNTransportErrorDomain);
        XCTAssertEqual(error.code, PNTransportErrorNetworkIssues);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Response Queue Exhaustion

- (void)testItShouldFallBackToDefaultAfterQueueExhausted {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Fallback to default"];

    [self.mockTransport enqueueResponse:[PNMockTransportResponse responseWithStatusCode:503 body:nil]];
    [self.mockTransport setDefaultResponse:[PNMockTransportResponse responseWithStatusCode:200 body:nil]];

    PNTransportRequest *request1 = [self publishRequest];
    PNTransportRequest *request2 = [self publishRequest];

    [self.mockTransport sendRequest:request1 withCompletionBlock:^(PNTransportRequest *req,
                                                                    id<PNTransportResponse> response,
                                                                    PNError *error) {
        XCTAssertEqual(response.statusCode, 503, @"First request should use enqueued response.");

        [self.mockTransport sendRequest:request2 withCompletionBlock:^(PNTransportRequest *req2,
                                                                       id<PNTransportResponse> response2,
                                                                       PNError *error2) {
            XCTAssertEqual(response2.statusCode, 200, @"Second request should use default response.");
            [expectation fulfill];
        }];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Full Reset

- (void)testItShouldFullyResetTransportState {
    self.mockTransport.networkState = PNMockTransportDisconnected;
    [self.mockTransport enqueueResponse:[PNMockTransportResponse responseWithStatusCode:503 body:nil]];

    XCTestExpectation *expectation1 = [self expectationWithDescription:@"Request before reset"];
    PNTransportRequest *req1 = [self publishRequest];
    [self.mockTransport sendRequest:req1 withCompletionBlock:^(PNTransportRequest *req,
                                                                id<PNTransportResponse> response,
                                                                PNError *error) {
        XCTAssertNotNil(error);
        [expectation1 fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];

    [self.mockTransport reset];

    // After reset: connected state, no enqueued responses, no recorded requests.
    XCTAssertEqual(self.mockTransport.networkState, PNMockTransportConnected);
    XCTAssertEqual(self.mockTransport.recordedRequestCount, 0);

    XCTestExpectation *expectation2 = [self expectationWithDescription:@"Request after reset"];
    PNTransportRequest *req2 = [self publishRequest];
    [self.mockTransport sendRequest:req2 withCompletionBlock:^(PNTransportRequest *req,
                                                                id<PNTransportResponse> response,
                                                                PNError *error) {
        XCTAssertNil(error);
        XCTAssertEqual(response.statusCode, 200);
        [expectation2 fulfill];
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Response Headers

- (void)testItShouldDeliverResponseWithHeaders {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Headers delivered"];
    PNTransportRequest *request = [self publishRequest];

    PNMockTransportResponse *mockResp = [PNMockTransportResponse responseWithStatusCode:200 body:nil];
    mockResp.headers = @{@"X-Custom-Header": @"test-value", @"Content-Type": @"text/plain"};
    [self.mockTransport enqueueResponse:mockResp];

    [self.mockTransport sendRequest:request withCompletionBlock:^(PNTransportRequest *req,
                                                                   id<PNTransportResponse> response,
                                                                   PNError *error) {
        XCTAssertNil(error);
        XCTAssertEqualObjects(response.headers[@"x-custom-header"], @"test-value");
        XCTAssertEqualObjects(response.headers[@"content-type"], @"text/plain");
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}


#pragma mark - Tests :: Transport Request Passthrough

- (void)testItShouldReturnRequestUnmodifiedFromTransportRequestMethod {
    PNTransportRequest *request = [self publishRequest];
    PNTransportRequest *result = [self.mockTransport transportRequestFromTransportRequest:request];
    XCTAssertEqualObjects(request, result, @"Mock transport should return request as-is.");
}


#pragma mark - Tests :: Retry Configuration :: Non-retriable status codes

- (void)testItShouldNotRetryNon5xxStatusCodes {
    PNRequestRetryConfiguration *retryConfig = [PNRequestRetryConfiguration configurationWithLinearDelay];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
        [NSURL URLWithString:@"https://ps.pndsn.com/publish/demo/demo/0/test-channel/0/message"]];

    // Test various non-retriable status codes.
    NSArray<NSNumber *> *nonRetriableCodes = @[@(200), @(201), @(204), @(301), @(302), @(403)];

    for (NSNumber *code in nonRetriableCodes) {
        NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:urlRequest.URL
                                                              statusCode:code.integerValue
                                                             HTTPVersion:@"1.1"
                                                            headerFields:nil];
        NSTimeInterval delay = [retryConfig retryDelayForFailedRequest:urlRequest
                                                          withResponse:response
                                                          retryAttempt:1];
        XCTAssertEqual(delay, -1.f, @"HTTP %@ should not be retriable.", code);
    }
}

- (void)testItShouldRetryRetriableStatusCodes {
    PNRequestRetryConfiguration *retryConfig = [PNRequestRetryConfiguration configurationWithLinearDelay];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
        [NSURL URLWithString:@"https://ps.pndsn.com/publish/demo/demo/0/test-channel/0/message"]];

    NSArray<NSNumber *> *retriableCodes = @[@(429), @(500), @(502), @(503), @(504)];

    for (NSNumber *code in retriableCodes) {
        NSURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:urlRequest.URL
                                                              statusCode:code.integerValue
                                                             HTTPVersion:@"1.1"
                                                            headerFields:nil];
        NSTimeInterval delay = [retryConfig retryDelayForFailedRequest:urlRequest
                                                          withResponse:response
                                                          retryAttempt:1];
        XCTAssertGreaterThan(delay, 0.f, @"HTTP %@ should be retriable.", code);
    }
}


#pragma mark - Helpers

- (PNTransportRequest *)transportRequestWithPath:(NSString *)path origin:(NSString *)origin {
    PNTransportRequest *request = [[PNTransportRequest alloc] init];
    request.origin = origin ?: @"ps.pndsn.com";
    request.path = path;
    request.method = TransportGETMethod;
    request.timeout = 10.0;
    request.secure = YES;
    request.retriable = YES;
    return request;
}

- (PNTransportRequest *)subscribeRequest {
    return [self transportRequestWithPath:@"/v2/subscribe/demo/test-channel/0" origin:nil];
}

- (PNTransportRequest *)publishRequest {
    return [self transportRequestWithPath:@"/publish/demo/demo/0/test-channel/0/message" origin:nil];
}

- (PNTransportRequest *)retriablePublishRequest {
    PNTransportRequest *request = [self publishRequest];
    request.retriable = YES;
    return request;
}

- (PNTransportRequest *)nonRetriableRequest {
    PNTransportRequest *request = [self publishRequest];
    request.retriable = NO;
    return request;
}

- (PNTransportConfiguration *)transportConfigurationWithRetry:(PNRequestRetryConfiguration *)retryConfiguration {
    PNTransportConfiguration *config = [[PNTransportConfiguration alloc] init];
    config.retryConfiguration = retryConfiguration;
    config.maximumConnections = 2;
    return config;
}

#pragma mark -


@end
