//
//  PNPublishWithMobilePayloadTests.m
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

@interface PNPublishWithMobilePayloadTests : PNBasicClientTestCase

@end

@implementation PNPublishWithMobilePayloadTests

- (BOOL)recording {
    return YES;
    
}

- (void)testSimplePublishNilMobilePushPayload {
    [self performVerifiedPublish:@"test"
                       onChannel:[NSUUID UUID].UUIDString
     mobilePushPayload:nil
                  storeInHistory:YES
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
