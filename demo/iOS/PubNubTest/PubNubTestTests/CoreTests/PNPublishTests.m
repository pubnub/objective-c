//
//  PNPublishTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "TestConfigurator.h"

@interface PNPublishTests : XCTestCase

@end

@implementation PNPublishTests  {
    
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

#warning PNResult *result

- (void)testPublishWithStoryInHistory {

    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message"];
    XCTestExpectation *_getHistoryExpectation = [self expectationWithDescription:@"Getting history"];
    
    // Send message
    NSString *testMessage = @"Hello world";

    [_pubNub publish:testMessage toChannel:@"testChannel1" storeInHistory:YES withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during publishing %@", status.data);
            _isTestError = YES;
        }
        [_publishExpectation fulfill];
    }];
    
    // Get history
    __block NSString *sentMessage;
    
    [_pubNub historyForChannel:@"testChannel1" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting history %@", status.data);
            _isTestError = YES;
        } else {
            
            NSArray *messages = (NSArray *)[result.data objectForKey:@"messages"];
            sentMessage = [(NSDictionary *)[messages lastObject] objectForKey:@"message"];
        }
        [_getHistoryExpectation fulfill];
    }];
    
    // Waiting for result
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        
        return;
    }
    
    // Check result
    XCTAssertEqualObjects(testMessage, sentMessage, @"Error, got incorrectly message: %@", sentMessage);
}

- (void)testPublishWithoutStoryInHistory {
    
    XCTestExpectation *_publishExpectation = [self expectationWithDescription:@"Send message withut store in history"];
    XCTestExpectation *_getHistoryExpectation = [self expectationWithDescription:@"Getting history"];
    
    // Send message without store in history
    NSString *testMessage = @"Hello world again";
    
    [_pubNub publish:testMessage toChannel:@"testChannel1" storeInHistory:NO withCompletion:^(PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during publishing %@", status.data);
            _isTestError = YES;
        }
        [_publishExpectation fulfill];
    }];

    // Get history
    __block NSString *sentMessage;
    
    [_pubNub historyForChannel:@"testChannel1" withCompletion:^(PNResult *result, PNStatus *status) {
        
        if (status.isError) {
            
            XCTFail(@"Error occurs during getting history %@", status.data);
            _isTestError = YES;
        } else {
            
            NSArray *messages = (NSArray *)[result.data objectForKey:@"messages"];
            sentMessage = [(NSDictionary *)[messages lastObject] objectForKey:@"message"];
        }
        [_getHistoryExpectation fulfill];
    }];
    
    // Waiting for result
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        
        if (error) {
            
            XCTFail(@"Timeout is fired");
            _isTestError = YES;
        }
    }];
    
    if (_isTestError) {
        
        return;
    };
    
    // Check result
    XCTAssertFalse([testMessage isEqual:sentMessage], @"Error, got incorrectly message: %@", sentMessage);
}


@end
