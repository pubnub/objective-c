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

@property (nonatomic, strong) PNChannel *channel;

// Stores reference on history time frame start/end dates (time tokens)
@property (nonatomic, strong) PNDate *startDate;
@property (nonatomic, strong) PNDate *endDate;
@property (nonatomic, assign) NSUInteger limit;
@property (nonatomic, assign, getter = shouldRevertMessages) BOOL revertMessages;
@property (nonatomic, assign, getter = shouldIncludeTimeToken) BOOL includeTimeToken;

@end

@implementation PNMessageHistoryRequestTest


- (void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

#pragma mark - States tests

- (void)testInitForChannelMock {
    id mockChannel = [OCMockObject mockForClass:[PNChannel class]];
    
    id mockStartDate = [OCMockObject mockForClass:[PNDate class]];
    
    id mockEndDate = [OCMockObject mockForClass:[PNDate class]];
    
    id mockRequest = [OCMockObject partialMockForObject:[PNMessageHistoryRequest alloc]];
    
    [[mockRequest expect] setChannel:mockChannel];
    [[mockRequest expect] setStartDate:mockStartDate];
    [[mockRequest expect] setEndDate:mockEndDate];
    
    PNMessageHistoryRequest *request = [mockRequest initForChannel: mockChannel from: mockStartDate to: mockEndDate limit:0 reverseHistory: NO includingTimeToken: NO];
    
    STAssertNotNil(request, @"Cannot initialize request");
    
    [mockRequest verify];
}
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)testInitForChannel {
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNDate *from = [PNDate dateWithToken: @(123)];
	PNDate *to = [PNDate dateWithToken: @(124)];
	PNMessageHistoryRequest *requst = [[PNMessageHistoryRequest alloc] initForChannel: channel from: from to: to limit: 111 reverseHistory: YES includingTimeToken: YES];

	STAssertTrue( requst.sendingByUserRequest == YES, @"");
	STAssertTrue( requst.channel == channel, @"");
	STAssertTrue( requst.startDate == from, @"");
	STAssertTrue( requst.endDate == to, @"");
	STAssertTrue( requst.limit == 111, @"");
	STAssertTrue( requst.includeTimeToken == YES, @"");
	STAssertTrue( requst.revertMessages == YES, @"");
}

-(void)testCallbackMethodName {
	PNMessageHistoryRequest *requst = [[PNMessageHistoryRequest alloc] init];
	STAssertTrue( [[requst callbackMethodName] isEqualToString: @"h"] == YES, @"");
}

-(void)testResourcePath {
	PNConfiguration *conf = [PNConfiguration configurationWithPublishKey: @"publish" subscribeKey: @"subscr" secretKey: @"secret" authorizationKey: @"auth"];
	[PubNub setConfiguration: conf];

	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNDate *from = [PNDate dateWithToken: @(123)];
	PNDate *to = [PNDate dateWithToken: @(124)];
	PNMessageHistoryRequest *requst = [[PNMessageHistoryRequest alloc] initForChannel: channel from: from to: to limit: 111 reverseHistory: YES includingTimeToken: YES];
	NSString *resourcePath = [requst resourcePath];
	NSLog(@"res %@", resourcePath);
	STAssertTrue( [resourcePath rangeOfString: @"/v2/history/sub-key/subscr/channel/channel?callback=h_"].location == 0, @"");
	STAssertTrue( [resourcePath rangeOfString: @"&start=123&end=124&count=111&reverse=true&include_token=true&auth=auth"].location != NSNotFound, @"");
}

-(void)testMessageHistoryRequestForChannel {
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNDate *from = [PNDate dateWithToken: @(123)];
	PNDate *to = [PNDate dateWithToken: @(124)];
	PNMessageHistoryRequest *requst = [PNMessageHistoryRequest messageHistoryRequestForChannel: channel from: from to: to limit:111 reverseHistory: YES includingTimeToken: YES];

	STAssertTrue( requst.sendingByUserRequest == YES, @"");
	STAssertTrue( requst.channel == channel, @"");
	STAssertTrue( requst.startDate == from, @"");
	STAssertTrue( requst.endDate == to, @"");
	STAssertTrue( requst.limit == 111, @"");
	STAssertTrue( requst.includeTimeToken == YES, @"");
	STAssertTrue( requst.revertMessages == YES, @"");
}

@end



