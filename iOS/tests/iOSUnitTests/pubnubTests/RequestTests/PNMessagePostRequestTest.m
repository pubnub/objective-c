//
//  PNMessagePostRequestTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/19/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNMessagePostRequestTest.h"
#import "PNMessagePostRequest.h"
#import "PNMessagePostRequest+Protected.h"

#import <OCMock/OCMock.h>

#import "PNMessage.h"

@interface PNMessagePostRequest ()


#pragma mark - Properties

// Stores reference on message object which will
// be processed
@property (nonatomic, strong) PNMessage *message;

@end

@implementation PNMessagePostRequestTest

- (void)setUp
{
    [super setUp];
    
    NSLog(@"setUp: %@", self.name);
}

- (void)tearDown
{
	[NSThread sleepForTimeInterval:0.1];
    [super tearDown];
}

#pragma mark - States tests

- (void)testInitWithMessage {
    id mockMessage = [OCMockObject mockForClass:[PNMessage class]];
    
    id mockRequest = [OCMockObject partialMockForObject:[PNMessagePostRequest alloc]];
    
    [[mockRequest expect] setMessage:mockMessage];
    
    PNMessagePostRequest *request = [mockRequest initWithMessage:mockMessage];
    
    STAssertNotNil(request, @"Cannot initialize message post request");
    
    [mockRequest verify];
}

#pragma mark - Interaction tests

- (void)testPostMessageRequestWithMessage {
    STAssertNotNil([[PNMessagePostRequest alloc] initWithMessage:nil], @"Cannot initialize post message request");
}

@end
