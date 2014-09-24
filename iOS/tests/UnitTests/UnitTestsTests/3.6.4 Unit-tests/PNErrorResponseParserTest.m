//
//  PNErrorResponseParserTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/23/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNErrorResponseParser+Protected.h"
#import "PNErrorResponseParser.h"
#import "PNResponse.h"
#import "PNError+Protected.h"
#import "PNError.h"
#import "PNErrorCodes.h"

@interface PNError (test)

@property (nonatomic, copy) NSString *errorMessage;

@end

@interface PNErrorResponseParser (test)

- (id)initWithResponse:(PNResponse *)response;

@end

@interface PNResponse (test)

@property (nonatomic, strong) id response;
@property (nonatomic, assign) NSInteger statusCode;

@end

@interface PNErrorResponseParserTest : XCTestCase

@end

@implementation PNErrorResponseParserTest

-(void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
    [super tearDown];
}

-(void)testInit {
	PNResponse *response = [[PNResponse alloc] init];
	response.response = [NSMutableDictionary dictionary];
	[response.response setObject: @[@"channel"] forKey: @"payload.channels"];
	[response.response setObject: @"errorMessage" forKey: @"message"];
	[response.response setObject: @"payload" forKey: @"payload"];
	[response.response setObject: @"service" forKey: @"service"];
	response.statusCode = 402;

	PNErrorResponseParser *parser = [[PNErrorResponseParser alloc] initWithResponse: response];
	XCTAssertTrue( parser != nil, @"");
	NSLog( @"[parser parsedData] %@", [parser parsedData]);
	NSLog( @"[[parser parsedData] associatedObject] %@", [[parser parsedData] associatedObject]);
	XCTAssertTrue( [[parser parsedData] associatedObject] == nil, @"");
	XCTAssertTrue( [[parser parsedData] code] == kPNUnknownError, @"");


	response = [[PNResponse alloc] init];
	response.response = [NSMutableDictionary dictionary];
	[response.response setObject: @[@"channel"] forKey: @"payload.channels"];
	[response.response setObject: @"errorMessage" forKey: @"message"];

	parser = [[PNErrorResponseParser alloc] initWithResponse: response];
	XCTAssertTrue( parser != nil, @"");
	XCTAssertTrue( [[[parser parsedData] errorMessage] isEqualToString: @"errorMessage"], @"");


	response = [[PNResponse alloc] init];
	response.response = nil;

	parser = [[PNErrorResponseParser alloc] initWithResponse: response];
	XCTAssertTrue( [[parser parsedData] code] == kPNResponseMalformedJSONError, @"");
}

@end
