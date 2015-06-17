//
//  PNChannelGroupTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/16/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "PNBasicSubscribeTestCase.h"

@interface PNChannelGroupTests : PNBasicSubscribeTestCase

@end

@implementation PNChannelGroupTests

- (BOOL)recording {
    return NO;
}

- (void)testChannelGroupAdd {
    self.subscribeExpectation = [self expectationWithDescription:@"network"];
    NSString *channelGroup = [NSUUID UUID].UUIDString;
    [self.client addChannels:@[@"a", @"c"] toGroup:channelGroup withCompletion:^(PNStatus<PNStatus> *status) {
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.operation, PNAddChannelsToGroupOperation);
        XCTAssertEqual(status.category, PNAcknowledgmentCategory);
        XCTAssertEqual(status.statusCode, 200);
        [self.subscribeExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
            XCTFail(@"what went wrong?");
        }
    }];
}

@end
