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

- (BOOL)isRecording {
    return NO;
}

- (void)testSimplePublish {
    NSString *uniqueChannel = @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA";
    [self performVerifiedPublish:@"test" onChannel:uniqueChannel
                  withAssertions:^(PNPublishStatus *status) {
        XCTAssertNotNil(status);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.operation, PNPublishOperation);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertFalse(status.isError);
        NSLog(@"status.data.information: %@", status.data.information);
        NSLog(@"status.data.timeToken: %@", status.data.timetoken);
        XCTAssertEqualObjects(status.data.information, @"Sent");
        XCTAssertEqualObjects(status.data.timetoken, @"14345797352002658");
    }];
}

- (void)testPublishNilMessage {
    NSString *uniqueChannel = @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA";
    [self performVerifiedPublish:nil onChannel:uniqueChannel
                  withAssertions:^(PNPublishStatus *status) {
        XCTAssertNotNil(status);
        XCTAssertEqual(status.category, PNBadRequestCategory);
        XCTAssertEqual(status.operation, PNPublishOperation);
        XCTAssertEqual(status.statusCode, 400);
        XCTAssertTrue(status.isError);
        NSLog(@"status.data.information: %@", status.data.information);
        NSLog(@"status.data.timeToken: %@", status.data.timetoken);
        XCTAssertNil(status.data.information);
        XCTAssertNil(status.data.timetoken);
    }];
}

- (void)testPublishDictionary {
    NSString *uniqueChannel = @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA";
    [self performVerifiedPublish:@{@"test" : @"test"} onChannel:uniqueChannel
                  withAssertions:^(PNPublishStatus *status) {
        XCTAssertNotNil(status);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.operation, PNPublishOperation);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertFalse(status.isError);
        NSLog(@"status.data.information: %@", status.data.information);
        NSLog(@"status.data.timeToken: %@", status.data.timetoken);
        XCTAssertEqualObjects(status.data.information, @"Sent");
        XCTAssertEqualObjects(status.data.timetoken, @"14345797350907256");
    }];
}

- (void)performVerifiedPublish:(id)message onChannel:(NSString *)channel withAssertions:(PNPublishCompletionBlock)verificationBlock {
    XCTestExpectation *networkExpectation = [self expectationWithDescription:@"network"];
    [self.client publish:message toChannel:channel
          withCompletion:^(PNPublishStatus *status) {
        verificationBlock(status);
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
