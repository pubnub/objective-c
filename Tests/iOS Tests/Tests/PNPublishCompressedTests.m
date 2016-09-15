//
//  PNPublishCompressedTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 3/23/16.
//
//

#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

#import "NSString+PNTest.h"

@interface PNPublishCompressedTests : PNBasicClientTestCase

@end

@implementation PNPublishCompressedTests

- (BOOL)isRecording {
    
    return NO;
}

- (NSString *)publishChannelString {
    return @"F16CB07C-9F3F-41AA-8A0A-313960F21AAB";
}

- (void)testSimplePublishCompressed {
    [self performVerifiedPublish:@"test"
                       onChannel:[self publishChannelString]
                      compressed:YES withAssertions:^(PNPublishStatus *status) {
                          XCTAssertNotNil(status);
                          XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                          XCTAssertEqual(status.operation, PNPublishOperation);
                          XCTAssertEqual(status.statusCode, 200);
                          XCTAssertFalse(status.isError);
                          NSLog(@"status.data.information: %@", status.data.information);
                          NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                          XCTAssertEqualObjects(status.data.information, @"Sent");
                          XCTAssertEqualObjects(status.data.timetoken, @14737054442643779);
                      }];
}

- (void)testSimplePublishNotCompressed {
    [self performVerifiedPublish:@"test"
                       onChannel:[self publishChannelString]
                      compressed:NO
                  withAssertions:^(PNPublishStatus *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                      XCTAssertEqualObjects(status.data.timetoken, @14737054445444510);
                  }];
}

- (void)testPublishNilMessageCompressed {
    [self performVerifiedPublish:nil
                       onChannel:[self publishChannelString]
                      compressed:YES
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

- (void)testPublishNilMessageNotCompressed {
    [self performVerifiedPublish:nil
                       onChannel:[self publishChannelString]
                      compressed:NO
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

- (void)testPublishDictionaryCompressed {
    [self performVerifiedPublish:@{@"test" : @"test"}
                       onChannel:[self publishChannelString]
                      compressed:YES
                  withAssertions:^(PNPublishStatus *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                      XCTAssertEqualObjects(status.data.timetoken, @14737054436300432);
                  }];
}

- (void)testPublishDictionaryNotCompressed {
    [self performVerifiedPublish:@{@"test" : @"test"}
                       onChannel:[self publishChannelString]
                      compressed:NO
                  withAssertions:^(PNPublishStatus *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                      XCTAssertEqualObjects(status.data.timetoken, @14737054439376241);
                  }];
}

- (void)testPublishToNilChannelCompressed {
    [self performVerifiedPublish:@{@"test" : @"test"}
                       onChannel:nil
                      compressed:YES
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

- (void)testPublishToNilChanneNotCompressed {
    [self performVerifiedPublish:@{@"test" : @"test"}
                       onChannel:nil
                      compressed:NO
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
                    compressed:(BOOL)compressed
                withAssertions:(PNPublishCompletionBlock)verificationBlock {
    XCTestExpectation *networkExpectation = [self expectationWithDescription:@"network"];
    [self.client publish:message toChannel:channel compressed:compressed
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
