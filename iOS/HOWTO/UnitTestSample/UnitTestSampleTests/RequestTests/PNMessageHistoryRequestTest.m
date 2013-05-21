//
//  PNMessageHistoryRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNMessageHistoryRequestTest.h"
#import "PNMessageHistoryRequest.h"
#import "PNMessageHistoryRequest+Protected.h"

#import <OCMock/OCMock.h>

#import "PNDate.h"
#import "PNChannel.h"

@interface PNMessageHistoryRequest ()


#pragma mark - Properties

// Stores reference on channel for which history should
// be pulled out
@property (nonatomic, strong) PNChannel *channel;

// Stores reference on history time frame start/end dates (time tokens)
@property (nonatomic, strong) PNDate *startDate;
@property (nonatomic, strong) PNDate *endDate;

@end

@implementation PNMessageHistoryRequestTest

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
    id mockChannel = [OCMockObject mockForClass:[PNChannel class]];
    
    id mockStartDate = [OCMockObject mockForClass:[PNDate class]];
    
    id mockEndDate = [OCMockObject mockForClass:[PNDate class]];
    
    id mockRequest = [OCMockObject partialMockForObject:[PNMessageHistoryRequest alloc]];
    
    [[mockRequest expect] setChannel:mockChannel];
    [[mockRequest expect] setStartDate:mockStartDate];
    [[mockRequest expect] setEndDate:mockEndDate];
    
    PNMessageHistoryRequest *request = [mockRequest initForChannel:mockChannel from:mockStartDate to:mockEndDate limit:0 reverseHistory:NO];
    
    STAssertNotNil(request, @"Cannot initialize request");
    
    [mockRequest verify];
}

#pragma mark - Interaction tests

- (void)testMessageHistoryRequestForChannel {
    STAssertNotNil([PNMessageHistoryRequest messageHistoryRequestForChannel:nil from:nil to:nil limit:0 reverseHistory:NO], @"Cannot initialize PNMessageHistoryRequest");
}

@end
