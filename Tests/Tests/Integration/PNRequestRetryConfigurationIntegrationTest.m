#import "PNRecordableTestCase.h"
#import "NSString+PNTest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

/// Request automatic retry configuration integration tests.
///
/// - Copyright: 2010-2023 PubNub, Inc.
@interface PNRequestRetryConfigurationIntegrationTest : PNRecordableTestCase


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNRequestRetryConfigurationIntegrationTest


#pragma mark - Setup / Tear down

- (PNConfiguration *)configurationForTestCaseWithName:(NSString *)name {
    PNConfiguration *configuration = [super configurationForTestCaseWithName:name];
    PNRequestRetryConfiguration *retryConfiguration = nil;

    if ([name pnt_includesString:@"LinearPolicy"]) {
        retryConfiguration = [PNRequestRetryConfiguration configurationWithLinearInterval];
    } else if ([name pnt_includesString:@"ExponentialPolicy"]) {
        retryConfiguration = [PNRequestRetryConfiguration configurationWithExponentialInterval];
    }

    if (retryConfiguration) {
        [retryConfiguration setValue:@(.5f) forKey:@"interval"];
        [retryConfiguration setValue:@(2) forKey:@"maximumRetryAttempts"];
    }

    configuration.requestRetry = retryConfiguration;

    return configuration;
}


#pragma mark - Tests :: Linear

- (void)testItShouldRetryRequestTwiceWithLinearPolicy {
    // Validate cassette to have initial and two retry attempts.
    XCTAssertEqual(YHVVCR.cassette.requests.count, 3);

    [self waitToCompleteIn:4.f codeBlock:^(dispatch_block_t handler) {
        [self.client publish:@"hello-world" toChannel:@"test-channel" withCompletion:^(PNPublishStatus *status) {

            XCTAssertTrue(status.isError);
            XCTAssertTrue([YHVVCR.cassette allPlayed]);
            handler();
        }];
    }];
}


#pragma mark - Tests :: Exponential

- (void)testItShouldRetryRequestTwiceWithExponentialPolicy {
    // Validate cassette to have initial and two retry attempts.
    XCTAssertEqual(YHVVCR.cassette.requests.count, 3);

    [self waitToCompleteIn:4.f codeBlock:^(dispatch_block_t handler) {
        [self.client publish:@"hello-world" toChannel:@"test-channel" withCompletion:^(PNPublishStatus *status) {

            XCTAssertTrue(status.isError);
            XCTAssertTrue([YHVVCR.cassette allPlayed]);
            handler();
        }];
    }];
}

#pragma mark -


@end
