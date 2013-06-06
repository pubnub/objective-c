//
//  PNLeaveRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNLeaveRequestTest.h"
#import "PNLeaveRequest.h"
#import "PNLeaveRequest+Protected.h"

#import <OCMock/OCMock.h>

@implementation PNLeaveRequestTest

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

- (void)testInitForChannels {
    STAssertNotNil([[PNLeaveRequest  alloc] initForChannels:nil byUserRequest:NO], @"Cannot initialize request");
}

#pragma mark - Interaction tests

- (void)testLeaveRequestForChannel {
    STAssertNotNil([[PNLeaveRequest  alloc] initForChannels:nil byUserRequest:NO], @"Cannot leave request for channel");
}

- (void)testLeaveRequestForChannels {
    STAssertNotNil([[PNLeaveRequest  alloc] initForChannels:nil byUserRequest:NO], @"Cannot leave request for channels");
}


@end
