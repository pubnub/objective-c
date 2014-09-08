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

#import <SenTestingKit/SenTestingKit.h>
#import "GCDWrapper.h"

@interface PNConfigurationChangeTest : SenTestCase

<
PNDelegate
>

@end

@implementation PNConfigurationChangeTest {
    dispatch_group_t _resultGroup1;
    dispatch_group_t _resultGroup2;
    dispatch_group_t _resultGroup3;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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
        STFail(@"Didn't receive error message about invalid congiguration.");
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
        STFail(@"Cannot setup with configuration.");
    }
    
    _resultGroup2 = NULL;
}

- (void)testChangingSeveralConfigurations {
    [PubNub setDelegate:self];
    
    _resultGroup3 = dispatch_group_create();
    
    /*
     [9/8/14, 11:00:58 AM] Vadim Osovets: Product 	Sandbox
     Subscribe Key 	sub-c-6dc508c0-bff0-11e3-a219-02ee2ddab7fe
     Publish Key 	pub-c-12b1444d-4535-4c42-a003-d509cc071e09
     Secret Key 	sec-c-YjIzMWEzZmEtYWVlYS00MzMzLTkyZGItNWJkMjRlZGQ4MjAz
     Key Status 	Enabled Disable
     
     [9/8/14, 4:39:01 PM] Sergey Kazanskiy: static NSString * const kPNPublishKey = @"pub-c-c37b4f44-6eab-4827-9059-3b1c9a4085f6";
     static NSString * const kPNSubscriptionKey = @"sub-c-fb5d8de4-3735-11e4-8736-02ee2ddab7fe";
     static NSString * const kPNSecretKey = @"sec-c-NDA1YjYyYjktZTA0NS00YmIzLWJmYjQtZjI4MGZmOGY0MzIw";
     */
    
    PNConfiguration *testConfiguration1 = [PNConfiguration defaultConfiguration];
    // Vadim's keys
    PNConfiguration *testConfiguration2 = [PNConfiguration configurationForOrigin:kTestPNOriginHost
                                                                       publishKey:@"pub-c-12b1444d-4535-4c42-a003-d509cc071e09" subscribeKey:@"sub-c-6dc508c0-bff0-11e3-a219-02ee2ddab7fe"
                                                                        secretKey:@"sec-c-YjIzMWEzZmEtYWVlYS00MzMzLTkyZGItNWJkMjRlZGQ4MjAz"];
    // SergeyK's keys
    PNConfiguration *testConfiguration3 = [PNConfiguration configurationForOrigin:kTestPNOriginHost
                                                                       publishKey:@"pub-c-c37b4f44-6eab-4827-9059-3b1c9a4085f6" subscribeKey:@"sub-c-fb5d8de4-3735-11e4-8736-02ee2ddab7fe"
                                                                        secretKey:@"sec-c-NDA1YjYyYjktZTA0NS00YmIzLWJmYjQtZjI4MGZmOGY0MzIw"];
    
    // Test-case 1: connect and change configuration
    dispatch_group_enter(_resultGroup3);
    
    [PubNub setupWithConfiguration:testConfiguration1 andDelegate:self];
    [PubNub connect];
    [PubNub setupWithConfiguration:testConfiguration2 andDelegate:self];
    [PubNub setupWithConfiguration:testConfiguration3 andDelegate:self];
    
    if ([GCDWrapper isGroup:_resultGroup3 timeoutFiredValue:10]) {
        STFail(@"Cannot connect with configuration.");
    }
    
    [PubNub disconnect];
    
    // Test-case 2: start connect and chanding configuration simultaneously
    
    dispatch_group_t _startGroup = dispatch_group_create();

    [PubNub setupWithConfiguration:testConfiguration1 andDelegate:self];
    
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
            [PubNub setupWithConfiguration:testConfiguration2 andDelegate:self];
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"t3");
        if (dispatch_group_wait(_startGroup, DISPATCH_TIME_FOREVER) == 0) {
            NSLog(@"t3.1");
            [PubNub setupWithConfiguration:testConfiguration3 andDelegate:self];
        }

    });
    
    [GCDWrapper sleepForSeconds:1];
    
    dispatch_group_leave(_startGroup);
    
    if ([GCDWrapper isGroup:_resultGroup3 timeoutFiredValue:20]) {
        STFail(@"Cannot connect with configuration.");
    }
    
    _resultGroup3 = NULL;
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
        NSLog(@"origin: %@, pub-key: %@", origin, [PubNub configuration].publishKey);
        dispatch_group_leave(_resultGroup3);
    }
}

- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {
    if (_resultGroup2 != NULL) {
        dispatch_group_leave(_resultGroup2);
    }
}

@end
