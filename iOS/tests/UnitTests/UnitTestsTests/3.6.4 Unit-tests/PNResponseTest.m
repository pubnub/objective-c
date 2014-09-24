//
//  PNResponseTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/20/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNResponse.h"

@interface PNResponse (test)
@property (nonatomic, strong) NSData *content;
@property (nonatomic, assign) NSUInteger size;
- (void)handleJSONDecodeErrorWithCode:(NSUInteger)errorCode;
- (NSString *)decodedResponse;
- (void)getCallbackFunction:(NSString **)callback requestIdentifier:(NSString **)identifier fromData:(NSData *)responseData;
@end


@interface PNResponseTest : XCTestCase

@end

@implementation PNResponseTest

-(void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testInitWithContent {
	NSData *data = [@"s_r([])" dataUsingEncoding:NSUTF8StringEncoding];
	PNResponse *response = [[PNResponse alloc] initWithContent: data size: 123 code: 1 lastResponseOnConnection: YES];
	XCTAssertTrue( response != nil, @"");
	XCTAssertTrue( response.content == data, @"");
	XCTAssertTrue( response.size == 123, @"");
	XCTAssertTrue( response.statusCode == 1, @"");
	XCTAssertTrue( response.lastResponseOnConnection == YES, @"");
	XCTAssertTrue( [response.callbackMethod isEqualToString: @"s"] == YES, @"");
	XCTAssertTrue( [response.requestIdentifier isEqualToString: @"r"] == YES, @"");
	XCTAssertTrue( [response.response isKindOfClass: [NSArray class]] == YES, @"");
	XCTAssertTrue( [response.response count] == 0, @"");

	data = [@"s_r({})" dataUsingEncoding:NSUTF8StringEncoding];
	response = [[PNResponse alloc] initWithContent: data size: 123 code: 1 lastResponseOnConnection: YES];
	XCTAssertTrue( response != nil, @"");
	XCTAssertTrue( response.content == data, @"");
	XCTAssertTrue( response.size == 123, @"");
	XCTAssertTrue( response.statusCode == 1, @"");
	XCTAssertTrue( response.lastResponseOnConnection == YES, @"");
	XCTAssertTrue( [response.callbackMethod isEqualToString: @"s"] == YES, @"");
	XCTAssertTrue( [response.requestIdentifier isEqualToString: @"r"] == YES, @"");
	XCTAssertTrue( [response.response isKindOfClass: [NSDictionary class]] == YES, @"");
	XCTAssertTrue( [response.response count] == 0, @"");

	data = [@"(najnajna;dn;)" dataUsingEncoding:NSUTF8StringEncoding];
	response = [[PNResponse alloc] initWithContent: data size: 123 code: 1 lastResponseOnConnection: YES];
	XCTAssertTrue( response != nil, @"");
	XCTAssertTrue( response.content == data, @"");
	XCTAssertTrue( response.size == 0, @"");
	XCTAssertTrue( response.statusCode == 1, @"");
	XCTAssertTrue( response.lastResponseOnConnection == YES, @"");
	XCTAssertTrue( [response.callbackMethod isEqualToString: @""] == YES, @"");
	XCTAssertTrue( response.response == 0, @"");
}

-(void)testHandleJSONDecodeErrorWithCode {
	PNResponse *response = [[PNResponse alloc] init];
	response.content = [@"s_r([])" dataUsingEncoding:NSUTF8StringEncoding];
	response.size = 456;
	[response handleJSONDecodeErrorWithCode: 123];
	XCTAssertTrue( response.size == 0, @"");
	XCTAssertTrue( [response.error isKindOfClass: [PNError class]] == YES, @"");
	XCTAssertTrue( response.error.code == 123, @"");
	XCTAssertTrue( [response.callbackMethod isEqualToString: @"s"] == YES, @"");
	XCTAssertTrue( [response.requestIdentifier isEqualToString: @"r"] == YES, @"");
}

-(void)testDecodedResponse {
	PNResponse *response = [[PNResponse alloc] init];
	response.content = [@"  s_r([])  " dataUsingEncoding:NSUTF8StringEncoding];
	XCTAssertTrue( [[response decodedResponse] isEqualToString: @"s_r([])"] == YES, @"");
}

-(void)testGetCallbackFunction {
	PNResponse *response = [[PNResponse alloc] init];
	NSString *callback = nil;
	NSString *identifier = nil;
	[response getCallbackFunction: &callback requestIdentifier: &identifier fromData:[@"s_r([])" dataUsingEncoding:NSUTF8StringEncoding]];
	XCTAssertTrue( [callback isEqualToString: @"s"] == YES, @"");
	XCTAssertTrue( [identifier isEqualToString: @"r"] == YES, @"");
}


@end


