//
//  PNTimeTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/15/15.
//  Copyright (c) 2015 PubNub Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PubNub.h"

#import "GCDGroup.h"
#import "GCDWrapper.h"

#import "TestConfigurator.h"

@interface PNTimeTests : XCTestCase

@end

@implementation PNTimeTests {
    
    PubNub *_pubNub;
}

- (void)setUp {
    
    [super setUp];
    
    // Init PubNub
    _pubNub = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey] andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
    _pubNub.uuid = @"testUUID";
}

- (void)tearDown {
    
    _pubNub = nil;
    [super tearDown];
}

#pragma mark - Tests


- (void)testTimetoken {
    
    clock_t start = clock();

    // First timetoken
    XCTestExpectation *timeToken1Expectation = [self expectationWithDescription:@"Get timeToken1"];
        
    __block long _timetoken1;
    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        _timetoken1 = [[result.data objectForKey:@"tt"] longLongValue];
        [timeToken1Expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
    
    // Second timetoken
    XCTestExpectation *timeToken2Expectation = [self expectationWithDescription:@"Get timeToken2"];
    
    __block long _timetoken2;
    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        _timetoken2 = [[result.data objectForKey:@"tt"] longLongValue];
        [timeToken2Expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
    }];
    
    clock_t finish = clock();
    
    // Check that during the test and the difference between the timetokens obtained in 0.5сек ... 1сек
    double duringClock = (double)(finish - start) / 100000;
    double duringTimetoken = (double)(_timetoken2 - _timetoken1) / 1000000;
    XCTAssertTrue(0.5 < (duringClock - duringTimetoken) < 1, @"Error");
}


#pragma mark - private methods

// For the future
- (BOOL)checkResult:(PNResult *)result andStatus:(PNStatus *)status {
    
    if ((result && status) || (!result && !status)) {
        
        XCTFail(@"Error");
    } else if (result) {
        
        NSLog(@"!!! %@", [result.data objectForKey:@"tt"]);
    } else if (status) {
        
        NSLog(@"!!! %@", status);
    }
    
    return YES;
}
@end
