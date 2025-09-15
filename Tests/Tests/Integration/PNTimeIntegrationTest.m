/**
 * @author Serhii Mamontov
 * @copyright © 2010-2020 PubNub, Inc.
 */
#import "PNRecordableTestCase.h"
#import <PubNub/PNBaseRequest+Private.h>
#import <PubNub/PubNub+CorePrivate.h>
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
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    [self completePubNubConfiguration:self.client];
}

- (PNConfiguration *)configurationForTestCaseWithName:(NSString *)name {
    PNConfiguration *configuration = [super configurationForTestCaseWithName:name];
    
    if ([name pnt_includesString:@"ShouldFetch"] && [name pnt_includesString:@"ResultWithExpectedOperation"]) {
        configuration.authKey = @"auth-key";
    }
    
    return configuration;
}


#pragma mark - Tests :: Fetch PubNub time

- (void)testItShouldFetchPubNubTimeAndReceiveResultWithExpectedOperation {
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        PNTimeRequest *request = [PNTimeRequest new];
        [self.client setAuthToken:@"secret-token"];
        
        [self.client timeWithRequest:request completion:^(PNTimeResult *result, PNErrorStatus *status) {
            PNTransportRequest *transportRequest = [self.client.serviceNetwork transportRequestFromTransportRequest:request.request];
            XCTAssertNil(status);
            XCTAssertNotNil(result.data.timetoken);
            XCTAssertEqual([@0 compare:result.data.timetoken], NSOrderedAscending);
            XCTAssertEqual(result.operation, PNTimeOperation);
            XCTAssertNotNil(self.client.currentConfiguration.authKey);
            XCTAssertNotNil([self.client.currentConfiguration valueForKey:@"authToken"]);
            XCTAssertEqualObjects(transportRequest.query[@"auth"], @"secret-token");
            
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
        PNTimeRequest *request = [PNTimeRequest new];
        __block __weak PNTimeCompletionBlock weakBlock;
        __block PNTimeCompletionBlock block;
        
        block = ^(PNTimeResult *result, PNErrorStatus *status) {
            __strong PNTimeCompletionBlock strongBlock = weakBlock;
            if (!strongBlock) XCTFail(@"Completion block invalidated.");
            
            if (!retried) {
                XCTAssertTrue(status.isError);
                XCTAssertEqual(status.operation, PNTimeOperation);
                XCTAssertEqual(status.category, PNMalformedResponseCategory);
                
                retried = YES;
                [self.client timeWithRequest:request completion:strongBlock];
            } else {
                XCTAssertNil(status);
                XCTAssertNotNil(result.data.timetoken);
                XCTAssertEqual([@0 compare:result.data.timetoken], NSOrderedAscending);
                handler();
            }
        };
        
        weakBlock = block;
        [self.client timeWithRequest:request completion:block];
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
