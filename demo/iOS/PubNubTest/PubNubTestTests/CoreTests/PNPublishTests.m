//
//  PNPublishTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PubNub.h"

#import "GCDGroup.h"
#import "GCDWrapper.h"

@interface PNPublishTests : XCTestCase

@end

@implementation PNPublishTests  {
    
    PubNub *_pubNub;
    GCDGroup *_resGroup;
}


- (void)setUp {
    
    [super setUp];
    
    _pubNub = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    _pubNub.uuid = @"testUUID";
}

- (void)tearDown {
    
    _pubNub =nil;
    [super tearDown];
}

#warning PNResult *result

- (void)testPublishWithStoryInHistory {

    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message"];
    XCTestExpectation *_getHistoryExpectation = [self expectationWithDescription:@"Getting history"];
    
    [_pubNub publish:@"Hello world" toChannel:@"testChannel1" storeInHistory:YES withCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_publishExpectation fulfill];
    }];
    
    [_pubNub historyForChannel:@"testChannel1" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_getHistoryExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestTimout handler:^(NSError *error) {
    }];
}

- (void)testPublishWithoutStoryInHistory {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message"];
    XCTestExpectation *_getHistoryExpectation = [self expectationWithDescription:@"Getting history"];
    
    [_pubNub publish:@"Hello world" toChannel:@"testChannel1" storeInHistory:NO withCompletion:^(PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_publishExpectation fulfill];
    }];
    
    [_pubNub historyForChannel:@"testChannel1" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.error) {
            
            XCTFail(@"Error");
        }
        [_getHistoryExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:kTestTimout handler:^(NSError *error) {
    }];
}


@end
