//
//  ResetDeallocTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 3/11/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface ResetDeallocTest : XCTestCase

@end

@implementation ResetDeallocTest {
    GCDGroup *_resGroup;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [PubNub disconnect];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSimpleDeallocClient {
    // This is an example of a functional test case.
    _resGroup = [GCDGroup group];
    
    [_resGroup enter];
    
    PubNub *pubNubClient = [PubNub connectingClientWithConfiguration:[PNConfiguration defaultTestConfiguration]
                                                     andSuccessBlock:^(NSString *origin) {
                                                         [_resGroup leave];
                                                     } errorBlock:^(PNError *error) {
                                                         XCTFail(@"Error during connect: %@", [error localizedDescription]);
                                                                                                                  [_resGroup leave];
                                                     }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout fired during connection.");
    }
    
    pubNubClient = nil;
    
    // just wait 5 second to make sure we remove it correctly.
    
    [GCDWrapper sleepForSeconds:5];
}

- (void)testResetClient {
    // This is an example of a functional test case.
    _resGroup = [GCDGroup group];
    
    [_resGroup enter];
    
    [PubNub setConfiguration:[PNConfiguration defaultTestConfiguration]];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        [_resGroup leave];
    } errorBlock:^(PNError *error) {
        XCTFail(@"Error during connect: %@", [error localizedDescription]);
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout fired during connection.");
    }
    
    [PubNub resetClient];
    
    // just wait 5 second to make sure we remove it correctly.
    
    [GCDWrapper sleepForSeconds:5];
}

@end
