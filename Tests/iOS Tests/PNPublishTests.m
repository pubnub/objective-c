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

- (BOOL)recording {
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
        XCTAssertEqualObjects(status.data.timetoken, @"14347265638751945");
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
        XCTAssertEqualObjects(status.data.timetoken, @"14347265622706178");
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
    [self performVerifiedPublish:@{@"test" : @{@"test": @"test"}} onChannel:[NSUUID UUID].UUIDString withAssertions:^(PNPublishStatus *status) {
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

/** FIXME: Error in PubNub+Publish.m
 
 Line 288: if ([message length]) {
 
 */

/*
- (void)testPublishNumber {
    [self performVerifiedPublish:[NSNumber numberWithFloat:700]
                       onChannel:[NSUUID UUID].UUIDString
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
 */

- (void)testPublishArray {
    [self performVerifiedPublish:@[@"1", @"2", @"3", @"4"]
                       onChannel:[NSUUID UUID].UUIDString
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

- (void)testPublishComplexArray {
    [self performVerifiedPublish:@[@"1", @{@"1": @{@"1": @"2"}}, @[@"1", @"2", @(2)], @(567)]
                       onChannel:[NSUUID UUID].UUIDString
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

/* FIXME: investigate it more
 
 NSSet is not among our allowed object to send, according to documentation, 
 but it seems we missed isValidJSONObject check before we try to serialize 
  some object.
 - (void)testPublishSet {
    [self performVerifiedPublish:[NSSet setWithObjects:@"1", @(5), @"3", nil]
                       onChannel:[NSUUID UUID].UUIDString
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
 */

- (void)testPublish1kCharactersString {
    
    // generate long string
    NSString *testString = [NSString randomAlphanumericStringWithLength:1000];
    
    [self performVerifiedPublish:testString
                       onChannel:[NSUUID UUID].UUIDString
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

- (void)testPublish10kCharactersString {
    
    // generate long string
    NSString *testString = [NSString randomAlphanumericStringWithLength:10000];
    
    [self performVerifiedPublish:testString
                       onChannel:[NSUUID UUID].UUIDString
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


- (void)testPublishStringWithSpecialSymbols {
    
    NSString *stringWithSpecialSymbols = @"!@#$%^&*()_+|";
    
    [self performVerifiedPublish:stringWithSpecialSymbols
                       onChannel:[NSUUID UUID].UUIDString
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
