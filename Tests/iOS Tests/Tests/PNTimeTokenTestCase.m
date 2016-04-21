//
//  PNTimeTokenTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/21/16.
//
//

#import "PNClientTestCase.h"

@interface PNTimeTokenTestCase : PNClientTestCase

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
        XCTAssertEqualObjects(result.data.timetoken, @14612575985029626);
        [timeTokenExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
