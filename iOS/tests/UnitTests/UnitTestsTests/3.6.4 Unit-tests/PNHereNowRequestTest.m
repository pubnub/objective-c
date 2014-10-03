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
/*
- (void)testInitWithChannel {
    
    id mockChannel = [OCMockObject mockForClass:[PNChannel class]];
    
    id mockRequest = [OCMockObject partialMockForObject:[PNHereNowRequest alloc]];
    
    [[mockRequest expect] setChannel:mockChannel];
    
    PNHereNowRequest *request = [mockRequest initWithChannel:mockChannel clientIdentifiersRequired: NO clientState: NO];
    
    XCTAssertNotNil(request, @"Cannot initialize request");
    
    [mockRequest verify];
}
*/
#pragma mark - Interaction tests

- (void)testWhoNowRequestForChannel {
    XCTAssertNotNil([PNHereNowRequest whoNowRequestForChannel:nil clientIdentifiersRequired: NO clientState: NO], @"Cannot initialize channel");
}

@end
