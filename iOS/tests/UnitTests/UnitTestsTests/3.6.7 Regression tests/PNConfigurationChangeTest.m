//
//  PNConfigurationChangeTest.m
//  pubnub
//
//  Created by Vadim Osovets on 9/5/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

/* This set of test cases should cover most of scenarious to
 test configuration change during connection.
 */

#import <XCTest/XCTest.h>
#import "GCDWrapper.h"

@interface PNConfigurationChangeTest : XCTestCase

<
PNDelegate
>

@end

@implementation PNConfigurationChangeTest {
    dispatch_group_t _resultGroup1;
    dispatch_group_t _resultGroup2;
    dispatch_group_t _resultGroup3;
    dispatch_group_t _resultGroup4;
    
    PNConfiguration *_testConfiguration1;
    PNConfiguration *_testConfiguration2;
    PNConfiguration *_testConfiguration3;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _testConfiguration1 = [PNConfiguration defaultConfiguration];
    // Vadim's keys
    _testConfiguration2 = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"
                                                                       publishKey:@"pub-c-12b1444d-4535-4c42-a003-d509cc071e09" subscribeKey:@"sub-c-6dc508c0-bff0-11e3-a219-02ee2ddab7fe"
                                                                        secretKey:@"sec-c-YjIzMWEzZmEtYWVlYS00MzMzLTkyZGItNWJkMjRlZGQ4MjAz"];
    // SergeyK's keys
    _testConfiguration3 = [PNConfiguration accessManagerTestConfiguration];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [PubNub disconnect];
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testSetupWithInvalidConfiguration {
    [PubNub setDelegate:self];
    
    _resultGroup1 = dispatch_group_create();
    dispatch_group_enter(_resultGroup1);
    
    PNConfiguration *testConfiguration = [PNConfiguration configurationForOrigin:@"" publishKey:@""
                                                                    subscribeKey:@"" secretKey:nil];
    
    [PubNub setupWithConfiguration:testConfiguration andDelegate:self];
    
    if ([GCDWrapper isGroup:_resultGroup1 timeoutFiredValue:5]) {
        XCTFail(@"Didn't receive error message about invalid congiguration.");
    }

    _resultGroup1 = NULL;
}

- (void)testSetupWithValidConfiguration {
    [PubNub setDelegate:self];
    
    _resultGroup2 = dispatch_group_create();
    dispatch_group_enter(_resultGroup2);
    dispatch_group_enter(_resultGroup2);
    
    PNConfiguration *testConfiguration = [PNConfiguration defaultConfiguration];
    
    [PubNub setupWithConfiguration:testConfiguration andDelegate:self];
    [PubNub connect];
    
    if ([GCDWrapper isGroup:_resultGroup2 timeoutFiredValue:10]) {
        XCTFail(@"Cannot setup with configuration.");
    }
    
    _resultGroup2 = NULL;
}

- (void)testChangingSeveralConfigurations {
    [PubNub setDelegate:self];
    
    _resultGroup3 = dispatch_group_create();
    
    // Test-case 1: connect and change configuration
    dispatch_group_enter(_resultGroup3);
    
    [PubNub setupWithConfiguration:_testConfiguration1 andDelegate:self];
    [PubNub connect];
    [PubNub setupWithConfiguration:_testConfiguration2 andDelegate:self];
    [PubNub setupWithConfiguration:_testConfiguration3 andDelegate:self];
    
    if ([GCDWrapper isGroup:_resultGroup3 timeoutFiredValue:10]) {
        XCTFail(@"Cannot connect with configuration.");
    }
    
    _resultGroup3 = NULL;
}

#warning 3.6.7 version doesn't support multithreading.
- (void)testChangingSeveralConfigurationsInDifferentThreads {
    [PubNub setDelegate:self];
    
    // Test-case 2: start connect and chanding configuration simultaneously
    _resultGroup4 = dispatch_group_create();
    
    dispatch_group_enter(_resultGroup4);
    
    dispatch_group_t _startGroup = dispatch_group_create();

    [PubNub setupWithConfiguration:_testConfiguration1 andDelegate:self];
    
    dispatch_group_enter(_startGroup);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"t1");
        
        if (dispatch_group_wait(_startGroup, DISPATCH_TIME_FOREVER) == 0) {
            NSLog(@"t1.1");
            [PubNub connect];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"t2");
        
        if (dispatch_group_wait(_startGroup, DISPATCH_TIME_FOREVER) == 0) {
            NSLog(@"t2.1");
            [PubNub setupWithConfiguration:_testConfiguration2 andDelegate:self];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"t3");
        if (dispatch_group_wait(_startGroup, DISPATCH_TIME_FOREVER) == 0) {
            NSLog(@"t3.1");
            [PubNub setupWithConfiguration:_testConfiguration3 andDelegate:self];
        }

    });
    
    [GCDWrapper sleepForSeconds:1];
    
    dispatch_group_leave(_startGroup);
    
    if ([GCDWrapper isGroup:_resultGroup4 timeoutFiredValue:10]) {
        XCTFail(@"Cannot connect with configuration.");
    }
    
    _resultGroup4 = NULL;
}

#pragma mark - PubNub Delegate

- (void)pubnubClient:(PubNub *)client error:(PNError *)error {
    
    if (_resultGroup1 != NULL) {
        if (error.code == kPNClientConfigurationError) {
            dispatch_group_leave(_resultGroup1);
        }
    }
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    if (_resultGroup2 != NULL) {
        dispatch_group_leave(_resultGroup2);
    }
    
    if (_resultGroup3 != NULL) {
        XCTAssertEqualObjects(_testConfiguration3.publishKey, [[PubNub configuration] publishKey], @"Configuration wasn't updated.");
        dispatch_group_leave(_resultGroup3);
    }
    
    if (_resultGroup4 != NULL) {
        XCTAssertTrue([_testConfiguration3.publishKey isEqualToString:[[PubNub configuration] publishKey]] || [_testConfiguration2.publishKey isEqualToString:[[PubNub configuration] publishKey]], @"We didn't install any valid congifugation");
        dispatch_group_leave(_resultGroup4);
    }
}

- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {
    if (_resultGroup2 != NULL) {
        dispatch_group_leave(_resultGroup2);
    }
}

@end
