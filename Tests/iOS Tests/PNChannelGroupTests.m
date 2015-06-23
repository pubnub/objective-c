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

static NSString * const kChannelGroup = @"79713A48-107C-4338-9977-92EEC1F29577";

@interface PNChannelGroupTests : PNBasicSubscribeTestCase
@end

@implementation PNChannelGroupTests

- (BOOL)isRecording {
    return NO;
}

- (void)tearDown {
    XCTestExpectation *channelGroupTearDownExpectation = [self expectationWithDescription:@"tearDownExpectation"];
    [self.client removeChannelsFromGroup:kChannelGroup
                          withCompletion:^(PNAcknowledgmentStatus *status) {
        [channelGroupTearDownExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
    [super tearDown];
}

- (void)testChannelGroupAdd {
    self.subscribeExpectation = [self expectationWithDescription:@"network"];
    [self.client addChannels:@[@"a", @"c"] toGroup:kChannelGroup
              withCompletion:^(PNAcknowledgmentStatus *status) {
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
