//
//  ConnectDisconnectTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 3/27/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static const NSUInteger kAmountOfPassages = 2;

@interface ConnectDisconnectTest : XCTestCase

@end

@implementation ConnectDisconnectTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [PubNub disconnect];
}

- (void)testSingletone {
    // This is an example of a functional test case.
    
    GCDGroup *resGroup = [GCDGroup group];
    
    void (^connectDisconnect)() = ^void() {

        [PubNub disconnect];
        PNConfiguration *configuration = [PNConfiguration defaultTestConfiguration];
        
        [PubNub setConfiguration:configuration];
        [PubNub connectWithSuccessBlock:^(NSString *origin) {
            [resGroup leave];
        }
                             errorBlock:^(PNError *connectionError) {
                                 XCTFail(@"Error during connect to PubNub: %@", connectionError);
                                 [resGroup leave];
                             }];
    };
    
    
    [resGroup enterTimes:kAmountOfPassages];
    for (int i = 0; i < kAmountOfPassages; i++) {
        connectDisconnect();
    }
    
    if ([GCDWrapper isGCDGroup:resGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout to connect to PubNub service");
        return;
    }
}

@end
