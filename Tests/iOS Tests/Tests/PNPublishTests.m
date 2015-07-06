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

#import "NSString+PNTest.h"

@interface PNPublishTests : PNBasicClientTestCase
@end

@implementation PNPublishTests

- (BOOL)isRecording{
    return NO;
}

- (NSString *)publishTestsChannelName {
    return @"2EC925F0-B996-47A4-AF54-A605E1A9AEBA";
}

- (void)testSimplePublish {
    [self performVerifiedPublish:@"test" onChannel:[self publishTestsChannelName]
                  withAssertions:^(PNPublishStatus *status) {
        XCTAssertNotNil(status);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.operation, PNPublishOperation);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertFalse(status.isError);
        NSLog(@"status.data.information: %@", status.data.information);
        NSLog(@"status.data.timeToken: %@", status.data.timetoken);
        XCTAssertEqualObjects(status.data.information, @"Sent");
        XCTAssertEqualObjects(status.data.timetoken, @14355311066264140);
    }];
}

- (void)testPublishNilMessage {
    [self performVerifiedPublish:nil onChannel:[self publishTestsChannelName]
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
    [self performVerifiedPublish:@{@"test" : @"test"} onChannel:[self publishTestsChannelName]
                  withAssertions:^(PNPublishStatus *status) {
        XCTAssertNotNil(status);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.operation, PNPublishOperation);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertFalse(status.isError);
        NSLog(@"status.data.information: %@", status.data.information);
        NSLog(@"status.data.timeToken: %@", status.data.timetoken);
        XCTAssertEqualObjects(status.data.information, @"Sent");
        XCTAssertEqualObjects(status.data.timetoken, @14355311062532489);
    }];
}

- (void)testPublishToNilChannel {
    [self performVerifiedPublish:@{@"test" : @"test"} onChannel:nil withAssertions:^(PNPublishStatus *status) {
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

- (void)testPublishNestedDictionary {
    [self performVerifiedPublish:@{@"test" : @{@"test": @"test"}} onChannel:[self publishTestsChannelName] withAssertions:^(PNPublishStatus *status) {
        XCTAssertNotNil(status);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.operation, PNPublishOperation);
        XCTAssertEqual(status.statusCode, 200);
        XCTAssertFalse(status.isError);
        NSLog(@"status.data.information: %@", status.data.information);
        NSLog(@"status.data.timeToken: %@", status.data.timetoken);
        XCTAssertEqualObjects(status.data.information, @"Sent");
        XCTAssertEqualObjects(status.data.timetoken, @14355311063449364);
    }];
}

/** FIXME: Error in PubNub+Publish.m
 
 Line 288: if ([message length]) {
 
 */

- (void)testPublishNumber {
    [self performVerifiedPublish:[NSNumber numberWithFloat:700]
                       onChannel:[self publishTestsChannelName]
                  withAssertions:^(PNPublishStatus *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                      XCTAssertEqualObjects(status.data.timetoken, @14355311064365833);
    }];
}

- (void)testPublishArray {
    [self performVerifiedPublish:@[@"1", @"2", @"3", @"4"]
                       onChannel:[self publishTestsChannelName]
                  withAssertions:^(PNPublishStatus *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                      XCTAssertEqualObjects(status.data.timetoken, @14355311060753687);
    }];
}

- (void)testPublishComplexArray {
    [self performVerifiedPublish:@[@"1", @{@"1": @{@"1": @"2"}}, @[@"1", @"2", @(2)], @(567)]
                       onChannel:[self publishTestsChannelName]
                  withAssertions:^(PNPublishStatus *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                      XCTAssertEqualObjects(status.data.timetoken, @14355311061679200);
                  }];
}

/* FIXME: investigate it more
 
 NSSet is not among our allowed object to send, according to documentation, 
 but it seems we missed isValidJSONObject check before we try to serialize 
  some object.
 */
 - (void)DISABLE_testPublishSet {
    [self performVerifiedPublish:[NSSet setWithObjects:@"1", @(5), @"3", nil]
                       onChannel:[self publishTestsChannelName]
                  withAssertions:^(PNPublishStatus *status) {
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

- (void)DISABLE_testPublish1kCharactersString {
    
    // generate long string
    NSString *testString = [NSString randomAlphanumericStringWithLength:1000];
    
    [self performVerifiedPublish:testString
                       onChannel:[self publishTestsChannelName]
                  withAssertions:^(PNPublishStatus *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                      XCTAssertEqualObjects(status.data.timetoken, @"14355247437244272");
                  }];
}

- (void)testPublish10kCharactersString {
    
    // generate long string
    NSString *testString = @"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";
    [self performVerifiedPublish:testString
                       onChannel:[self publishTestsChannelName]
                  withAssertions:^(PNPublishStatus *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                      XCTAssertEqualObjects(status.data.timetoken, @14355311058624908);
                  }];
}


- (void)testPublishStringWithSpecialSymbols {
    
    NSString *stringWithSpecialSymbols = @"!@#$%^&*()_+|";
    
    [self performVerifiedPublish:stringWithSpecialSymbols
                       onChannel:[self publishTestsChannelName]
                  withAssertions:^(PNPublishStatus *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNAcknowledgmentCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 200);
                      XCTAssertFalse(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                      XCTAssertEqualObjects(status.data.information, @"Sent");
                      XCTAssertEqualObjects(status.data.timetoken, @14355311065294161);
                  }];
}

#pragma mark - Main flow

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
