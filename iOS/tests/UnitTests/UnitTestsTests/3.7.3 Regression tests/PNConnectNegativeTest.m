//
//  PNConnectNegativeTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 11/14/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface PNConnectNegativeTest : XCTestCase

@end

@implementation PNConnectNegativeTest

- (void)setUp {
    [super setUp];
    [PubNub disconnect];
}

- (void)tearDown {
    [PubNub disconnect];
    [super tearDown];
}

// expected behaviour gracefully call error block with human readable error
- (void)testPubNubConnectSuccessWithoutConfiruration {
    
    dispatch_group_t _resGroup1 = dispatch_group_create();
    
    dispatch_group_enter(_resGroup1);
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        XCTFail(@"We shouldn't connect without configuration");
        
        dispatch_group_leave(_resGroup1);
    }
                         errorBlock:^(PNError *connectionError) {
                             
                             if (connectionError) {
                                 dispatch_group_leave(_resGroup1);
                             } else {
                                 XCTFail(@"Error cannot be nil during test run: %@", connectionError);
                             }
                             
                         }];
    
    if ([GCDWrapper isGroup:_resGroup1 timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout is fired. PubNub connection passed unsuccessfully");
    }
    
    _resGroup1 = nil;
}

@end
