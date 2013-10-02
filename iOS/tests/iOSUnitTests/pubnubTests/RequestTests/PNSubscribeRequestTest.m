//
//  PNSubscribeRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNSubscribeRequestTest.h"
#import "PNSubscribeRequest.h"
#import "PNSubscribeRequest+Protected.h"

#import <OCMock/OCMock.h>

#import "PNChannel.h"

@implementation PNSubscribeRequestTest

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

- (void)testInitForChannel {
   
    STAssertNotNil([[PNSubscribeRequest alloc] initForChannel:[[PNChannel alloc] init] byUserRequest:NO], @"Cannot initialize PNSubscribeRequest with channel");
}

- (void)testInitForChannels {
    STAssertNotNil([[PNSubscribeRequest alloc] initForChannels:@[] byUserRequest:NO], @"Cannot initialize PNSubscribeRequest with channels");
}

#pragma mark - Interaction tests

- (void)testSubscribeRequestForChannel {
    STAssertNotNil([[PNSubscribeRequest alloc] initForChannels:nil byUserRequest:NO], @"Cannot subscribe for channel");
}

- (void)testSubscribeRequestForChannels {
    STAssertNotNil([[PNSubscribeRequest alloc] initForChannels:nil byUserRequest:NO], @"Cannot subscribe for channels");
}

@end
