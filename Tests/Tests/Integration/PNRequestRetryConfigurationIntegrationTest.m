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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - Setup / Tear down

- (PNConfiguration *)configurationForTestCaseWithName:(NSString *)name {
    PNConfiguration *configuration = [super configurationForTestCaseWithName:name];
    PNRequestRetryConfiguration *retryConfiguration = nil;

    if ([name pnt_includesString:@"LinearPolicy"]) {
        retryConfiguration = [PNRequestRetryConfiguration configurationWithLinearDelay];
    } else if ([name pnt_includesString:@"ExponentialPolicy"]) {
        retryConfiguration = [PNRequestRetryConfiguration configurationWithExponentialDelay];
    }

    if (retryConfiguration) {
        [retryConfiguration setValue:@(.5f) forKey:@"minimumDelay"];
        [retryConfiguration setValue:@(2) forKey:@"maximumRetry"];
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

#pragma clang diagnostic pop

@end
