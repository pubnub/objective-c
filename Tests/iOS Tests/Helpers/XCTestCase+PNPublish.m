//
//  XCTestCase+PNPublish.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import <PubNub/PubNub.h>
#import "XCTestCase+PNPublish.h"

@implementation XCTestCase (PNPublish)

- (void)PN_assertOnPublishStatus:(PNPublishStatus *)status withSuccess:(BOOL)isSuccessful {
    XCTAssertNotNil(status);
    XCTAssertEqual(status.operation, PNPublishOperation);
    if (isSuccessful) {
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertEqualObjects(status.data.information, @"Sent");
    } else {
        XCTAssertTrue(status.isError);
        XCTAssertEqual(status.category, PNBadRequestCategory);
        XCTAssertEqual(status.statusCode, 400);
        XCTAssertNil(status.data.information);
        XCTAssertNil(status.data.timetoken);
    }
}

- (PNPublishCompletionBlock)PN_successfulPublishCompletionWithExpectedTimeToken:(NSNumber *)timeToken {
    __block XCTestExpectation *publishExpectation = [self expectationWithDescription:@"publish"];
    return ^void (PNPublishStatus *status) {
        [self PN_assertOnPublishStatus:status withSuccess:YES];
        XCTAssertEqualObjects(status.data.timetoken, timeToken);
        [publishExpectation fulfill];
    };
}

- (PNPublishCompletionBlock)PN_failedPublishCompletion {
    __block XCTestExpectation *publishExpectation = [self expectationWithDescription:@"publish"];
    return ^void (PNPublishStatus *status) {
        [self PN_assertOnPublishStatus:status withSuccess:NO];
        [publishExpectation fulfill];
    };
}

@end
