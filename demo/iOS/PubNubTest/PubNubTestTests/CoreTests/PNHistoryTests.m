//
//  PNHistoryTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "GCDGroup.h"
#import "GCDWrapper.h"

#import "TestConfigurator.h"

@interface PNHistoryTests : XCTestCase

@end

@implementation PNHistoryTests {
    
    PubNub *_pubNub;
    BOOL _isTestError;
}


- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey] andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
    _pubNub.uuid = @"testUUID";
}

- (void)tearDown {
    
    _pubNub =nil;
    [super tearDown];
}

- (void)testHistory {

    // Get timetoken until send message
    XCTestExpectation *timeToken1Expectation = [self expectationWithDescription:@"Get timeToken1"];
    
    __block NSNumber *_timetoken1;
    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting timetoken %@", status.data);
            _isTestError = YES;
        } else {
            
            _timetoken1 = [NSNumber numberWithLongLong:[[result.data objectForKey:@"tt"] longLongValue] ];
        }
        [timeToken1Expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        
        return;
    }

    // Send message to channel
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message"];
    
    [_pubNub publish:@"Hello world" toChannel:@"testChannel1" storeInHistory:NO withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during publishing message %@", status.data);
        }
        [_publishExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        
        return;
    }

    // Get timetoken after send message
    XCTestExpectation *timeToken2Expectation = [self expectationWithDescription:@"Get timeToken2"];
    
    __block NSNumber *_timetoken2;
    [_pubNub timeWithCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting timetoken %@", status.data);
            _isTestError = YES;
        } else {
            
            _timetoken2 = [NSNumber numberWithLongLong:[[result.data objectForKey:@"tt"] longLongValue] ];
        }
        [timeToken2Expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];

    // Get history for channel
    XCTestExpectation *_getHistoryExpectation = [self expectationWithDescription:@"Getting history"];

    [_pubNub historyForChannel:@"testChannel1" start:_timetoken1 end:_timetoken2 limit:1 reverse:NO includeTimeToken:YES withCompletion:^(PNResult *result, PNStatus *status) {

        if (status.isError) {
            
            XCTFail(@"Error occurs during getting messages from history %@", status.data);
        }
        [_getHistoryExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
}

@end
