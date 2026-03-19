#import <PubNub/PNRequestRetryConfiguration+Private.h>
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNConfiguration.h>
#import "PNPresenceHeartbeatRequest.h"
#import "PNFileUploadRequest.h"
#import "PNBaseRequest+Private.h"
#import "PNRecordableTestCase.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Request automatic retry configuration unit tests.
///
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNRequestRetryConfigurationTest : PNRecordableTestCase


#pragma mark - Helpers

/// Compute expected exponential delay.
///
/// - Parameters:
///   - baseInterval: Base interval, which will be used to calculate the next interval based on the number of retry
///     attempts.
///   - maxInterval: Maximum allowed computed interval that should be used between retry attempts.
///   - retryAttempt: Current retry attempt.
/// - Returns: Exponential delay which depends from current retry attempt.
- (NSTimeInterval)exponentialDelayWithBaseInterval:(NSTimeInterval)baseInterval
                                      maxInterval:(NSTimeInterval)maxInterval
                                      retryAttempt:(NSUInteger)retryAttempt;

/// Create request for specific endpoint group.
///
/// - Parameter endpoint: One of `PNEndpoint` enum field which suggest tested API group.
/// - Returns: Initialized request for specified endpoint group.
- (NSURLRequest *)requestForEndpoint:(PNEndpoint)endpoint;

- (NSURLResponse *)failedURLResponseForRequest:(NSURLRequest *)request
                                withStatusCode:(NSUInteger)statusCode
                                       headers:(nullable NSDictionary<NSString *, NSString *> *)headers;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNRequestRetryConfigurationTest


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Linear policy

- (void)testItShouldOverrideWrongMinimumDelayAndRetryAttemptsWithLinearPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithLinearDelay:.5f
                                                                                              maximumRetry:12
                                                                                         excludedEndpoints:0];
    NSURLRequest *request = [self requestForEndpoint:PNDevicePushNotificationsEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:500 headers:nil];

    XCTAssertEqualWithAccuracy([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:10], 2.f, 1.f);
    XCTAssertEqual([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:11], -1.f);
}

- (void)testItShouldProvideConfiguredDelayWithLinearPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithLinearDelay:4.5f
                                                                                              maximumRetry:5
                                                                                         excludedEndpoints:0];
    NSURLRequest *request = [self requestForEndpoint:PNMessageSendEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:500 headers:nil];

    XCTAssertEqualWithAccuracy([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:3], 4.5f, 1.f);
    XCTAssertEqualWithAccuracy([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:4], 4.5f, 1.f);
}

- (void)testItShouldProvideConfiguredDelayWhenReceivedResponseWith429StatusCodeAndRetryAfterIsMissingWithLinearPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithLinearDelay:4.5f
                                                                                              maximumRetry:5
                                                                                         excludedEndpoints:0];
    NSURLRequest *request = [self requestForEndpoint:PNMessageSendEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:429 headers:nil];

    XCTAssertEqualWithAccuracy([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:3], 4.5f, 1.f);
}

- (void)testItShouldProvideRetryAfterValueDelayWhenReceivedResponseWith429StatusCodeAndRetryAfterIsPresentWithLinearPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithLinearDelay:4.5f
                                                                                              maximumRetry:5
                                                                                         excludedEndpoints:0];
    NSURLRequest *request = [self requestForEndpoint:PNMessageSendEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:429 headers:@{@"Retry-After": @"16"}];

    XCTAssertEqualWithAccuracy([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:3], 16.f, 1.f);
}

- (void)testItShouldNotProvideConfiguredDelayWhenExceededMaximumRetryAttemptsWithLinearPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithLinearDelay:4.5f
                                                                                              maximumRetry:5
                                                                                         excludedEndpoints:0];
    NSURLRequest *request = [self requestForEndpoint:PNMessageStorageEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:510 headers:nil];

    XCTAssertEqual([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:6], -1.f);
}

- (void)testItShouldNotProvideConfiguredDelayWhenReceivedResponseWith4XXStatusCodeWithLinearPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithLinearDelay:4.5f
                                                                                              maximumRetry:5
                                                                                         excludedEndpoints:0];
    NSURLRequest *request = [self requestForEndpoint:PNSubscribeEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:403 headers:nil];

    XCTAssertEqual([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:2], -1.f);
}

