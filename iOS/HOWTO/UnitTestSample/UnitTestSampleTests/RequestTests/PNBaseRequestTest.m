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

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"

@interface PNBaseRequest ()

@property (nonatomic, assign) NSUInteger retryCount;

@end


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
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
    
    STAssertTrue([PubNub sharedInstance].configuration.nonSubscriptionRequestTimeout == [baseRequest timeout], @"Default value of timeout should be qual nonSubscriptionRequestTimeout");
}

- (void)testCallbackMethodName {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
    
    STAssertTrue([[baseRequest callbackMethodName] isEqualToString:@"0"], @"Default value of callback method name is 0");
}

- (void)testResourcePath {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
    
    STAssertTrue([[baseRequest resourcePath] isEqualToString:@"/"], @"Default value of callback method name is //");
}

- (void)testBuffer {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
    
    STAssertTrue([[baseRequest buffer] isKindOfClass:[PNWriteBuffer class]], @"Should return valid object of write buffer here");
}

// Protected methods

- (void)testReset {
    id mockBaseRequest = [OCMockObject partialMockForObject:[[PNBaseRequest alloc] init]];
    [[mockBaseRequest expect] setRetryCount:0];
    [[mockBaseRequest expect] setProcessed:NO];
    [[mockBaseRequest expect] setProcessing:NO];
    
    [mockBaseRequest reset];
    
    [mockBaseRequest verify];
}

- (void)testAllowedRetryCount {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
    
    STAssertTrue([baseRequest allowedRetryCount] == kPNRequestMaximumRetryCount, @"Should be defined as kPNRequestMaximumRetryCount");
}


- (void)testIncreaseRetryCount {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
    
    [baseRequest increaseRetryCount];
    
    STAssertTrue([baseRequest retryCount] == 1, @"By default retryCount should be 0");
}

- (void)testCanRetry {
    id mockBaseRequest = [OCMockObject partialMockForObject:[[PNBaseRequest alloc] init]];
    [[mockBaseRequest expect] retryCount];
    [[mockBaseRequest expect] allowedRetryCount];
    
    [mockBaseRequest canRetry];
    
    [mockBaseRequest verify];
}

- (void)testHTTPPayload {
    PNBaseRequest *baseRequest = [[PNBaseRequest alloc] init];
    
    NSString *payload = [baseRequest HTTPPayload];
    
    STAssertTrue([payload isKindOfClass:[NSString class]], @"Payload should be a string");
    STAssertTrue([payload length] > 0, @"Payload should has length more than zero");
}

#pragma mark - Interaction tests

@end
