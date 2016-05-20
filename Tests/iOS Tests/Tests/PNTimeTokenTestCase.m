//
//  PNTimeTokenTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/21/16.
//
//

#import <PubNubTesting/PubNubTesting.h>

@interface PNTimeTokenTestCase : PNTClientTestCase

@end

@implementation PNTimeTokenTestCase

- (BOOL)isRecording {
    return NO;
}

- (void)testTimeToken {
    __block XCTestExpectation *timeTokenExpectation = [self expectationWithDescription:@"timeToken"];
    [self.client timeWithCompletion:^(PNTimeResult *result, PNErrorStatus *status) {
        XCTAssertNil(status.errorData.information);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.operation, PNTimeOperation);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqualObjects(result.data.timetoken, @14635141685212657);
        [timeTokenExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:kPNTTimeTokenTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
