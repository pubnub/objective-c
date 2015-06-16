//
//  PNPublishTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/15/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

@interface PNPublishTests : PNBasicClientTestCase
@end

@implementation PNPublishTests

- (BOOL)recording {
    return NO;
}

- (void)testSimplePublish {
    [self performVerifiedPublish:@"test"];
}

- (void)performVerifiedPublish:(id)message {
    XCTestExpectation *networkExpectation = [self expectationWithDescription:@"network"];
    NSString *uniqueChannel = [NSUUID UUID].UUIDString;
    [self.client publish:message toChannel:uniqueChannel withCompletion:^(PNStatus<PNPublishStatus> *status) {
        XCTAssertNotNil(status);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.operation, PNPublishOperation);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertFalse(status.isError);
        XCTAssertEqualObjects(status.data.information, @"Sent");
        NSLog(@"timeToken: %@", status.data.timetoken);
        XCTAssertEqualObjects(status.data.timetoken, @14344794403500414);
        [networkExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

@end