- (void)testItShouldNotProvideConfiguredDelayWhenTargetEndpointExcludedWithLinearPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithLinearDelay:4.5f
                                                                                              maximumRetry:5
                                                                                         excludedEndpoints:PNAppContextEndpoint, 0];
    NSURLRequest *request = [self requestForEndpoint:PNAppContextEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:403 headers:nil];

    XCTAssertEqual([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:2], -1.f);
}

- (void)testItShouldNotRetryNonSubscribeEndpointsWithDefaultConfiguration {
    PNConfiguration *clientConfiguration = [PNConfiguration configurationWithPublishKey:@"demo"
                                                                           subscribeKey:@"demo"
                                                                                 userID:@"test-user"];
    PNConfiguration *copiedConfiguration = [clientConfiguration copy];
    PNRequestRetryConfiguration *retryConfig = copiedConfiguration.requestRetry;

    XCTAssertNotNil(retryConfig);

    NSURLRequest *publishRequest = [self requestForEndpoint:PNMessageSendEndpoint];
    NSURLResponse *publishResponse = [self failedURLResponseForRequest:publishRequest withStatusCode:500 headers:nil];
    XCTAssertEqual([retryConfig retryDelayForFailedRequest:publishRequest withResponse:publishResponse retryAttempt:1], -1.f,
                   @"Publish should not be retried with default configuration");

    NSURLRequest *presenceRequest = [self requestForEndpoint:PNPresenceEndpoint];
    NSURLResponse *presenceResponse = [self failedURLResponseForRequest:presenceRequest withStatusCode:500 headers:nil];
    XCTAssertEqual([retryConfig retryDelayForFailedRequest:presenceRequest withResponse:presenceResponse retryAttempt:1], -1.f,
                   @"Presence should not be retried with default configuration");

    NSURLRequest *historyRequest = [self requestForEndpoint:PNMessageStorageEndpoint];
    NSURLResponse *historyResponse = [self failedURLResponseForRequest:historyRequest withStatusCode:500 headers:nil];
    XCTAssertEqual([retryConfig retryDelayForFailedRequest:historyRequest withResponse:historyResponse retryAttempt:1], -1.f,
                   @"Message storage should not be retried with default configuration");

    NSURLRequest *filesRequest = [self requestForEndpoint:PNFilesEndpoint];
    NSURLResponse *filesResponse = [self failedURLResponseForRequest:filesRequest withStatusCode:500 headers:nil];
    XCTAssertEqual([retryConfig retryDelayForFailedRequest:filesRequest withResponse:filesResponse retryAttempt:1], -1.f,
                   @"Files should not be retried with default configuration");

    NSURLRequest *appContextRequest = [self requestForEndpoint:PNAppContextEndpoint];
    NSURLResponse *appContextResponse = [self failedURLResponseForRequest:appContextRequest withStatusCode:500 headers:nil];
    XCTAssertEqual([retryConfig retryDelayForFailedRequest:appContextRequest withResponse:appContextResponse retryAttempt:1], -1.f,
                   @"App Context should not be retried with default configuration");
}

- (void)testItShouldPreserveExcludedEndpointsAfterCopyWithLinearPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithLinearDelay:4.5f
                                                                                              maximumRetry:5
                                                                                         excludedEndpoints:PNAppContextEndpoint, PNMessageSendEndpoint, 0];
    PNRequestRetryConfiguration *configurationCopy = [configuration copy];

    NSURLRequest *appContextRequest = [self requestForEndpoint:PNAppContextEndpoint];
    NSURLResponse *appContextResponse = [self failedURLResponseForRequest:appContextRequest withStatusCode:500 headers:nil];
    XCTAssertEqual([configurationCopy retryDelayForFailedRequest:appContextRequest withResponse:appContextResponse retryAttempt:1], -1.f);

    NSURLRequest *publishRequest = [self requestForEndpoint:PNMessageSendEndpoint];
    NSURLResponse *publishResponse = [self failedURLResponseForRequest:publishRequest withStatusCode:500 headers:nil];
    XCTAssertEqual([configurationCopy retryDelayForFailedRequest:publishRequest withResponse:publishResponse retryAttempt:1], -1.f);

    NSURLRequest *presenceRequest = [self requestForEndpoint:PNPresenceEndpoint];
    NSURLResponse *presenceResponse = [self failedURLResponseForRequest:presenceRequest withStatusCode:500 headers:nil];
    XCTAssertEqualWithAccuracy([configurationCopy retryDelayForFailedRequest:presenceRequest withResponse:presenceResponse retryAttempt:1], 4.5f, 1.f);
}


