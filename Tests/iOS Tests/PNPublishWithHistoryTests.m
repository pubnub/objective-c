//
//  PNPublishWithHistoryTests.m
//  PubNub Tests
//
//  Created by Vadim Osovets on 6/19/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

#import "NSString+PNTest.h"

@interface PNPublishWithHistoryTests : PNBasicClientTestCase

@end

@implementation PNPublishWithHistoryTests

- (BOOL)isRecording{
    return NO;
    
}

- (NSString *)publishChannelString {
    return @"9BA810C6-985D-4797-926F-CC81749CC774";
}

- (void)testSimplePublishWithHistory {
    [self performVerifiedPublish:@"test" onChannel:[self publishChannelString]
                  storeInHistory:YES
                  withAssertions:^(PNPublishStatus *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                      XCTAssertEqualObjects(status.data.timetoken, @"14355338601176506");
    }];
}

- (void)testSimplePublishWithoutHistory {
    [self performVerifiedPublish:@"test" onChannel:[self publishChannelString]
                  storeInHistory:NO
                  withAssertions:^(PNPublishStatus *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                      XCTAssertEqualObjects(status.data.timetoken, @"14355338601978693");
                  }];
}

- (void)testPublishWithHistoryNilMessage {
    [self performVerifiedPublish:nil
                       onChannel:[self publishChannelString]
                  storeInHistory:YES
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

- (void)testPublishWithoutHistoryNilMessage {
    [self performVerifiedPublish:nil
                       onChannel:[self publishChannelString]
                  storeInHistory:NO
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

- (void)testPublishDictionaryWithHistory {
    [self performVerifiedPublish:@{@"test" : @"test"}
                       onChannel:[self publishChannelString]
                  storeInHistory:YES
                  withAssertions:^(PNPublishStatus *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                      XCTAssertEqualObjects(status.data.timetoken, @"14355338598726743");
    }];
}

- (void)testPublishDictionaryWithoutHistory {
    [self performVerifiedPublish:@{@"test" : @"test"}
                       onChannel:[self publishChannelString]
                  storeInHistory:NO
                  withAssertions:^(PNPublishStatus *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                      XCTAssertEqualObjects(status.data.timetoken, @"14355338599684259");
                  }];
}

- (void)testPublishToNilChannelWithHistory {
    [self performVerifiedPublish:@{@"test" : @"test"}
                       onChannel:nil
                  storeInHistory:YES
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

- (void)testPublishToNilChannelWithoutHistory {
    [self performVerifiedPublish:@{@"test" : @"test"}
                       onChannel:nil
                  storeInHistory:NO
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

#pragma mark - Main flow

- (void)performVerifiedPublish:(id)message
                     onChannel:(NSString *)channel
                storeInHistory:(BOOL)storeInHistory
                withAssertions:(PNPublishCompletionBlock)verificationBlock {
    XCTestExpectation *networkExpectation = [self expectationWithDescription:@"network"];
    [self.client publish:message toChannel:channel storeInHistory:storeInHistory withCompletion:^(PNPublishStatus *status) {
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
