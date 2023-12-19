#import <PubNub/PNRequestRetryConfiguration+Private.h>
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