#pragma mark - Tests :: Exponential policy

- (void)testItShouldOverrideWrongMinimumDelayAndRetryAttemptsWithExponentialPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithExponentialDelay:.5f 
                                                                                                   maximumDelay:10.f
                                                                                                   maximumRetry:12
                                                                                              excludedEndpoints:0];
    NSTimeInterval expectedDelay = [self exponentialDelayWithBaseInterval:2.f maxInterval:10.f retryAttempt:2];
    NSURLRequest *request = [self requestForEndpoint:PNDevicePushNotificationsEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:500 headers:nil];

    XCTAssertEqualWithAccuracy([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:2], expectedDelay, 1.f);
    XCTAssertEqual([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:11], -1.f);
}

- (void)testItShouldProvideCalculatedDelayWithExponentialPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithExponentialDelay:4.5f
                                                                                                   maximumDelay:20.f
                                                                                                   maximumRetry:5
                                                                                              excludedEndpoints:0];
    NSTimeInterval expectedDelay1 = [self exponentialDelayWithBaseInterval:4.5f maxInterval:20.f retryAttempt:1];
    NSTimeInterval expectedDelay2 = [self exponentialDelayWithBaseInterval:4.5f maxInterval:20.f retryAttempt:2];
    NSURLRequest *request = [self requestForEndpoint:PNMessageSendEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:500 headers:nil];

    XCTAssertNotEqualWithAccuracy(expectedDelay1, expectedDelay2, 1.f);
    XCTAssertEqualWithAccuracy([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:1], expectedDelay1, 1.f);
    XCTAssertEqualWithAccuracy([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:2], expectedDelay2, 1.f);
}

- (void)testItShouldProvideConfiguredMaximumDelayWhenCalculatedDelayIsHigherThanConfiguredMaximumWithExponentialPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithExponentialDelay:4.5f
                                                                                                   maximumDelay:20.f
                                                                                                   maximumRetry:5
                                                                                              excludedEndpoints:0];
    NSURLRequest *request = [self requestForEndpoint:PNMessageSendEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:500 headers:nil];

    XCTAssertEqualWithAccuracy([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:4], 20.f, 1.f);
}

- (void)testItShouldProvideCalculatedDelayWhenReceivedResponseWith429StatusCodeAndRetryAfterIsMissingWithExponentialPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithExponentialDelay:4.5f
                                                                                                   maximumDelay:20.f
                                                                                                   maximumRetry:5
                                                                                              excludedEndpoints:0];
    NSTimeInterval expectedDelay = [self exponentialDelayWithBaseInterval:4.5f maxInterval:20.f retryAttempt:2];
    NSURLRequest *request = [self requestForEndpoint:PNMessageSendEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:429 headers:nil];

    XCTAssertEqualWithAccuracy([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:2], expectedDelay, 1.f);
}

- (void)testItShouldProvideRetryAfterValueDelayWhenReceivedResponseWith429StatusCodeAndRetryAfterIsPresentWithExponentialPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithExponentialDelay:4.5f 
                                                                                                   maximumDelay:20.f
                                                                                                   maximumRetry:5
                                                                                              excludedEndpoints:0];
    NSURLRequest *request = [self requestForEndpoint:PNMessageSendEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:429 headers:@{@"Retry-After": @"16"}];

    XCTAssertEqualWithAccuracy([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:1], 16.f, 1.f);
}

