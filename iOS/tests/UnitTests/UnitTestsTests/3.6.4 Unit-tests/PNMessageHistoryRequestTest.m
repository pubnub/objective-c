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

-(void)setUp {
	[super setUp];
	[PubNub resetClient];
}

- (void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
    [super tearDown];
}

#pragma mark - States tests


/*
- (void)testInitForChannelMock {
    id mockChannel = [OCMockObject mockForClass:[PNChannel class]];
    
    id mockStartDate = [OCMockObject mockForClass:[PNDate class]];
    
    id mockEndDate = [OCMockObject mockForClass:[PNDate class]];
    
    id mockRequest = [OCMockObject partialMockForObject:[PNMessageHistoryRequest alloc]];
    
    [[mockRequest expect] setChannel:mockChannel];
    [[mockRequest expect] setStartDate:mockStartDate];
    [[mockRequest expect] setEndDate:mockEndDate];
    
    PNMessageHistoryRequest *request = [mockRequest initForChannel: mockChannel from: mockStartDate to: mockEndDate limit:0 reverseHistory: NO includingTimeToken: NO];
    
    XCTAssertNotNil(request, @"Cannot initialize request");
    
    [mockRequest verify];
}
 */
///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)testInitForChannel {
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNDate *from = [PNDate dateWithToken: @(123)];
	PNDate *to = [PNDate dateWithToken: @(124)];
	PNMessageHistoryRequest *requst = [[PNMessageHistoryRequest alloc] initForChannel: channel from: from to: to limit: 111 reverseHistory: YES includingTimeToken: YES];

	XCTAssertTrue( requst.sendingByUserRequest == YES, @"");
	XCTAssertTrue( requst.channel == channel, @"");
	XCTAssertTrue( requst.startDate == from, @"");
	XCTAssertTrue( requst.endDate == to, @"");
	XCTAssertTrue( requst.limit == 111, @"");
	XCTAssertTrue( requst.includeTimeToken == YES, @"");
	XCTAssertTrue( requst.revertMessages == YES, @"");
}

-(void)testCallbackMethodName {
	PNMessageHistoryRequest *requst = [[PNMessageHistoryRequest alloc] init];
	XCTAssertTrue( [[requst callbackMethodName] isEqualToString: @"h"] == YES, @"");
}

-(void)testResourcePath {
	PNConfiguration *conf = [PNConfiguration configurationWithPublishKey: @"publish" subscribeKey: @"demo" secretKey: @"secret" authorizationKey: @"auth"];
	[PubNub setConfiguration: conf];

	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNDate *from = [PNDate dateWithToken: @(123)];
	PNDate *to = [PNDate dateWithToken: @(124)];
	PNMessageHistoryRequest *requst = [[PNMessageHistoryRequest alloc] initForChannel: channel from: from to: to limit: 111 reverseHistory: YES includingTimeToken: YES];
	NSString *resourcePath = [requst resourcePath];
	NSLog(@"res %@", resourcePath);
	XCTAssertTrue( [resourcePath rangeOfString: @"/v2/history/sub-key/demo/channel/channel?callback=h_"].location == 0, @"");
	XCTAssertTrue( [resourcePath rangeOfString: @"&start=123&end=124&count=111&reverse=true&include_token=true"].location != NSNotFound, @"");
}

-(void)testMessageHistoryRequestForChannel {
	PNChannel *channel = [PNChannel channelWithName: @"channel"];
	PNDate *from = [PNDate dateWithToken: @(123)];
	PNDate *to = [PNDate dateWithToken: @(124)];
	PNMessageHistoryRequest *requst = [PNMessageHistoryRequest messageHistoryRequestForChannel: channel from: from to: to limit:111 reverseHistory: YES includingTimeToken: YES];

	XCTAssertTrue( requst.sendingByUserRequest == YES, @"");
	XCTAssertTrue( requst.channel == channel, @"");
	XCTAssertTrue( requst.startDate == from, @"");
	XCTAssertTrue( requst.endDate == to, @"");
	XCTAssertTrue( requst.limit == 111, @"");
	XCTAssertTrue( requst.includeTimeToken == YES, @"");
	XCTAssertTrue( requst.revertMessages == YES, @"");
}

@end



