//
//  PNSubscribeNetworkIssueTests.m
//  PubNub Tests
//
//  Created by Vadim Osovets on 12/2/15.
//
//

#import <XCTest/XCTest.h>

#import "PNBasicSubscribeTestCase.h"

@interface PNSubscribeNetworkIssueTests : PNBasicSubscribeTestCase

@end

@implementation PNSubscribeNetworkIssueTests

- (BOOL)isRecording{
    
    return NO;
}

- (NSArray *)subscriptionChannels {
    
    return @[@"a"];
}

#pragma mark - Tests

/*
 Idea of tests:
  Сheck behavior of SDK in case of we have 504 status error.
 
 Correct behavior:
  After 1 second we should try to resubscibe to the channel with the same timetoken
 */

- (void)testSubscribeWith504Error {
    PNWeakify(self);
    
    self.subscribeExpectation = [self expectationWithDescription:@"subscribe"];
    
    __block int countUnexpectedDisconnect = 0;
    
    self.didReceiveStatusAssertions = ^void (PubNub *client, PNSubscribeStatus *status) {
        
        PNStrongify(self);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        
        if (status.category == PNUnexpectedDisconnectCategory) {
            countUnexpectedDisconnect++;
            
            if (countUnexpectedDisconnect > 5) {
                [self.subscribeExpectation fulfill];
            }
        }
    };
    
    [self.client subscribeToChannels:[self subscriptionChannels] withPresence:YES usingTimeToken:nil];
    
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