- (void)testItShouldNotProvideCalculatedDelayWhenExceededMaximumRetryAttemptsWithExponentialPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithExponentialDelay:4.5f
                                                                                                   maximumDelay:20.f
                                                                                                   maximumRetry:5
                                                                                              excludedEndpoints:0];
    NSURLRequest *request = [self requestForEndpoint:PNMessageStorageEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:510 headers:nil];

    XCTAssertEqual([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:6], -1.f);
}

- (void)testItShouldNotProvideCalculatedDelayWhenReceivedResponseWith4XXStatusCodeWithExponentialPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithExponentialDelay:4.5f
                                                                                                   maximumDelay:20.f
                                                                                                   maximumRetry:5
                                                                                              excludedEndpoints:0];
    NSURLRequest *request = [self requestForEndpoint:PNSubscribeEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:403 headers:nil];

    XCTAssertEqual([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:2], -1.f);
}

- (void)testItShouldNotProvideCalculatedDelayWhenTargetEndpointExcludedWithExponentialPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithExponentialDelay:4.5f
                                                                                                   maximumDelay:20.f
                                                                                                   maximumRetry:5
                                                                                              excludedEndpoints:PNAppContextEndpoint, 0];
    NSURLRequest *request = [self requestForEndpoint:PNAppContextEndpoint];
    NSURLResponse *response = [self failedURLResponseForRequest:request withStatusCode:403 headers:nil];

    XCTAssertEqual([configuration retryDelayForFailedRequest:request withResponse:response retryAttempt:2], -1.f);
}

- (void)testSubscribeRequestShouldBeRetriableWithDefaultConfiguration {
    PNConfiguration *clientConfiguration = [PNConfiguration configurationWithPublishKey:@"demo"
                                                                           subscribeKey:@"demo"
                                                                                 userID:@"test-user"];
    PNConfiguration *copiedConfiguration = [clientConfiguration copy];
    PNRequestRetryConfiguration *retryConfig = copiedConfiguration.requestRetry;

    XCTAssertNotNil(retryConfig);

    NSURLRequest *subscribeRequest = [self requestForEndpoint:PNSubscribeEndpoint];
    NSURLResponse *subscribeResponse = [self failedURLResponseForRequest:subscribeRequest withStatusCode:500 headers:nil];
    NSTimeInterval delay = [retryConfig retryDelayForFailedRequest:subscribeRequest withResponse:subscribeResponse retryAttempt:1];

    XCTAssertGreaterThan(delay, 0,
                         @"Subscribe should be retried with default configuration for 500 errors");
}

- (void)testHeartbeatRequestShouldNotBeRetriable {
    PNPresenceHeartbeatRequest *heartbeatRequest = [PNPresenceHeartbeatRequest requestWithHeartbeat:300
                                                                                          channels:@[@"test-channel"]
                                                                                     channelGroups:nil];
    [heartbeatRequest setupWithClientConfiguration:self.client.configuration];
    PNTransportRequest *transportRequest = heartbeatRequest.request;

    XCTAssertFalse(transportRequest.retriable,
                   @"Heartbeat request should not be retriable because it has its own timer-based retry loop");
}

- (void)testFileUploadRequestShouldNotBeRetriable {
    NSURL *uploadURL = [NSURL URLWithString:@"https://s3.amazonaws.com/bucket/test-file"];
    PNFileUploadRequest *uploadRequest = [PNFileUploadRequest requestWithURL:uploadURL
                                                                 httpMethod:@"POST"
                                                                   formData:@[]];
    [uploadRequest setupWithClientConfiguration:self.client.configuration];
    PNTransportRequest *transportRequest = uploadRequest.request;

    XCTAssertFalse(transportRequest.retriable,
                   @"File upload request should not be retriable because body streams cannot be rewound");
}

