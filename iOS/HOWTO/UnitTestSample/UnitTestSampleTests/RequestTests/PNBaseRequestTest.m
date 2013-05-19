//
//  PNBaseRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNBaseRequestTest.h"
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import <OCMock/OCMock.h>

@implementation PNBaseRequestTest

- (void)setUp
{
    [super setUp];
    
    NSLog(@"setUp: %@", self.name);
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark - States tests

- (void)testTimeout {
    
}

- (void)testCallbackMethodName {
    
}

- (void)testResourcePath {
    
}

- (void)testBuffer {
    
}

// Protected methods

- (void)testReset {
    
}

- (void)testAllowedRetryCount {
    
}

- (void)resetRetryCount {
    
}

- (void)testIncreaseRetryCount {
    
}

- (void)testCanRetry {
    
}

- (void)testHTTPPayload {
    
}

#pragma mark - Interaction tests

@end
