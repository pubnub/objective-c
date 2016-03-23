//
//  PNPublishWithMobilePayloadTests.m
//  PubNub Tests
//
//  Created by Vadim Osovets on 6/22/15.
//
//

#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

#import "NSString+PNTest.h"

@interface PNPublishWithMobilePayloadTests : PNBasicClientTestCase

@end

@implementation PNPublishWithMobilePayloadTests

- (BOOL)isRecording{
    return NO;
}

- (NSString *)publishChannelName {
    return @"02290046-2F36-43DD-97F0-2F51D925451A";
}

- (void)testSimplePublishSimpleMobilePushPayload {
    
    NSDictionary *payload = @{@"aps" :
                                  @{@"alert" : @"You got your emails.@",
                                    @"badge" : @(9),
                                    @"sound" : @"bingbong.aiff"},
                              @"acme 1" : @(42)};
    
    [self performVerifiedPublish:@"test"
                       onChannel:[self publishChannelName]
               mobilePushPayload:payload
                  storeInHistory:YES
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
                      XCTAssertEqualObjects(status.data.timetoken, @14587651644081128);
                  }];
}

- (void)testSimplePublishNilMobilePushPayload {
    [self performVerifiedPublish:@"test"
                       onChannel:[self publishChannelName]
               mobilePushPayload:nil
                  storeInHistory:YES
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
                      XCTAssertEqualObjects(status.data.timetoken, @14587651642570398);
                  }];
}

- (void)testPublishMobilePayloadNotStoreInHistory {
    
    NSDictionary *payload = @{@"aps" :
                                  @{@"alert" : @"You got your emails.@",
                                    @"badge" : @(9),
                                    @"sound" : @"bingbong.aiff"},
                              @"acme 1" : @(42)};
    
    [self performVerifiedPublish:@"test"
                       onChannel:[self publishChannelName]
               mobilePushPayload:payload
                  storeInHistory:NO
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
                      XCTAssertEqualObjects(status.data.timetoken, @14587651639789412);
                  }];
}

- (void)testPublishMobilePayloadNotStoreInHistoryNotCompressed {
    
    NSDictionary *payload = @{@"aps" :
                                  @{@"alert" : @"You got your emails.@",
                                    @"badge" : @(9),
                                    @"sound" : @"bingbong.aiff"},
                              @"acme 1" : @(42)};
    
    [self performVerifiedPublish:@"test"
                       onChannel:[self publishChannelName]
               mobilePushPayload:payload
                  storeInHistory:NO
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
                  }];
}

- (void)testPublishMobilePayloadToNillChannnel {
    
    NSDictionary *payload = @{@"aps" :
                                  @{@"alert" : @"You got your emails",
                                    @"badge" : @(9),
                                    @"sound" : @"bingbong.aiff"},
                              @"acme 1" : @(42)};
    
    [self performVerifiedPublish:@"test"
                       onChannel:nil
               mobilePushPayload:payload
                  storeInHistory:NO
                      compressed:NO
                  withAssertions:^(PNPublishStatus *status) {
                      XCTAssertNotNil(status);
                      XCTAssertEqual(status.category, PNBadRequestCategory);
                      XCTAssertEqual(status.operation, PNPublishOperation);
                      XCTAssertEqual(status.statusCode, 400);
                      XCTAssertTrue(status.isError);
                      NSLog(@"status.data.information: %@", status.data.information);
                      NSLog(@"status.data.timeToken: %@", status.data.timetoken);
                  }];
}

#pragma mark - Main flow

- (void)performVerifiedPublish:(id)message
                     onChannel:(NSString *)channel
             mobilePushPayload:(NSDictionary *)payload
                storeInHistory:(BOOL)storeInHistory
                    compressed:(BOOL)compressed
                withAssertions:(PNPublishCompletionBlock)verificationBlock {
    XCTestExpectation *networkExpectation = [self expectationWithDescription:@"network"];
    [self.client publish:message
               toChannel:channel
       mobilePushPayload:payload
          storeInHistory:storeInHistory
              compressed:compressed
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
