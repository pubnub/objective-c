/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import "NSString+PNTest.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNTimeIntegrationTest : PNRecordableTestCase


#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNTimeIntegrationTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
}

- (PNConfiguration *)configurationForTestCaseWithName:(NSString *)name {
    PNConfiguration *configuration = [super configurationForTestCaseWithName:name];
    
    if ([name pnt_includesString:@"ShouldFetch"] && [name pnt_includesString:@"ResultWithExpectedOperation"]) {
        configuration.authKey = @"auth-key";
        configuration.authToken = @"secret-token";
    }
    
    return configuration;
}


#pragma mark - Tests :: Fetch PubNub time

- (void)testItShouldFetchPubNubTimeAndReceiveResultWithExpectedOperation {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client timeWithCompletion:^(PNTimeResult *result, PNErrorStatus *status) {
            XCTAssertNil(status);
            XCTAssertNotNil(result.data.timetoken);
            XCTAssertEqual([@0 compare:result.data.timetoken], NSOrderedAscending);
            XCTAssertEqual(result.operation, PNTimeOperation);
            XCTAssertNotNil(self.client.currentConfiguration.authKey);
            XCTAssertNotNil(self.client.currentConfiguration.authToken);
            
            NSURLRequest *request = [result valueForKey:@"clientRequest"];
            XCTAssertNotEqual([request.URL.query rangeOfString:@"auth=secret-token"].location, NSNotFound);
            
            handler();
        }];
    }];
}

/**
 * @brief To test 'retry' functionality
 *  'ItShouldFetchPubNubTimeAfterRetry.json' should be modified after cassette recording. Find first mention of time API and copy paste
 *  4 entries which belong to it. For new entries change 'id' field to be different from source. For
 *  original response entry change status code to 404.
 */
- (void)testItShouldFetchPubNubTimeAfterRetry {
    if ([self shouldSkipTestWithManuallyModifiedMockedResponse]) {
        NSLog(@"'%@' requires special conditions (modified mocked response). Skip", self.name);
        return;
    }
    __block BOOL retried = NO;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.client timeWithCompletion:^(PNTimeResult *result, PNErrorStatus *status) {
            if (!retried) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.operation, PNTimeOperation);
                XCTAssertEqual(status.category, PNMalformedResponseCategory);
                XCTAssertEqual(status.statusCode, 404);
                
                retried = YES;
                [status retry];
            } else {
                XCTAssertNil(status);
                XCTAssertNotNil(result.data.timetoken);
                XCTAssertEqual([@0 compare:result.data.timetoken], NSOrderedAscending);
                handler();
            }
        }];
    }];
}


#pragma mark - Tests :: Builder pattern-based channel here now

- (void)testItShouldFetchPubNubTimeUsingBuilderPatternInterface {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.time().performWithCompletion(^(PNTimeResult *result, PNErrorStatus *status) {
            XCTAssertNil(status);
            XCTAssertNotNil(result.data.timetoken);
            XCTAssertEqual([@0 compare:result.data.timetoken], NSOrderedAscending);
            XCTAssertEqual(result.operation, PNTimeOperation);
            
            handler();
        });
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