- (void)testItShouldPreserveExcludedEndpointsAfterCopyWithExponentialPolicy {
    PNRequestRetryConfiguration *configuration = [PNRequestRetryConfiguration configurationWithExponentialDelay:4.5f
                                                                                                   maximumDelay:20.f
                                                                                                   maximumRetry:5
                                                                                              excludedEndpoints:PNAppContextEndpoint, PNMessageSendEndpoint, 0];
    PNRequestRetryConfiguration *configurationCopy = [configuration copy];

    NSURLRequest *appContextRequest = [self requestForEndpoint:PNAppContextEndpoint];
    NSURLResponse *appContextResponse = [self failedURLResponseForRequest:appContextRequest withStatusCode:500 headers:nil];
    XCTAssertEqual([configurationCopy retryDelayForFailedRequest:appContextRequest withResponse:appContextResponse retryAttempt:1], -1.f);

    NSURLRequest *publishRequest = [self requestForEndpoint:PNMessageSendEndpoint];
    NSURLResponse *publishResponse = [self failedURLResponseForRequest:publishRequest withStatusCode:500 headers:nil];
    XCTAssertEqual([configurationCopy retryDelayForFailedRequest:publishRequest withResponse:publishResponse retryAttempt:1], -1.f);

    NSTimeInterval expectedDelay = [self exponentialDelayWithBaseInterval:4.5f maxInterval:20.f retryAttempt:1];
    NSURLRequest *presenceRequest = [self requestForEndpoint:PNPresenceEndpoint];
    NSURLResponse *presenceResponse = [self failedURLResponseForRequest:presenceRequest withStatusCode:500 headers:nil];
    XCTAssertEqualWithAccuracy([configurationCopy retryDelayForFailedRequest:presenceRequest withResponse:presenceResponse retryAttempt:1], expectedDelay, 1.f);
}


#pragma mark - Helpers

- (NSTimeInterval)exponentialDelayWithBaseInterval:(NSTimeInterval)baseInterval
                                      maxInterval:(NSTimeInterval)maxInterval
                                      retryAttempt:(NSUInteger)retryAttempt {
    return MIN(baseInterval * pow(2, retryAttempt - 1), maxInterval);
}

- (NSURLRequest *)requestForEndpoint:(PNEndpoint)endpoint {
    NSURL *requestURL = nil;

    if (endpoint == PNMessageSendEndpoint) {
        requestURL = [NSURL URLWithString:@"https://ps.pndsn.com/publish/demo/demo/0/test-channel/0/2010"];
    } else if (endpoint == PNSubscribeEndpoint) {
        requestURL = [NSURL URLWithString:@"https://ps.pndsn.com/v2/subscribe/demo/test-channel/0"];
    } else if (endpoint == PNPresenceEndpoint) {
        requestURL = [NSURL URLWithString:@"https://ps.pndsn.com/v2/presence/sub-key/demo/channel/test-channel"];
    } else if (endpoint == PNFilesEndpoint) {
        requestURL = [NSURL URLWithString:@"https://ps.pndsn.com/v1/files/demo/channels/test-channel/files"];
    } else if (endpoint == PNMessageStorageEndpoint) {
        requestURL = [NSURL URLWithString:@"https://ps.pndsn.com/v3/history-with-actions/sub-key/demo/channel/test-channel"];
    } else if (endpoint == PNChannelGroupsEndpoint) {
        requestURL = [NSURL URLWithString:@"https://ps.pndsn.com/v1/channel-registration/sub-key/demo/channel-group"];
    } else if (endpoint == PNDevicePushNotificationsEndpoint) {
        requestURL = [NSURL URLWithString:@"https://ps.pndsn.com/v2/push/sub-key/demo/devices-apns2/test-device-token"];
    } else if (endpoint == PNAppContextEndpoint) {
        requestURL = [NSURL URLWithString:@"https://ps.pndsn.com/v2/objects/demo/uuids/test-uuid/channels"];
    } else {
        requestURL = [NSURL URLWithString:@"https://ps.pndsn.com/v1/message-actions/demo/channel/test-channel/message/123456789012345"];
    }

    return [NSURLRequest requestWithURL:requestURL];
}


- (NSURLResponse *)failedURLResponseForRequest:(NSURLRequest *)request
                                withStatusCode:(NSUInteger)statusCode
                                       headers:(nullable NSDictionary<NSString *, NSString *> *)headers {
    return [[NSHTTPURLResponse alloc] initWithURL:request.URL 
                                       statusCode:statusCode
                                      HTTPVersion:@"1.1"
                                     headerFields:headers];
}

#pragma mark -


@end
