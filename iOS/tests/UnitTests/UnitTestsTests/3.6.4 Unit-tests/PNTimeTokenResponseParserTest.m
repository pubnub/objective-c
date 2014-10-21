//
//  PNTimeTokenResponseParserTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/31/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PNTimeTokenResponseParser.h"
#import "PNResponse.h"

@interface PNResponse (test)

@property (nonatomic, strong) id response;
@property (nonatomic, assign) NSInteger statusCode;

@end

@interface PNTimeTokenResponseParser (test)
@property (nonatomic, strong) NSNumber *timeToken;
- (id)initWithResponse:(PNResponse *)response;
@end



@interface PNTimeTokenResponseParserTest : XCTestCase

@end

@implementation PNTimeTokenResponseParserTest

-(void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
    [super tearDown];
}

-(void)testInit {
	PNResponse *response = [[PNResponse alloc] init];
	response.response = @[@"status", @"123"];

	PNTimeTokenResponseParser *parser = [[PNTimeTokenResponseParser alloc] initWithResponse: response];
	XCTAssertTrue( parser != nil, @"");
	XCTAssertTrue( [parser parsedData] == parser.timeToken, @"");
	XCTAssertTrue( [[parser parsedData] intValue] == 123, @"");
}

@end
