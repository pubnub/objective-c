//
//  PNResponseParserTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/31/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNResponseParser.h"
#import "PNResponse.h"
#import "PNPushNotificationsEnabledChannelsParser.h"
#import "PNTimeTokenResponseParser.h"
#import "PNChannelHistoryParser.h"
#import "PNChannelEventsResponseParser.h"
#import "PNOperationStatusResponseParser.h"
#import "PNActionResponseParser.h"
#import "PNHereNowResponseParser.h"
#import "PNAccessRightsResponseParser.h"
#import "PNErrorResponseParser.h"

@interface PNResponseParser (test)
+ (Class)classForResponse:(PNResponse *)response;
@end

@interface PNResponse (test)

@property (nonatomic, strong) id response;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, copy) NSString *callbackMethod;

@end

@interface PNResponseParserTest : SenTestCase

@end

@implementation PNResponseParserTest

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testParserForResponse {
	PNResponse *response = [[PNResponse alloc] init];
	NSArray *channels = @[@"ch1", @"ch2"];
	response.response = channels;
	response.callbackMethod = @"pec";
	PNResponseParser *parser = [PNResponseParser parserForResponse: response];
	STAssertTrue( parser != nil, @"");
	STAssertTrue( [parser isKindOfClass: [PNPushNotificationsEnabledChannelsParser class]] == YES, @"");

	response = [[PNResponse alloc] init];
	response.response = @[@"item1"];
	parser = [PNResponseParser parserForResponse: response];
	STAssertTrue( parser != nil, @"");
	STAssertTrue( [parser isKindOfClass: [PNTimeTokenResponseParser class]] == YES, @"");

	response = [[PNResponse alloc] init];
	response.response = @[ @[], @(1), @(2)];
	parser = [PNResponseParser parserForResponse: response];
	STAssertTrue( parser != nil, @"");
	STAssertTrue( [parser isKindOfClass: [PNChannelHistoryParser class]] == YES, @"");

	response = [[PNResponse alloc] init];
	response.response = @[ @[], @"", @(2)];
	Class class = [PNResponseParser classForResponse: response];
	STAssertTrue( class != nil, @"");
	STAssertTrue( class == [PNChannelEventsResponseParser class], @"");

	response = [[PNResponse alloc] init];
	response.response = @[ @"", @"", @(2)];
	parser = [PNResponseParser parserForResponse: response];
	STAssertTrue( parser != nil, @"");
	STAssertTrue( [parser isKindOfClass: [PNOperationStatusResponseParser class]] == YES, @"");

	response = [[PNResponse alloc] init];
	response.response = @{@"action":@"value"};
	class = [PNResponseParser classForResponse: response];
	STAssertTrue( class != nil, @"");
	STAssertTrue( class == [PNActionResponseParser class], @"");

	response = [[PNResponse alloc] init];
	response.response = @{@"uuids":@"uuid", @"occupancy":@"occupancy"};
	class = [PNResponseParser classForResponse: response];
	STAssertTrue( class != nil, @"");
	STAssertTrue( class == [PNHereNowResponseParser class], @"");

	response = [[PNResponse alloc] init];
	response.response = @{@"payload":@"payload", @"service":@"Access Manager"};
	class = [PNResponseParser classForResponse: response];
	STAssertTrue( class != nil, @"");
	STAssertTrue( class == [PNAccessRightsResponseParser class], @"");

	response = [[PNResponse alloc] init];
	response.response = @{@"payload":@"payload", @"error":@"error"};
	class = [PNResponseParser classForResponse: response];
	STAssertTrue( class != nil, @"");
	STAssertTrue( class == [PNErrorResponseParser class], @"");

	response = [[PNResponse alloc] init];
	class = [PNResponseParser classForResponse: response];
	STAssertTrue( class != nil, @"");
	STAssertTrue( class == [PNErrorResponseParser class], @"");
}



@end




