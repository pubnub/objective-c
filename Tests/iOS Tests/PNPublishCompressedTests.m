//
//  PNPublishCompressedTests.m
//  PubNub Tests
//
//  Created by Vadim Osovets on 6/22/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

#import "NSString+PNTest.h"

@interface PNPublishCompressedTests : PNBasicClientTestCase

@end

@implementation PNPublishCompressedTests

- (BOOL)recording {
    return NO;
    
}

- (void)testSimplePublishCompressed {
    [self performVerifiedPublish:@"test"
                       onChannel:[NSUUID UUID].UUIDString
                      compressed:YES withAssertions:^(PNStatus<PNPublishStatus> *status) {
                          XCTAssertNotNil(status);
                          XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                          XCTAssertEqual(status.operation, PNPublishOperation);
                          XCTAssertEqual(status.statusCode, 200);
                          XCTAssertFalse(status.isError);
                          NSLog(@"status.data.information: %@", status.data.information);
                          NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                          XCTAssertEqualObjects(status.data.information, @"Sent");
                      }];
}

- (void)testSimplePublishNotCompressed {
    [self performVerifiedPublish:@"test"
                       onChannel:[NSUUID UUID].UUIDString
                      compressed:NO
                  withAssertions:^(PNStatus<PNPublishStatus> *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                  }];
}

- (void)testPublishNilMessageCompressed {
    [self performVerifiedPublish:nil
                       onChannel:[NSUUID UUID].UUIDString
                      compressed:YES
                  withAssertions:^(PNStatus<PNPublishStatus> *status) {
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

- (void)testPublishNilMessageNotCompressed {
    [self performVerifiedPublish:nil
                       onChannel:[NSUUID UUID].UUIDString
                      compressed:NO
                  withAssertions:^(PNStatus<PNPublishStatus> *status) {
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

- (void)testPublishDictionaryCompressed {
    [self performVerifiedPublish:@{@"test" : @"test"}
                       onChannel:[NSUUID UUID].UUIDString
                      compressed:YES
                  withAssertions:^(PNStatus<PNPublishStatus> *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                  }];
}

- (void)testPublishDictionaryNotCompressed {
    [self performVerifiedPublish:@{@"test" : @"test"}
                       onChannel:[NSUUID UUID].UUIDString
                      compressed:NO
                  withAssertions:^(PNStatus<PNPublishStatus> *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                  }];
}

- (void)testPublishToNilChannelCompressed {
    [self performVerifiedPublish:@{@"test" : @"test"}
                       onChannel:nil
                      compressed:YES
                  withAssertions:^(PNStatus<PNPublishStatus> *status) {
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

- (void)testPublishToNilChanneNotCompressed {
    [self performVerifiedPublish:@{@"test" : @"test"}
                       onChannel:nil
                      compressed:NO
                  withAssertions:^(PNStatus<PNPublishStatus> *status) {
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
                    compressed:(BOOL)compressed
                withAssertions:(PNPublishCompletionBlock)verificationBlock {
    XCTestExpectation *networkExpectation = [self expectationWithDescription:@"network"];
    [self.client publish:message toChannel:channel compressed:compressed
          withCompletion:^(PNStatus<PNPublishStatus> *status) {
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
