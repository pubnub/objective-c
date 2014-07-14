//
//  PNResponseTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNResponse.h"

@interface PNResponse (test)
@property (nonatomic, strong) NSData *content;
@property (nonatomic, assign) NSUInteger size;
- (void)handleJSONDecodeErrorWithCode:(NSUInteger)errorCode;
- (NSString *)decodedResponse;
- (void)getCallbackFunction:(NSString **)callback requestIdentifier:(NSString **)identifier fromData:(NSData *)responseData;
@end


@interface PNResponseTest : SenTestCase

@end

@implementation PNResponseTest

-(void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testInitWithContent {
	NSData *data = [@"s_r([])" dataUsingEncoding:NSUTF8StringEncoding];
	PNResponse *response = [[PNResponse alloc] initWithContent: data size: 123 code: 1 lastResponseOnConnection: YES];
	STAssertTrue( response != nil, @"");
	STAssertTrue( response.content == data, @"");
	STAssertTrue( response.size == 123, @"");
	STAssertTrue( response.statusCode == 1, @"");
	STAssertTrue( response.lastResponseOnConnection == YES, @"");
	STAssertTrue( [response.callbackMethod isEqualToString: @"s"] == YES, @"");
	STAssertTrue( [response.requestIdentifier isEqualToString: @"r"] == YES, @"");
	STAssertTrue( [response.response isKindOfClass: [NSArray class]] == YES, @"");
	STAssertTrue( [response.response count] == 0, @"");

	data = [@"s_r({})" dataUsingEncoding:NSUTF8StringEncoding];
	response = [[PNResponse alloc] initWithContent: data size: 123 code: 1 lastResponseOnConnection: YES];
	STAssertTrue( response != nil, @"");
	STAssertTrue( response.content == data, @"");
	STAssertTrue( response.size == 123, @"");
	STAssertTrue( response.statusCode == 1, @"");
	STAssertTrue( response.lastResponseOnConnection == YES, @"");
	STAssertTrue( [response.callbackMethod isEqualToString: @"s"] == YES, @"");
	STAssertTrue( [response.requestIdentifier isEqualToString: @"r"] == YES, @"");
	STAssertTrue( [response.response isKindOfClass: [NSDictionary class]] == YES, @"");
	STAssertTrue( [response.response count] == 0, @"");

	data = [@"(najnajna;dn;)" dataUsingEncoding:NSUTF8StringEncoding];
	response = [[PNResponse alloc] initWithContent: data size: 123 code: 1 lastResponseOnConnection: YES];
	STAssertTrue( response != nil, @"");
	STAssertTrue( response.content == data, @"");
	STAssertTrue( response.size == 0, @"");
	STAssertTrue( response.statusCode == 1, @"");
	STAssertTrue( response.lastResponseOnConnection == YES, @"");
	STAssertTrue( [response.callbackMethod isEqualToString: @""] == YES, @"");
	STAssertTrue( response.response == 0, @"");
}

-(void)testHandleJSONDecodeErrorWithCode {
	PNResponse *response = [[PNResponse alloc] init];
	response.content = [@"s_r([])" dataUsingEncoding:NSUTF8StringEncoding];
	response.size = 456;
	[response handleJSONDecodeErrorWithCode: 123];
	STAssertTrue( response.size == 0, @"");
	STAssertTrue( [response.error isKindOfClass: [PNError class]] == YES, @"");
	STAssertTrue( response.error.code == 123, @"");
	STAssertTrue( [response.callbackMethod isEqualToString: @"s"] == YES, @"");
	STAssertTrue( [response.requestIdentifier isEqualToString: @"r"] == YES, @"");
}

-(void)testDecodedResponse {
	PNResponse *response = [[PNResponse alloc] init];
	response.content = [@"  s_r([])  " dataUsingEncoding:NSUTF8StringEncoding];
	STAssertTrue( [[response decodedResponse] isEqualToString: @"s_r([])"] == YES, @"");
}

-(void)testGetCallbackFunction {
	PNResponse *response = [[PNResponse alloc] init];
	NSString *callback = nil;
	NSString *identifier = nil;
	[response getCallbackFunction: &callback requestIdentifier: &identifier fromData:[@"s_r([])" dataUsingEncoding:NSUTF8StringEncoding]];
	STAssertTrue( [callback isEqualToString: @"s"] == YES, @"");
	STAssertTrue( [identifier isEqualToString: @"r"] == YES, @"");
}


@end


