//
//  PNTimeTokenTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/28/15.
//
//

#import <PubNub/PubNub.h>

#import "PNBasicSubscribeTestCase.h"

@interface PNTimeTokenTests : PNBasicSubscribeTestCase

@end

@implementation PNTimeTokenTests

- (BOOL)isRecording{
    return NO;
}

- (void)testTimeToken {
    XCTestExpectation *timeTokenExpectation = [self expectationWithDescription:@"timeToken"];
    [self.client timeWithCompletion:^(PNTimeResult *result, PNErrorStatus *status) {
        XCTAssertNil(status.errorData.information);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.operation, PNTimeOperation);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqualObjects(result.data.timetoken, @15579918206106789);
        [timeTokenExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
