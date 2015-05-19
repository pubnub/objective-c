//
//  PNCoreTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015  PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PubNub.h"

#import "GCDGroup.h"
#import "GCDWrapper.h"

#import "TestConfigurator.h"

@interface PNCoreTests : XCTestCase

/*

@property (nonatomic, copy) NSString *publishKey;
@property (nonatomic, copy) NSString *subscribeKey;
@property (nonatomic, copy) NSString *authKey;
@property (nonatomic, copy, setter = setUUID:) NSString *uuid;
@property (nonatomic, copy) NSString *cipherKey;
@property (nonatomic, assign) NSTimeInterval subscribeMaximumIdleTime;
@property (nonatomic, assign) NSTimeInterval nonSubscribeRequestTimeout;
@property (nonatomic, assign) NSInteger presenceHeartbeatValue;
@property (nonatomic, assign) NSInteger presenceHeartbeatInterval;
@property (nonatomic, assign, getter = isSSLEnabled) BOOL SSLEnabled;
@property (nonatomic, assign, getter = shouldKeepTimeTokenOnListChange) BOOL keepTimeTokenOnListChange;
@property (nonatomic, assign, getter = shouldRestoreSubscription) BOOL restoreSubscription;
@property (nonatomic, assign, getter = shouldTryCatchUpOnSubscriptionRestore) BOOL catchUpOnSubscriptionRestore;
@property (nonatomic, strong) dispatch_queue_t callbackQueue;

- (void)commitConfiguration:(dispatch_block_t)block;
+ (instancetype)clientWithPublishKey:(NSString *)publishKey
                     andSubscribeKey:(NSString *)subscribeKey;
 */

@end


@implementation PNCoreTests {
    PubNub *_client;
}

- (void)setUp {
    
    [super setUp];
}

- (void)tearDown {
    
    _client = nil;
    [super tearDown];
}

#pragma mark - Tests

- (void)testSimpleInstance {
    
    _client = [PubNub clientWithPublishKey:[[TestConfigurator shared] mainPubKey] andSubscribeKey:[[TestConfigurator shared] mainSubKey]];
    
    if (_client == nil) {
        XCTFail(@"Cannot allocate client");
    }
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Checking configuration to work"];
    
    // we use it just to understand that we configure client appropriate way
    [_client timeWithCompletion:^(PNResult *result, PNStatus *status) {
        if (result) {
            NSLog(@"Time token: %@", result.data);
        }
        else {
            
            XCTFail(@"Request failed: %@", status);
        }
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:[[TestConfigurator shared] testTimeout] handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Error: %@", error);
        }
    }];
}

- (void)testCommitConfiguration {


}

@end
