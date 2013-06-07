//
//  PNHereNowRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNHereNowRequestTest.h"
#import "PNHereNowRequest.h"

#import "PNChannel.h"

#import <OCMock/OCMock.h>

@interface PNHereNowRequest ()

@property (nonatomic, strong) PNChannel *channel;

@end

@implementation PNHereNowRequestTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark - States tests

- (void)testInitWithChannel {
    
    id mockChannel = [OCMockObject mockForClass:[PNChannel class]];
    
    id mockRequest = [OCMockObject partialMockForObject:[PNHereNowRequest alloc]];
    
    [[mockRequest expect] setChannel:mockChannel];
    
    PNHereNowRequest *request = [mockRequest initWithChannel:mockChannel];
    
    STAssertNotNil(request, @"Cannot initialize request");
    
    [mockRequest verify];
}

#pragma mark - Interaction tests

- (void)testWhoNowRequestForChannel {
    STAssertNotNil([PNHereNowRequest whoNowRequestForChannel:nil], @"Cannot initialize channel");
}

@end
